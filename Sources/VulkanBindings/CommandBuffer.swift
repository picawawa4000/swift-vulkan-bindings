import Vulkan

/// Represents an owned Vulkan command pool.
public final class VulkanOwnedCommandPool {
    public let commandPool: VkCommandPool
    private let device: VkDevice

    public init(device: VkDevice, commandPool: VkCommandPool) {
        self.device = device
        self.commandPool = commandPool
    }

    deinit {
        vkDestroyCommandPool(self.device, self.commandPool, nil)
    }
}

/// Represents a Vulkan command buffer.
public struct VulkanCommandBuffer {
    public let commandBuffer: VkCommandBuffer

    public init(commandBuffer: VkCommandBuffer) {
        self.commandBuffer = commandBuffer
    }
}

public extension VulkanCommandBuffer {
    /// Begin recording this command buffer.
    /// - Parameters:
    ///   - flags: Usage flags for the command buffer.
    ///   - inheritanceInfo: Optional inheritance info for secondary command buffers.
    /// - Throws: Any error raised by Vulkan.
    func begin(
        flags: VkCommandBufferUsageFlags = 0,
        inheritanceInfo: UnsafePointer<VkCommandBufferInheritanceInfo>? = nil
    ) throws {
        var beginInfo = VkCommandBufferBeginInfo.create(flags: flags, pInheritanceInfo: inheritanceInfo)
        try check(vkBeginCommandBuffer(self.commandBuffer, &beginInfo))
    }

    /// End recording this command buffer.
    /// - Throws: Any error raised by Vulkan.
    func end() throws {
        try check(vkEndCommandBuffer(self.commandBuffer))
    }

    /// Begin a render pass.
    /// - Parameters:
    ///   - renderPassBeginInfo: The render pass begin info.
    ///   - contents: The subpass contents.
    func beginRenderPass(renderPassBeginInfo: inout VkRenderPassBeginInfo, contents: VkSubpassContents) {
        vkCmdBeginRenderPass(self.commandBuffer, &renderPassBeginInfo, contents)
    }

    /// End the current render pass.
    func endRenderPass() {
        vkCmdEndRenderPass(self.commandBuffer)
    }

    /// Bind a graphics or compute pipeline.
    /// - Parameters:
    ///   - bindPoint: The pipeline bind point.
    ///   - pipeline: The pipeline to bind.
    func bindPipeline(bindPoint: VkPipelineBindPoint, pipeline: VkPipeline) {
        vkCmdBindPipeline(self.commandBuffer, bindPoint, pipeline)
    }

    /// Set viewports.
    /// - Parameter viewports: The viewports to set.
    func setViewports(_ viewports: [VkViewport]) {
        viewports.withUnsafeBufferPointer { buffer in
            vkCmdSetViewport(self.commandBuffer, 0, UInt32(buffer.count), buffer.baseAddress)
        }
    }

    /// Set scissors.
    /// - Parameter scissors: The scissors to set.
    func setScissors(_ scissors: [VkRect2D]) {
        scissors.withUnsafeBufferPointer { buffer in
            vkCmdSetScissor(self.commandBuffer, 0, UInt32(buffer.count), buffer.baseAddress)
        }
    }

    /// Issue a non-indexed draw.
    /// - Parameters:
    ///   - vertexCount: The number of vertices to draw.
    ///   - instanceCount: The number of instances to draw.
    ///   - firstVertex: The first vertex to draw.
    ///   - firstInstance: The first instance to draw.
    func draw(vertexCount: UInt32, instanceCount: UInt32 = 1, firstVertex: UInt32 = 0, firstInstance: UInt32 = 0) {
        vkCmdDraw(self.commandBuffer, vertexCount, instanceCount, firstVertex, firstInstance)
    }
}

public extension VulkanDevice {
    /// Create a command pool.
    /// - Parameters:
    ///   - flags: The command pool creation flags.
    ///   - queueFamilyIndex: The queue family index.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created command pool.
    func createCommandPool(flags: VulkanCommandPoolCreateFlags = [], queueFamilyIndex: UInt32) throws -> VulkanOwnedCommandPool {
        var commandPool: VkCommandPool?
        var createInfo = VkCommandPoolCreateInfo.create(flags: flags.rawValue, queueFamilyIndex: queueFamilyIndex)
        try check(vkCreateCommandPool(self.device, &createInfo, nil, &commandPool))
        return VulkanOwnedCommandPool(device: self.device, commandPool: commandPool!)
    }

    /// Allocate command buffers from a command pool.
    /// - Parameters:
    ///   - commandPool: The command pool to allocate from.
    ///   - level: The command buffer level.
    ///   - count: The number of command buffers to allocate.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: The allocated command buffers.
    func allocateCommandBuffers(
        from commandPool: VulkanOwnedCommandPool,
        level: VkCommandBufferLevel = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        count: UInt32
    ) throws -> [VulkanCommandBuffer] {
        var buffers = Array<VkCommandBuffer?>(repeating: nil, count: Int(count))
        var allocateInfo = VkCommandBufferAllocateInfo.create(
            commandPool: commandPool.commandPool,
            level: level,
            commandBufferCount: count
        )
        try buffers.withUnsafeMutableBufferPointer { buffer in
            try check(vkAllocateCommandBuffers(self.device, &allocateInfo, buffer.baseAddress))
        }
        return buffers.compactMap { $0 }.map { VulkanCommandBuffer(commandBuffer: $0) }
    }

    /// Free command buffers allocated from a command pool.
    /// - Parameters:
    ///   - commandPool: The command pool the command buffers were allocated from.
    ///   - commandBuffers: The command buffers to free.
    func freeCommandBuffers(from commandPool: VulkanOwnedCommandPool, commandBuffers: [VulkanCommandBuffer]) {
        let rawBuffers = commandBuffers.map { $0.commandBuffer }
        rawBuffers.withUnsafeBufferPointer { buffer in
            vkFreeCommandBuffers(self.device, commandPool.commandPool, UInt32(buffer.count), buffer.baseAddress)
        }
    }
}

/// Loosely maps to `VkCommandPoolCreateFlags`.
public struct VulkanCommandPoolCreateFlags: OptionSet, Sendable {
    public let rawValue: VkCommandPoolCreateFlags

    public init(rawValue: VkCommandPoolCreateFlags) {
        self.rawValue = rawValue
    }

    public static let transient = VulkanCommandPoolCreateFlags(rawValue: VK_COMMAND_POOL_CREATE_TRANSIENT_BIT.rawValue)
    public static let resetCommandBuffer = VulkanCommandPoolCreateFlags(rawValue: VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT.rawValue)
}
