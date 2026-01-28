import Vulkan

/// Represents an owned Vulkan shader module.
public final class VulkanOwnedShaderModule {
    public let shaderModule: VkShaderModule
    private let device: VkDevice

    public init(device: VkDevice, shaderModule: VkShaderModule) {
        self.device = device
        self.shaderModule = shaderModule
    }

    deinit {
        vkDestroyShaderModule(self.device, self.shaderModule, nil)
    }
}

public extension VulkanDevice {
    /// Create a shader module from SPIR-V code.
    /// - Parameters:
    ///   - code: The SPIR-V code as an array of 32-bit words.
    ///   - flags: The shader module creation flags.
    /// - Throws: Any error raised by Vulkan.
    /// - Returns: An owning handle to the created shader module.
    func createShaderModule(code: [UInt32], flags: VkShaderModuleCreateFlags = 0) throws -> VulkanOwnedShaderModule {
        var shaderModule: VkShaderModule?
        try code.withUnsafeBufferPointer { buffer in
            var createInfo = VkShaderModuleCreateInfo.create(
                flags: flags,
                codeSize: buffer.count * MemoryLayout<UInt32>.size,
                pCode: buffer.baseAddress!
            )
            try check(vkCreateShaderModule(self.device, &createInfo, nil, &shaderModule))
        }
        return VulkanOwnedShaderModule(device: self.device, shaderModule: shaderModule!)
    }
}
