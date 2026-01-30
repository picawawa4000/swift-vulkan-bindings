import Foundation
import Testing
import Vulkan
@testable import VulkanBindings

@Test func triangleExampleOffscreen() throws {
    // Minimal triangle example that renders into an offscreen image.
    // Requires SPIR-V shader binaries pointed to by environment variables.
    guard
        let vertPath = ProcessInfo.processInfo.environment["VULKAN_TRIANGLE_VERT_SPV"],
        let fragPath = ProcessInfo.processInfo.environment["VULKAN_TRIANGLE_FRAG_SPV"]
    else {
        print("Skipping triangle example: set VULKAN_TRIANGLE_VERT_SPV and VULKAN_TRIANGLE_FRAG_SPV.")
        return
    }

    let vertCode = try loadSpirvWords(from: vertPath)
    let fragCode = try loadSpirvWords(from: fragPath)

#if DEBUG
    let validationLayers = ["VK_LAYER_KHRONOS_validation"]
#else
    let validationLayers: [String] = []
#endif

    var extensions = [VK_KHR_SHADER_DRAW_PARAMETERS_EXTENSION_NAME]
#if os(macOS)
    extensions.append(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME)
    let instance = try VulkanOwnedInstance(
        flags: [.enumeratePortability],
        enabledLayers: validationLayers,
        enabledExtensions: extensions,
        appName: "VulkanBindingsTriangle",
        appVersion: 1,
        engineName: nil,
        engineVersion: nil,
        apiVersion: VulkanAPIVersion.v1_3.rawValue
    )
#else
    let instance = try VulkanOwnedInstance(
        flags: [],
        enabledLayers: validationLayers,
        enabledExtensions: extensions,
        appName: "VulkanBindingsTriangle",
        appVersion: 1,
        engineName: nil,
        engineVersion: nil,
        apiVersion: VulkanAPIVersion.v1_3.rawValue
    )
#endif

    let physicalDevices = try instance.enumeratePhysicalDevices()
    guard let physicalDevice = physicalDevices.first else {
        print("Skipping triangle example: no Vulkan physical devices found.")
        return
    }

    let queueFamilyIndex = try findGraphicsQueueFamilyIndex(physicalDevice)
    let queuePriority: Float = 1.0
    let queueCreateInfo = withUnsafePointer(to: queuePriority) { prioritiesPtr in
        VkDeviceQueueCreateInfo.create(
            flags: 0,
            queueFamilyIndex: queueFamilyIndex,
            queueCount: 1,
            pQueuePriorities: prioritiesPtr
        )
    }

    let device = try physicalDevice.createDevice(queueCreateInfos: [queueCreateInfo])
    let queue = device.getQueue(familyIndex: queueFamilyIndex, queueIndex: 0)

    let commandPool = try device.createCommandPool(queueFamilyIndex: queueFamilyIndex)
    let commandBuffer = try device.allocateCommandBuffers(from: commandPool, count: 1).first!

    let extent = VkExtent2D(width: 256, height: 256)
    let imageFormat = VK_FORMAT_R8G8B8A8_UNORM
    var imageCreateInfo = VkImageCreateInfo.create(
        flags: 0,
        imageType: VK_IMAGE_TYPE_2D,
        format: imageFormat,
        extent: VkExtent3D(width: extent.width, height: extent.height, depth: 1),
        mipLevels: 1,
        arrayLayers: 1,
        samples: VK_SAMPLE_COUNT_1_BIT,
        tiling: VK_IMAGE_TILING_OPTIMAL,
        usage: VkImageUsageFlags(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue),
        sharingMode: VK_SHARING_MODE_EXCLUSIVE,
        queueFamilyIndexCount: 0,
        pQueueFamilyIndices: nil,
        initialLayout: VK_IMAGE_LAYOUT_UNDEFINED
    )
    let colorImage = try device.createImage(&imageCreateInfo)
    let imageRequirements = device.getImageMemoryRequirements(colorImage)
    let memoryTypeIndex = try findMemoryTypeIndex(
        physicalDevice,
        typeBits: imageRequirements.memoryTypeBits,
        properties: VkMemoryPropertyFlags(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT.rawValue)
    )
    var imageMemoryAllocateInfo = VkMemoryAllocateInfo.create(
        allocationSize: imageRequirements.size,
        memoryTypeIndex: memoryTypeIndex
    )
    let imageMemory = try device.allocateMemory(&imageMemoryAllocateInfo)
    try device.bindImageMemory(image: colorImage, memory: imageMemory)

    let components = VkComponentMapping(
        r: VK_COMPONENT_SWIZZLE_IDENTITY,
        g: VK_COMPONENT_SWIZZLE_IDENTITY,
        b: VK_COMPONENT_SWIZZLE_IDENTITY,
        a: VK_COMPONENT_SWIZZLE_IDENTITY
    )
    let subresourceRange = VkImageSubresourceRange(
        aspectMask: VkImageAspectFlags(VK_IMAGE_ASPECT_COLOR_BIT.rawValue),
        baseMipLevel: 0,
        levelCount: 1,
        baseArrayLayer: 0,
        layerCount: 1
    )
    var imageViewCreateInfo = VkImageViewCreateInfo.create(
        flags: 0,
        image: colorImage.image,
        viewType: VK_IMAGE_VIEW_TYPE_2D,
        format: imageFormat,
        components: components,
        subresourceRange: subresourceRange
    )
    let colorImageView = try device.createImageView(&imageViewCreateInfo)

    var colorAttachment = VkAttachmentDescription(
        flags: 0,
        format: imageFormat,
        samples: VK_SAMPLE_COUNT_1_BIT,
        loadOp: VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        storeOp: VK_ATTACHMENT_STORE_OP_STORE,
        stencilLoadOp: VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        stencilStoreOp: VK_ATTACHMENT_STORE_OP_DONT_CARE,
        initialLayout: VK_IMAGE_LAYOUT_UNDEFINED,
        finalLayout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    )
    var colorAttachmentRef = VkAttachmentReference(
        attachment: 0,
        layout: VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    )
    let renderPass: VulkanOwnedRenderPass = try withUnsafePointer(to: &colorAttachment) { attachmentPtr in
        try withUnsafePointer(to: &colorAttachmentRef) { colorRefPtr in
            var subpass = VkSubpassDescription(
                flags: 0,
                pipelineBindPoint: VK_PIPELINE_BIND_POINT_GRAPHICS,
                inputAttachmentCount: 0,
                pInputAttachments: nil,
                colorAttachmentCount: 1,
                pColorAttachments: colorRefPtr,
                pResolveAttachments: nil,
                pDepthStencilAttachment: nil,
                preserveAttachmentCount: 0,
                pPreserveAttachments: nil
            )
            return try withUnsafePointer(to: &subpass) { subpassPtr in
                var renderPassCreateInfo = VkRenderPassCreateInfo.create(
                    flags: 0,
                    attachmentCount: 1,
                    pAttachments: attachmentPtr,
                    subpassCount: 1,
                    pSubpasses: subpassPtr,
                    dependencyCount: 0,
                    pDependencies: nil
                )
                return try device.createRenderPass(&renderPassCreateInfo)
            }
        }
    }

    let imageViewRefs: [VkImageView?] = [colorImageView.imageView]
    let framebuffer: VulkanOwnedFramebuffer = try imageViewRefs.withUnsafeBufferPointer { imageViewPtr in
        var framebufferCreateInfo = VkFramebufferCreateInfo.create(
            flags: 0,
            renderPass: renderPass.renderPass,
            attachmentCount: 1,
            pAttachments: imageViewPtr.baseAddress,
            width: extent.width,
            height: extent.height,
            layers: 1
        )
        return try device.createFramebuffer(&framebufferCreateInfo)
    }

    let vertModule = try device.createShaderModule(code: vertCode)
    let fragModule = try device.createShaderModule(code: fragCode)

    var pipelineLayoutCreateInfo = VkPipelineLayoutCreateInfo.create(
        flags: 0,
        setLayoutCount: 0,
        pSetLayouts: nil,
        pushConstantRangeCount: 0,
        pPushConstantRanges: nil
    )
    let pipelineLayout = try device.createPipelineLayout(&pipelineLayoutCreateInfo)

    let entryPoint = OwnedCString("main")
    var shaderStages = [
        VkPipelineShaderStageCreateInfo(
            sType: VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            pNext: nil,
            flags: 0,
            stage: VK_SHADER_STAGE_VERTEX_BIT,
            module: vertModule.shaderModule,
            pName: entryPoint.rawString,
            pSpecializationInfo: nil
        ),
        VkPipelineShaderStageCreateInfo(
            sType: VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            pNext: nil,
            flags: 0,
            stage: VK_SHADER_STAGE_FRAGMENT_BIT,
            module: fragModule.shaderModule,
            pName: entryPoint.rawString,
            pSpecializationInfo: nil
        )
    ]

    var vertexInput = VkPipelineVertexInputStateCreateInfo(
        sType: VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        pNext: nil,
        flags: 0,
        vertexBindingDescriptionCount: 0,
        pVertexBindingDescriptions: nil,
        vertexAttributeDescriptionCount: 0,
        pVertexAttributeDescriptions: nil
    )
    var inputAssembly = VkPipelineInputAssemblyStateCreateInfo(
        sType: VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        pNext: nil,
        flags: 0,
        topology: VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
        primitiveRestartEnable: VK_FALSE
    )
    var viewport = VkViewport(
        x: 0,
        y: 0,
        width: Float(extent.width),
        height: Float(extent.height),
        minDepth: 0,
        maxDepth: 1
    )
    var scissor = VkRect2D(
        offset: VkOffset2D(x: 0, y: 0),
        extent: extent
    )
    var viewportState = VkPipelineViewportStateCreateInfo(
        sType: VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        pNext: nil,
        flags: 0,
        viewportCount: 1,
        pViewports: nil,
        scissorCount: 1,
        pScissors: nil
    )
    var rasterization = VkPipelineRasterizationStateCreateInfo(
        sType: VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        pNext: nil,
        flags: 0,
        depthClampEnable: VK_FALSE,
        rasterizerDiscardEnable: VK_FALSE,
        polygonMode: VK_POLYGON_MODE_FILL,
        cullMode: VkCullModeFlags(VK_CULL_MODE_BACK_BIT.rawValue),
        frontFace: VK_FRONT_FACE_COUNTER_CLOCKWISE,
        depthBiasEnable: VK_FALSE,
        depthBiasConstantFactor: 0,
        depthBiasClamp: 0,
        depthBiasSlopeFactor: 0,
        lineWidth: 1
    )
    var multisample = VkPipelineMultisampleStateCreateInfo(
        sType: VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        pNext: nil,
        flags: 0,
        rasterizationSamples: VK_SAMPLE_COUNT_1_BIT,
        sampleShadingEnable: VK_FALSE,
        minSampleShading: 1,
        pSampleMask: nil,
        alphaToCoverageEnable: VK_FALSE,
        alphaToOneEnable: VK_FALSE
    )
    var colorBlendAttachment = VkPipelineColorBlendAttachmentState(
        blendEnable: VK_FALSE,
        srcColorBlendFactor: VK_BLEND_FACTOR_ONE,
        dstColorBlendFactor: VK_BLEND_FACTOR_ZERO,
        colorBlendOp: VK_BLEND_OP_ADD,
        srcAlphaBlendFactor: VK_BLEND_FACTOR_ONE,
        dstAlphaBlendFactor: VK_BLEND_FACTOR_ZERO,
        alphaBlendOp: VK_BLEND_OP_ADD,
        colorWriteMask: VkColorComponentFlags(
            VK_COLOR_COMPONENT_R_BIT.rawValue |
            VK_COLOR_COMPONENT_G_BIT.rawValue |
            VK_COLOR_COMPONENT_B_BIT.rawValue |
            VK_COLOR_COMPONENT_A_BIT.rawValue
        )
    )
    var colorBlend = VkPipelineColorBlendStateCreateInfo(
        sType: VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        pNext: nil,
        flags: 0,
        logicOpEnable: VK_FALSE,
        logicOp: VK_LOGIC_OP_COPY,
        attachmentCount: 1,
        pAttachments: nil,
        blendConstants: (0, 0, 0, 0)
    )
    let pipeline: VulkanOwnedPipeline = try shaderStages.withUnsafeMutableBufferPointer { stagesPtr in
        try withUnsafePointer(to: &vertexInput) { vertexInputPtr in
            try withUnsafePointer(to: &inputAssembly) { inputAssemblyPtr in
                try withUnsafePointer(to: &viewport) { viewportPtr in
                    try withUnsafePointer(to: &scissor) { scissorPtr in
                        viewportState.pViewports = viewportPtr
                        viewportState.pScissors = scissorPtr
                        return try withUnsafePointer(to: &viewportState) { viewportStatePtr in
                            try withUnsafePointer(to: &rasterization) { rasterizationPtr in
                                try withUnsafePointer(to: &multisample) { multisamplePtr in
                                    try withUnsafePointer(to: &colorBlendAttachment) { colorBlendAttachmentPtr in
                                        colorBlend.pAttachments = colorBlendAttachmentPtr
                                        return try withUnsafePointer(to: &colorBlend) { colorBlendPtr in
                                            var graphicsPipelineCreateInfo = VkGraphicsPipelineCreateInfo(
                                                sType: VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
                                                pNext: nil,
                                                flags: 0,
                                                stageCount: UInt32(stagesPtr.count),
                                                pStages: stagesPtr.baseAddress,
                                                pVertexInputState: vertexInputPtr,
                                                pInputAssemblyState: inputAssemblyPtr,
                                                pTessellationState: nil,
                                                pViewportState: viewportStatePtr,
                                                pRasterizationState: rasterizationPtr,
                                                pMultisampleState: multisamplePtr,
                                                pDepthStencilState: nil,
                                                pColorBlendState: colorBlendPtr,
                                                pDynamicState: nil,
                                                layout: pipelineLayout.pipelineLayout,
                                                renderPass: renderPass.renderPass,
                                                subpass: 0,
                                                basePipelineHandle: nil,
                                                basePipelineIndex: 0
                                            )
                                            return try device.createGraphicsPipeline(createInfo: &graphicsPipelineCreateInfo)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    try commandBuffer.begin()
    var renderPassBeginInfo = VkRenderPassBeginInfo(
        sType: VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        pNext: nil,
        renderPass: renderPass.renderPass,
        framebuffer: framebuffer.framebuffer,
        renderArea: VkRect2D(offset: VkOffset2D(x: 0, y: 0), extent: extent),
        clearValueCount: 0,
        pClearValues: nil
    )
    commandBuffer.beginRenderPass(renderPassBeginInfo: &renderPassBeginInfo, contents: VK_SUBPASS_CONTENTS_INLINE)
    commandBuffer.bindPipeline(bindPoint: VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline: pipeline.pipeline)
    commandBuffer.draw(vertexCount: 3)
    commandBuffer.endRenderPass()
    try commandBuffer.end()

    let fence = try device.createFence()
    var commandBufferOptional: VkCommandBuffer? = commandBuffer.commandBuffer
    try withUnsafePointer(to: &commandBufferOptional) { commandBufferPtr in
        let submitInfo = VkSubmitInfo.create(
            waitSemaphoreCount: 0,
            pWaitSemaphores: nil,
            pWaitDstStageMask: nil,
            commandBufferCount: 1,
            pCommandBuffers: commandBufferPtr,
            signalSemaphoreCount: 0,
            pSignalSemaphores: nil
        )
        try device.submit(queue: queue, submits: [submitInfo], fence: fence.fence)
    }
    try device.waitForFences([fence.fence], waitAll: true, timeout: UInt64.max)
}

private enum TriangleExampleError: Error {
    case invalidSpirvData
    case missingQueueFamily
    case missingMemoryType
}

private func loadSpirvWords(from path: String) throws -> [UInt32] {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    if data.count % MemoryLayout<UInt32>.size != 0 {
        throw TriangleExampleError.invalidSpirvData
    }
    return data.withUnsafeBytes { rawBuffer in
        let wordBuffer = rawBuffer.bindMemory(to: UInt32.self)
        return Array(wordBuffer)
    }
}

private func findGraphicsQueueFamilyIndex(_ physicalDevice: VulkanPhysicalDevice) throws -> UInt32 {
    let queueFamilies = physicalDevice.getQueueFamilyProperties()
    for (index, family) in queueFamilies.enumerated() {
        if (family.queueFlags & VkQueueFlags(VK_QUEUE_GRAPHICS_BIT.rawValue)) != 0 {
            return UInt32(index)
        }
    }
    throw TriangleExampleError.missingQueueFamily
}

private func findMemoryTypeIndex(
    _ physicalDevice: VulkanPhysicalDevice,
    typeBits: UInt32,
    properties: VkMemoryPropertyFlags
) throws -> UInt32 {
    let memoryProperties = physicalDevice.getMemoryProperties()
    let count = Int(memoryProperties.memoryTypeCount)
    return try withUnsafePointer(to: memoryProperties.memoryTypes) { typesPtr in
        let rawPtr = UnsafeRawPointer(typesPtr).bindMemory(to: VkMemoryType.self, capacity: count)
        for index in 0..<count {
            let type = rawPtr[index]
            let typeSupported = (typeBits & (1 << index)) != 0
            let hasProperties = (type.propertyFlags & properties) == properties
            if typeSupported && hasProperties {
                return UInt32(index)
            }
        }
        throw TriangleExampleError.missingMemoryType
    }
}
