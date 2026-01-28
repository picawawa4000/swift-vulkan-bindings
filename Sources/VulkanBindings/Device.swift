import Vulkan

public struct VulkanPhysicalDevice {
    public let handle: VkPhysicalDevice

    /// Get the properties of this physical device.
    /// - Returns: The properties of this physical device.
    public func getProperties() -> VkPhysicalDeviceProperties {
        var properties = VkPhysicalDeviceProperties()
        vkGetPhysicalDeviceProperties(self.handle, &properties)
        return properties
    }

    /// Get the features of this physical device.
    /// - Returns: The features of this physical device.
    public func getFeatures() -> VkPhysicalDeviceFeatures {
        var features = VkPhysicalDeviceFeatures()
        vkGetPhysicalDeviceFeatures(self.handle, &features)
        return features
    }

    /// Get the memory properties of this physical device.
    /// - Returns: The memory properties of this physical device.
    public func getMemoryProperties() -> VkPhysicalDeviceMemoryProperties {
        var properties = VkPhysicalDeviceMemoryProperties()
        vkGetPhysicalDeviceMemoryProperties(self.handle, &properties)
        return properties
    }

    /// Get the format properties for the given format.
    /// - Parameter format: The format to query.
    /// - Returns: The format properties for the given format.
    public func getFormatProperties(format: VkFormat) -> VkFormatProperties {
        var properties = VkFormatProperties()
        vkGetPhysicalDeviceFormatProperties(self.handle, format, &properties)
        return properties
    }

    /// Get image format properties for the given format and usage.
    /// - Parameters:
    ///   - format: The format to query.
    ///   - type: The image type to query.
    ///   - tiling: The tiling to query.
    ///   - usage: The intended usage of the image.
    ///   - flags: Image creation flags.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: The image format properties.
    public func getImageFormatProperties(
        format: VkFormat,
        type: VkImageType,
        tiling: VkImageTiling,
        usage: VkImageUsageFlags,
        flags: VkImageCreateFlags
    ) throws -> VkImageFormatProperties {
        var properties = VkImageFormatProperties()
        try check(vkGetPhysicalDeviceImageFormatProperties(self.handle, format, type, tiling, usage, flags, &properties))
        return properties
    }

    /// Get sparse image format properties for the given format and usage.
    /// - Parameters:
    ///   - format: The format to query.
    ///   - type: The image type to query.
    ///   - samples: The sample count to query.
    ///   - usage: The intended usage of the image.
    ///   - tiling: The tiling to query.
    /// - Returns: The sparse image format properties.
    public func getSparseImageFormatProperties(
        format: VkFormat,
        type: VkImageType,
        samples: VkSampleCountFlagBits,
        usage: VkImageUsageFlags,
        tiling: VkImageTiling
    ) -> [VkSparseImageFormatProperties] {
        var count: UInt32 = 0
        vkGetPhysicalDeviceSparseImageFormatProperties(self.handle, format, type, samples, usage, tiling, &count, nil)
        if count == 0 { return [] }

        var properties = Array<VkSparseImageFormatProperties>(repeating: VkSparseImageFormatProperties(), count: Int(count))
        vkGetPhysicalDeviceSparseImageFormatProperties(self.handle, format, type, samples, usage, tiling, &count, &properties)
        return properties
    }

    /// Get the queue family properties of this physical device.
    /// - Returns: The queue family properties of this physical device.
    public func getQueueFamilyProperties() -> [VkQueueFamilyProperties] {
        var count: UInt32 = 0
        vkGetPhysicalDeviceQueueFamilyProperties(self.handle, &count, nil)
        if count == 0 { return [] }

        var queueFamilyProperties = Array<VkQueueFamilyProperties>(repeating: VkQueueFamilyProperties(), count: Int(count))
        vkGetPhysicalDeviceQueueFamilyProperties(self.handle, &count, &queueFamilyProperties)
        return queueFamilyProperties
    }

