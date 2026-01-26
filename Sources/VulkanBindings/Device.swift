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
}

public protocol VulkanDevice {
    var device: VkDevice { get }
}

public extension VulkanDevice {}

public struct VulkanUnownedDevice {}

public struct VulkanOwnedDevice {}
