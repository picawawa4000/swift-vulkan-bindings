import Vulkan

/// Represents an owned Vulkan swapchain.
public final class VulkanOwnedSwapchain {
    public let swapchain: VkSwapchainKHR
    private let device: VkDevice

    public init(device: VkDevice, swapchain: VkSwapchainKHR) {
        self.device = device
        self.swapchain = swapchain
    }

    deinit {
        vkDestroySwapchainKHR(self.device, self.swapchain, nil)
    }
}

public extension VulkanDevice {
    /// Create a swapchain.
    /// - Parameter createInfo: The swapchain creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created swapchain.
    func createSwapchain(_ createInfo: inout VkSwapchainCreateInfoKHR) throws -> VulkanOwnedSwapchain {
        var swapchain: VkSwapchainKHR?
        try check(vkCreateSwapchainKHR(self.device, &createInfo, nil, &swapchain))
        return VulkanOwnedSwapchain(device: self.device, swapchain: swapchain!)
    }

    /// Get all images in a swapchain.
    /// - Parameter swapchain: The swapchain to query.
    /// - Returns: The swapchain images.
    func getSwapchainImages(_ swapchain: VulkanOwnedSwapchain) throws -> [VkImage] {
        return try getSwapchainImages(swapchain.swapchain)
    }

    /// Get all images in a swapchain.
    /// - Parameter swapchain: The swapchain handle to query.
    /// - Returns: The swapchain images.
    func getSwapchainImages(_ swapchain: VkSwapchainKHR) throws -> [VkImage] {
        var count: UInt32 = 0
        try check(vkGetSwapchainImagesKHR(self.device, swapchain, &count, nil))
        if count == 0 { return [] }

        var images = Array<VkImage?>(repeating: nil, count: Int(count))
        try images.withUnsafeMutableBufferPointer { buffer in
            try check(vkGetSwapchainImagesKHR(self.device, swapchain, &count, buffer.baseAddress))
        }
        return images.compactMap { $0 }
    }

    /// Acquire the next available swapchain image.
    /// - Parameters:
    ///   - swapchain: The swapchain to acquire from.
    ///   - timeout: The timeout in nanoseconds. Defaults to `UInt64.max`.
    ///   - semaphore: A semaphore to signal when the image is available.
    ///   - fence: A fence to signal when the image is available.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: The index of the acquired image.
    func acquireNextImage(
        from swapchain: VulkanOwnedSwapchain,
        timeout: UInt64 = UInt64.max,
        semaphore: VkSemaphore? = nil,
        fence: VkFence? = nil
    ) throws -> UInt32 {
        var index: UInt32 = 0
        try check(vkAcquireNextImageKHR(self.device, swapchain.swapchain, timeout, semaphore, fence, &index))
        return index
    }

    /// Present an image to the swapchain.
    /// - Parameter queue: The queue to present on.
    /// - Parameter presentInfo: The present info.
    /// - Throws: Any error raised by Vulkan.
    func present(queue: VkQueue, presentInfo: inout VkPresentInfoKHR) throws {
        try check(vkQueuePresentKHR(queue, &presentInfo))
    }
}
