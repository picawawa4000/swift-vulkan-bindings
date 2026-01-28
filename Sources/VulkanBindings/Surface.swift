import Vulkan

public protocol VulkanSurface {
    var surface: VkSurfaceKHR { get }
}

/// Represents a non-owning handle to a Vulkan surface.
public struct VulkanUnownedSurface: VulkanSurface {
    public let surface: VkSurfaceKHR

    public init(surface: VkSurfaceKHR) {
        self.surface = surface
    }
}

/// Represents an owned Vulkan surface.
public final class VulkanOwnedSurface: VulkanSurface {
    public let surface: VkSurfaceKHR
    private let instance: VkInstance

    public init(instance: VkInstance, surface: VkSurfaceKHR) {
        self.instance = instance
        self.surface = surface
    }

    deinit {
        vkDestroySurfaceKHR(self.instance, self.surface, nil)
    }
}

public extension VulkanPhysicalDevice {
    /// Check whether a queue family supports presenting to the given surface.
    /// - Parameters:
    ///   - surface: The surface to query.
    ///   - queueFamilyIndex: The queue family index.
    /// - Returns: True if the queue family supports presenting to the surface.
    func getSurfaceSupport(surface: VkSurfaceKHR, queueFamilyIndex: UInt32) throws -> Bool {
        var supported: VkBool32 = 0
        try check(vkGetPhysicalDeviceSurfaceSupportKHR(self.handle, queueFamilyIndex, surface, &supported))
        return supported == VK_TRUE
    }

    /// Get surface capabilities for the given surface.
    /// - Parameter surface: The surface to query.
    /// - Returns: The surface capabilities.
    func getSurfaceCapabilities(surface: VkSurfaceKHR) throws -> VkSurfaceCapabilitiesKHR {
        var capabilities = VkSurfaceCapabilitiesKHR()
        try check(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(self.handle, surface, &capabilities))
        return capabilities
    }

    /// Get all surface formats supported by this physical device for the given surface.
    /// - Parameter surface: The surface to query.
    /// - Returns: The surface formats.
    func getSurfaceFormats(surface: VkSurfaceKHR) throws -> [VkSurfaceFormatKHR] {
        var count: UInt32 = 0
        try check(vkGetPhysicalDeviceSurfaceFormatsKHR(self.handle, surface, &count, nil))
        if count == 0 { return [] }

        var formats = Array<VkSurfaceFormatKHR>(repeating: VkSurfaceFormatKHR(), count: Int(count))
        try formats.withUnsafeMutableBufferPointer { buffer in
            try check(vkGetPhysicalDeviceSurfaceFormatsKHR(self.handle, surface, &count, buffer.baseAddress))
        }
        return formats
    }

    /// Get all present modes supported by this physical device for the given surface.
    /// - Parameter surface: The surface to query.
    /// - Returns: The present modes.
    func getSurfacePresentModes(surface: VkSurfaceKHR) throws -> [VkPresentModeKHR] {
        var count: UInt32 = 0
        try check(vkGetPhysicalDeviceSurfacePresentModesKHR(self.handle, surface, &count, nil))
        if count == 0 { return [] }

        var modes = Array<VkPresentModeKHR>(repeating: VK_PRESENT_MODE_IMMEDIATE_KHR, count: Int(count))
        try modes.withUnsafeMutableBufferPointer { buffer in
            try check(vkGetPhysicalDeviceSurfacePresentModesKHR(self.handle, surface, &count, buffer.baseAddress))
        }
        return modes
    }
}
