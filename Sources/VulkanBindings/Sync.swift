import Vulkan

/// Represents an owned Vulkan semaphore.
public final class VulkanOwnedSemaphore {
    public let semaphore: VkSemaphore
    private let device: VkDevice

    public init(device: VkDevice, semaphore: VkSemaphore) {
        self.device = device
        self.semaphore = semaphore
    }

    deinit {
        vkDestroySemaphore(self.device, self.semaphore, nil)
    }
}

/// Represents an owned Vulkan fence.
public final class VulkanOwnedFence {
    public let fence: VkFence
    private let device: VkDevice

    public init(device: VkDevice, fence: VkFence) {
        self.device = device
        self.fence = fence
    }

    deinit {
        vkDestroyFence(self.device, self.fence, nil)
    }
}

public extension VulkanDevice {
    /// Create a semaphore.
    /// - Parameter flags: The semaphore creation flags.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created semaphore.
    func createSemaphore(flags: VulkanSemaphoreCreateFlags = []) throws -> VulkanOwnedSemaphore {
        var semaphore: VkSemaphore?
        var createInfo = VkSemaphoreCreateInfo.create(flags: flags.rawValue)
        try check(vkCreateSemaphore(self.device, &createInfo, nil, &semaphore))
        return VulkanOwnedSemaphore(device: self.device, semaphore: semaphore!)
    }

    /// Create a fence.
    /// - Parameter flags: The fence creation flags.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created fence.
    func createFence(flags: VulkanFenceCreateFlags = []) throws -> VulkanOwnedFence {
        var fence: VkFence?
        var createInfo = VkFenceCreateInfo.create(flags: flags.rawValue)
        try check(vkCreateFence(self.device, &createInfo, nil, &fence))
        return VulkanOwnedFence(device: self.device, fence: fence!)
    }

    /// Wait for one or more fences.
    /// - Parameters:
    ///   - fences: The fences to wait on.
    ///   - waitAll: Whether to wait for all fences or any fence.
    ///   - timeout: The timeout in nanoseconds.
    /// - Throws: Any error raised by Vulkan.
    func waitForFences(_ fences: [VkFence], waitAll: Bool = true, timeout: UInt64 = UInt64.max) throws {
        let optionalFences = fences.map { Optional($0) }
        try optionalFences.withUnsafeBufferPointer { buffer in
            try check(vkWaitForFences(self.device, UInt32(buffer.count), buffer.baseAddress, waitAll ? VK_TRUE : VK_FALSE, timeout))
        }
    }

    /// Reset one or more fences.
    /// - Parameter fences: The fences to reset.
    /// - Throws: Any error raised by Vulkan.
    func resetFences(_ fences: [VkFence]) throws {
        let optionalFences = fences.map { Optional($0) }
        try optionalFences.withUnsafeBufferPointer { buffer in
            try check(vkResetFences(self.device, UInt32(buffer.count), buffer.baseAddress))
        }
    }

    /// Submit command buffers to a queue.
    /// - Parameters:
    ///   - queue: The queue to submit to.
    ///   - submits: The submit infos.
    ///   - fence: The fence to signal on completion.
    /// - Throws: Any error raised by Vulkan.
    func submit(queue: VkQueue, submits: [VkSubmitInfo], fence: VkFence? = nil) throws {
        try submits.withUnsafeBufferPointer { buffer in
            try check(vkQueueSubmit(queue, UInt32(buffer.count), buffer.baseAddress, fence))
        }
    }
}

/// Loosely maps to `VkSemaphoreCreateFlags`.
public struct VulkanSemaphoreCreateFlags: OptionSet, Sendable {
    public let rawValue: VkSemaphoreCreateFlags

    public init(rawValue: VkSemaphoreCreateFlags) {
        self.rawValue = rawValue
    }
}

/// Loosely maps to `VkFenceCreateFlags`.
public struct VulkanFenceCreateFlags: OptionSet, Sendable {
    public let rawValue: VkFenceCreateFlags

    public init(rawValue: VkFenceCreateFlags) {
        self.rawValue = rawValue
    }

    public static let signaled = VulkanFenceCreateFlags(rawValue: VK_FENCE_CREATE_SIGNALED_BIT.rawValue)
}
