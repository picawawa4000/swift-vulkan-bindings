import Vulkan

/// Represents an owned Vulkan buffer.
public final class VulkanOwnedBuffer {
    public let buffer: VkBuffer
    private let device: VkDevice

    public init(device: VkDevice, buffer: VkBuffer) {
        self.device = device
        self.buffer = buffer
    }

    deinit {
        vkDestroyBuffer(self.device, self.buffer, nil)
    }
}

/// Represents an owned Vulkan device memory allocation.
public final class VulkanOwnedDeviceMemory {
    public let memory: VkDeviceMemory
    private let device: VkDevice

    public init(device: VkDevice, memory: VkDeviceMemory) {
        self.device = device
        self.memory = memory
    }

    deinit {
        vkFreeMemory(self.device, self.memory, nil)
    }
}

/// Represents an owned Vulkan image view.
public final class VulkanOwnedImageView {
    public let imageView: VkImageView
    private let device: VkDevice

    public init(device: VkDevice, imageView: VkImageView) {
        self.device = device
        self.imageView = imageView
    }

    deinit {
        vkDestroyImageView(self.device, self.imageView, nil)
    }
}

public extension VulkanDevice {
    /// Create a buffer.
    /// - Parameter createInfo: The buffer creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created buffer.
    func createBuffer(_ createInfo: inout VkBufferCreateInfo) throws -> VulkanOwnedBuffer {
        var buffer: VkBuffer?
        try check(vkCreateBuffer(self.device, &createInfo, nil, &buffer))
        return VulkanOwnedBuffer(device: self.device, buffer: buffer!)
    }

    /// Get buffer memory requirements.
    /// - Parameter buffer: The buffer to query.
    /// - Returns: The buffer memory requirements.
    func getBufferMemoryRequirements(_ buffer: VulkanOwnedBuffer) -> VkMemoryRequirements {
        var requirements = VkMemoryRequirements()
        vkGetBufferMemoryRequirements(self.device, buffer.buffer, &requirements)
        return requirements
    }

    /// Allocate device memory.
    /// - Parameter allocateInfo: The memory allocation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the allocated memory.
    func allocateMemory(_ allocateInfo: inout VkMemoryAllocateInfo) throws -> VulkanOwnedDeviceMemory {
        var memory: VkDeviceMemory?
        try check(vkAllocateMemory(self.device, &allocateInfo, nil, &memory))
        return VulkanOwnedDeviceMemory(device: self.device, memory: memory!)
    }

    /// Bind buffer memory.
    /// - Parameters:
    ///   - buffer: The buffer to bind.
    ///   - memory: The memory to bind.
    ///   - offset: The offset into the memory allocation.
    /// - Throws: Any error raised by Vulkan.
    func bindBufferMemory(buffer: VulkanOwnedBuffer, memory: VulkanOwnedDeviceMemory, offset: VkDeviceSize = 0) throws {
        try check(vkBindBufferMemory(self.device, buffer.buffer, memory.memory, offset))
    }

    /// Map device memory.
    /// - Parameters:
    ///   - memory: The memory to map.
    ///   - offset: The offset into the memory allocation.
    ///   - size: The size of the mapped range.
    ///   - flags: Mapping flags.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: A pointer to the mapped memory.
    func mapMemory(
        _ memory: VulkanOwnedDeviceMemory,
        offset: VkDeviceSize = 0,
        size: VkDeviceSize = VkDeviceSize.max,
        flags: VkMemoryMapFlags = 0
    ) throws -> UnsafeMutableRawPointer {
        var data: UnsafeMutableRawPointer?
        try check(vkMapMemory(self.device, memory.memory, offset, size, flags, &data))
        return data!
    }

    /// Unmap device memory.
    /// - Parameter memory: The memory to unmap.
    func unmapMemory(_ memory: VulkanOwnedDeviceMemory) {
        vkUnmapMemory(self.device, memory.memory)
    }

    /// Flush mapped memory ranges.
    /// - Parameter ranges: The memory ranges to flush.
    /// - Throws: Any error raised by Vulkan.
    func flushMappedMemoryRanges(_ ranges: [VkMappedMemoryRange]) throws {
        try ranges.withUnsafeBufferPointer { buffer in
            try check(vkFlushMappedMemoryRanges(self.device, UInt32(buffer.count), buffer.baseAddress))
        }
    }

    /// Invalidate mapped memory ranges.
    /// - Parameter ranges: The memory ranges to invalidate.
    /// - Throws: Any error raised by Vulkan.
    func invalidateMappedMemoryRanges(_ ranges: [VkMappedMemoryRange]) throws {
        try ranges.withUnsafeBufferPointer { buffer in
            try check(vkInvalidateMappedMemoryRanges(self.device, UInt32(buffer.count), buffer.baseAddress))
        }
    }

    /// Create an image view.
    /// - Parameter createInfo: The image view creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created image view.
    func createImageView(_ createInfo: inout VkImageViewCreateInfo) throws -> VulkanOwnedImageView {
        var imageView: VkImageView?
        try check(vkCreateImageView(self.device, &createInfo, nil, &imageView))
        return VulkanOwnedImageView(device: self.device, imageView: imageView!)
    }
}
