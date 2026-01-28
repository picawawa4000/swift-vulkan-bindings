import Vulkan

/// Represents an owned Vulkan pipeline layout.
public final class VulkanOwnedPipelineLayout {
    public let pipelineLayout: VkPipelineLayout
    private let device: VkDevice

    public init(device: VkDevice, pipelineLayout: VkPipelineLayout) {
        self.device = device
        self.pipelineLayout = pipelineLayout
    }

    deinit {
        vkDestroyPipelineLayout(self.device, self.pipelineLayout, nil)
    }
}

/// Represents an owned Vulkan pipeline.
public final class VulkanOwnedPipeline {
    public let pipeline: VkPipeline
    private let device: VkDevice

    public init(device: VkDevice, pipeline: VkPipeline) {
        self.device = device
        self.pipeline = pipeline
    }

    deinit {
        vkDestroyPipeline(self.device, self.pipeline, nil)
    }
}

public extension VulkanDevice {
    /// Create a pipeline layout.
    /// - Parameter createInfo: The pipeline layout creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created pipeline layout.
    func createPipelineLayout(_ createInfo: inout VkPipelineLayoutCreateInfo) throws -> VulkanOwnedPipelineLayout {
        var pipelineLayout: VkPipelineLayout?
        try check(vkCreatePipelineLayout(self.device, &createInfo, nil, &pipelineLayout))
        return VulkanOwnedPipelineLayout(device: self.device, pipelineLayout: pipelineLayout!)
    }

    /// Create a single graphics pipeline.
    /// - Parameters:
    ///   - cache: The pipeline cache to use, or nil.
    ///   - createInfo: The graphics pipeline creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created pipeline.
    func createGraphicsPipeline(cache: VkPipelineCache? = nil, createInfo: inout VkGraphicsPipelineCreateInfo) throws -> VulkanOwnedPipeline {
        var pipeline: VkPipeline?
        try check(vkCreateGraphicsPipelines(self.device, cache, 1, &createInfo, nil, &pipeline))
        return VulkanOwnedPipeline(device: self.device, pipeline: pipeline!)
    }
}
