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

    public func enumerateDeviceExtensionProperties(layerName: String? = nil) -> [VkExtensionProperties] {
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
}

public protocol VulkanDevice {
    var device: VkDevice { get }
}

public extension VulkanDevice {}

public struct VulkanUnownedDevice {}

public struct VulkanOwnedDevice {}
