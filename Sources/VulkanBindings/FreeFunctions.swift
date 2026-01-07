import Vulkan

/// The location where all free functions (that is, functions not tied to a particular object) live.
public final class VulkanFreeFunctions {
    // Disallow instantiation.
    private init() {}

    /// Gets all of the available instance extension properties.
    /// - Parameter forLayer: The layer to get the properties for. Equivalent to `layerName` in the C API.
    /// - Returns: The available instance extension properties.
    public func enumerateInstanceExtensionProperties(forLayer layerName: String?) throws -> [VkExtensionProperties] {
        var count: UInt32 = 0
        try check(vkEnumerateInstanceExtensionProperties(layerName, &count, nil))
        if count == 0 { return []; }

        var extensionProperties = Array<VkExtensionProperties>(repeating: VkExtensionProperties(), count: Int(count))
        try check(vkEnumerateInstanceExtensionProperties(layerName, &count, &extensionProperties))
        return extensionProperties
    }
}