    /// Get all extensions supported by this physical device.
    /// - Parameter forLayer: The layer to get the extensions for, or `nil` to get all extensions.
    /// - Returns: The supported extensions.
    public func enumerateDeviceExtensionProperties(forLayer layerName: String? = nil) -> [VkExtensionProperties] {
        var count: UInt32 = 0
        if let name = layerName {
            _ = name.withCString { cStr in
                vkEnumerateDeviceExtensionProperties(self.handle, cStr, &count, nil)
            }
        } else {
            vkEnumerateDeviceExtensionProperties(self.handle, nil, &count, nil)
        }

        if count == 0 { return [] }

        var properties = Array<VkExtensionProperties>(repeating: VkExtensionProperties(), count: Int(count))
        if let name = layerName {
            _ = name.withCString { cStr in
                properties.withUnsafeMutableBufferPointer { buffer in
                    vkEnumerateDeviceExtensionProperties(self.handle, cStr, &count, buffer.baseAddress)
                }
            }
        } else {
            _ = properties.withUnsafeMutableBufferPointer { buffer in
                vkEnumerateDeviceExtensionProperties(self.handle, nil, &count, buffer.baseAddress)
            }
        }

        return properties
    }

    /// Create a logical device from this physical device.
    /// - Parameters:
    ///   - flags: The flags to use for device creation.
    ///   - queueCreateInfos: The queue creation infos.
    ///   - enabledLayers: The enabled validation layers.
    ///   - enabledExtensions: The enabled device extensions.
    ///   - enabledFeatures: The enabled device features. May be null.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created logical device.
    public func createDevice(
        flags: VulkanDeviceCreateFlags = [],
        queueCreateInfos: [VkDeviceQueueCreateInfo],
        enabledLayers: [String] = [],
        enabledExtensions: [String] = [],
        enabledFeatures: UnsafePointer<VkPhysicalDeviceFeatures>? = nil
    ) throws -> VulkanOwnedDevice {
        var device: VkDevice?
        try queueCreateInfos.withUnsafeBufferPointer { queueBuffer in
            try withCStringsPointerAndSize(enabledLayers) { layerPtr, layerCount in
                try withCStringsPointerAndSize(enabledExtensions) { extensionPtr, extensionCount in
                    let layerBase = layerPtr.baseAddress?.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: Int(layerCount)) { $0 }
                    let extensionBase = extensionPtr.baseAddress?.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: Int(extensionCount)) { $0 }
                    var deviceCreateInfo = VkDeviceCreateInfo.create(
                        flags: flags.rawValue,
                        queueCreateInfoCount: UInt32(queueBuffer.count),
                        pQueueCreateInfos: queueBuffer.baseAddress,
                        enabledLayerCount: layerCount,
                        ppEnabledLayerNames: layerBase,
                        enabledExtensionCount: extensionCount,
                        ppEnabledExtensionNames: extensionBase,
                        pEnabledFeatures: enabledFeatures
                    )
                    try check(vkCreateDevice(self.handle, &deviceCreateInfo, nil, &device))
                }
            }
        }
        return VulkanOwnedDevice(with: device!)
    }
}

public protocol VulkanDevice {
    var device: VkDevice { get }
}

public extension VulkanDevice {
    /// Get a queue from this device.
    /// - Parameters:
    ///   - familyIndex: The queue family index.
    ///   - queueIndex: The queue index within the family.
    /// - Returns: The queue handle.
    func getQueue(familyIndex: UInt32, queueIndex: UInt32) -> VkQueue {
        var queue: VkQueue?
        vkGetDeviceQueue(self.device, familyIndex, queueIndex, &queue)
        return queue!
    }

    /// Block until this device is idle.
    /// - Throws: Any error raised by Vulkan.
    func waitIdle() throws {
        try check(vkDeviceWaitIdle(self.device))
    }
}

public struct VulkanUnownedDevice {}

public final class VulkanOwnedDevice: VulkanDevice {
    public let device: VkDevice

    public init(with device: VkDevice) {
        self.device = device
    }

    deinit {
        vkDestroyDevice(self.device, nil)
    }
}

/// Loosely maps to `VkDeviceCreateFlags`.
public struct VulkanDeviceCreateFlags: OptionSet, Sendable {
    public let rawValue: VkDeviceCreateFlags

    public init(rawValue: VkDeviceCreateFlags) {
        self.rawValue = rawValue
    }
}
