import Foundation
import Vulkan

public protocol VulkanInstance {
    var instance: VkInstance { get }
}

public extension VulkanInstance {
    /// Get a list of all Vulkan-supporting physical devices.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: A list of all Vulkan-supporting physical devices.
    func enumeratePhysicalDevices() throws -> [VulkanPhysicalDevice] {
        // Figure out how many devices there are
        var count: UInt32 = 0
        try check(vkEnumeratePhysicalDevices(self.instance, &count, nil))
        if count == 0 { return [] }

        // Get the devices
        var devices = Array<VkPhysicalDevice?>(repeating: nil, count: Int(count))
        try check(vkEnumeratePhysicalDevices(self.instance, &count, &devices))
        return devices.compactMap { device in
            device.map { VulkanPhysicalDevice(handle: $0) }
        }
    }
}

/// Represents an instance of Vulkan. Should be created via `OwnedVulkanInstance.getUnownedHandle()`, rather than instantiated directly.
/// Maps to `VkInstance`.
public struct VulkanUnownedInstance: VulkanInstance {
    public let instance: VkInstance
}

/// Represents a reference to a Vulkan instance.
public final class VulkanOwnedInstance: VulkanInstance {
    public let instance: VkInstance

    /// Only use if you have a pre-existing instance of Vulkan that you want to create an owner for.
    /// Prefer `UnownedVulkanInstance` for this purpose to avoid sketchy ownership semantics.
    /// - Parameter instance: The instance to own.
    public init(with instance: VkInstance) {
        self.instance = instance
    }

    /// Creates a new Vulkan instance without any information about the application.
    /// - Parameters:
    ///   - flags: The flags to pass to the instance.
    ///   - enabledLayers: The enabled validation layers.
    ///   - enabledExtensions: The enabled extensions.
    /// - Throws: Any error caused by instance initialisation.
    public init(flags: VulkanInstanceCreateFlags, enabledLayers: [String], enabledExtensions: [String]) throws {
        var instance: VkInstance?
        try withCStringsPointerAndSize(enabledLayers) { layerPtr, layerCount in
            try withCStringsPointerAndSize(enabledExtensions) { extensionPtr, extensionCount in
                let layerBase = layerPtr.baseAddress?.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: Int(layerCount)) { $0 }
                let extensionBase = extensionPtr.baseAddress?.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: Int(extensionCount)) { $0 }
                var instanceCreateInfo = VkInstanceCreateInfo.create(
                    flags: flags.rawValue,
                    pApplicationInfo: nil,
                    enabledLayerCount: layerCount,
                    ppEnabledLayerNames: layerBase,
                    enabledExtensionCount: extensionCount,
                    ppEnabledExtensionNames: extensionBase
                )

                try check(vkCreateInstance(&instanceCreateInfo, nil, &instance))
            }
        }
        self.instance = instance!
    }

    /// Creates a new Vulkan instance.
    /// - Parameters:
    ///   - flags: The flags to pass to the instance.
    ///   - enabledLayers: The enabled validation layers.
    ///   - enabledExtensions: The enabled extensions.
    ///   - appName: The name of this application, used for some GPU optimisations.
    ///   - appVersion: The version of this application.
    ///   - engineName: The name of the engine used by this application. Defaults to "VulkanBindings".
    ///   - engineVersion: The version of the engine used by this application. Defaults to 1.
    ///   - apiVersion: The maximum version of the Vulkan API used by this application. Defaults to `UInt32.max`.
    /// - Note: If using Vulkan 1.0, `apiVersion` must be set to 1.
    public init(
        flags: VulkanInstanceCreateFlags,
        enabledLayers: [String],
        enabledExtensions: [String],
        appName: String,
        appVersion: UInt32,
        engineName: String?,
        engineVersion: UInt32?,
        apiVersion: UInt32?
    ) throws {
        var instance: VkInstance?
        try withCStringsPointerAndSize(enabledLayers) { layerPtr, layerCount in
            try withCStringsPointerAndSize(enabledExtensions) { extensionPtr, extensionCount in
                try appName.withCString { pAppName in
                    try (engineName ?? "VulkanBindings").withCString { pEngineName in
                        var appInfo = VkApplicationInfo.create(
                            pApplicationName: pAppName,
                            applicationVersion: appVersion,
                            pEngineName: pEngineName,
                            engineVersion: engineVersion ?? 1,
                            apiVersion: apiVersion ?? UInt32.max
                        )
                        
                        let layerBase = layerPtr.baseAddress?.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: Int(layerCount)) { $0 }
                        let extensionBase = extensionPtr.baseAddress?.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: Int(extensionCount)) { $0 }
                        var instanceCreateInfo = VkInstanceCreateInfo.create(
                            flags: flags.rawValue,
                            pApplicationInfo: &appInfo,
                            enabledLayerCount: layerCount,
                            ppEnabledLayerNames: layerBase,
                            enabledExtensionCount: extensionCount,
                            ppEnabledExtensionNames: extensionBase
                        )

                        try check(vkCreateInstance(&instanceCreateInfo, nil, &instance))
                    }
                }
            }
        }
        self.instance = instance!
    }

    deinit {
        vkDestroyInstance(self.instance, nil)
    }

    /// Get a non-owning handle to this instance.
    /// - Returns: A non-owning handle to this instance.
    public func getUnownedHandle() -> VulkanInstance {
        return VulkanUnownedInstance(instance: self.instance)
    }
}

/// Loosely maps to `VkInstanceCreateFlags`.
public struct VulkanInstanceCreateFlags: OptionSet, Sendable {
    public let rawValue: VkInstanceCreateFlags

    public init(rawValue: VkInstanceCreateFlags) {
        self.rawValue = rawValue
    }

    public static let enumeratePortability = VulkanInstanceCreateFlags(rawValue: VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR.rawValue)
}