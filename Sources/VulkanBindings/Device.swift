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
}
