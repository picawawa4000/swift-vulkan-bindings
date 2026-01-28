import Vulkan

/// Represents an owned Vulkan render pass.
public final class VulkanOwnedRenderPass {
    public let renderPass: VkRenderPass
    private let device: VkDevice

    public init(device: VkDevice, renderPass: VkRenderPass) {
        self.device = device
        self.renderPass = renderPass
    }

    deinit {
        vkDestroyRenderPass(self.device, self.renderPass, nil)
    }
}

/// Represents an owned Vulkan framebuffer.
public final class VulkanOwnedFramebuffer {
    public let framebuffer: VkFramebuffer
    private let device: VkDevice

    public init(device: VkDevice, framebuffer: VkFramebuffer) {
        self.device = device
        self.framebuffer = framebuffer
    }

    deinit {
        vkDestroyFramebuffer(self.device, self.framebuffer, nil)
    }
}

public extension VulkanDevice {
    /// Create a render pass.
    /// - Parameter createInfo: The render pass creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created render pass.
    func createRenderPass(_ createInfo: inout VkRenderPassCreateInfo) throws -> VulkanOwnedRenderPass {
        var renderPass: VkRenderPass?
        try check(vkCreateRenderPass(self.device, &createInfo, nil, &renderPass))
        return VulkanOwnedRenderPass(device: self.device, renderPass: renderPass!)
    }

    /// Create a framebuffer.
    /// - Parameter createInfo: The framebuffer creation info.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created framebuffer.
    func createFramebuffer(_ createInfo: inout VkFramebufferCreateInfo) throws -> VulkanOwnedFramebuffer {
        var framebuffer: VkFramebuffer?
        try check(vkCreateFramebuffer(self.device, &createInfo, nil, &framebuffer))
        return VulkanOwnedFramebuffer(device: self.device, framebuffer: framebuffer!)
    }
}
