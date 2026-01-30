import Vulkan

public extension VkInstanceCreateInfo {
    /// Creates a new `VkInstanceCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the instance.
    ///   - pApplicationInfo: A pointer to info about the application. May be null.
    ///   - enabledLayerCount: The number of enabled layers (i.e. the size of the array at `ppEnabledLayerNames`).
    ///   - ppEnabledLayerNames: The enabled layers, as a pointer to an array of C strings.
    ///   - enabledExtensionCount: The number of enabled extensions.
    ///   - ppEnabledExtensionNames: The enabled extensions, with the same format as `ppEnabledLayerNames`.
    /// - Returns: A `VkInstanceCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkInstanceCreateFlags,
        pApplicationInfo: UnsafePointer<VkApplicationInfo>!,
        enabledLayerCount: UInt32,
        ppEnabledLayerNames: UnsafePointer<UnsafePointer<CChar>?>!,
        enabledExtensionCount: UInt32,
        ppEnabledExtensionNames: UnsafePointer<UnsafePointer<CChar>?>!
    ) -> VkInstanceCreateInfo {
        return VkInstanceCreateInfo(
            sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            pNext: nil,
            flags: flags,
            pApplicationInfo: pApplicationInfo,
            enabledLayerCount: enabledLayerCount,
            ppEnabledLayerNames: ppEnabledLayerNames,
            enabledExtensionCount: enabledExtensionCount,
            ppEnabledExtensionNames: ppEnabledExtensionNames
        )
    }
}

public extension VkApplicationInfo {
    /// Creates a new `VkApplicationInfo`.
    /// - Parameters:
    ///   - pApplicationName: The name of this application.
    ///   - applicationVersion: The version of this application.
    ///   - pEngineName: The name of the engine used by this application.
    ///   - engineVersion: The version of the engine used by this application.
    ///   - apiVersion: The maximum version of the Vulkan API used by this application.
    /// - Returns: A `VkApplicationInfo` structure encoding all of the above information.
    static func create(
        pApplicationName: UnsafePointer<CChar>,
        applicationVersion: UInt32,
        pEngineName: UnsafePointer<CChar>,
        engineVersion: UInt32,
        apiVersion: UInt32
    ) -> VkApplicationInfo {
        return VkApplicationInfo(
            sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
            pNext: nil,
            pApplicationName: pApplicationName,
            applicationVersion: applicationVersion,
            pEngineName: pEngineName,
            engineVersion: engineVersion,
            apiVersion: apiVersion
        )
    }
}

public extension VkDeviceQueueCreateInfo {
    /// Creates a new `VkDeviceQueueCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the queue.
    ///   - queueFamilyIndex: The queue family index.
    ///   - queueCount: The number of queues to create (must match the count of `pQueuePriorities`).
    ///   - pQueuePriorities: A pointer to an array of queue priorities.
    /// - Returns: A `VkDeviceQueueCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkDeviceQueueCreateFlags,
        queueFamilyIndex: UInt32,
        queueCount: UInt32,
        pQueuePriorities: UnsafePointer<Float>
    ) -> VkDeviceQueueCreateInfo {
        return VkDeviceQueueCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            pNext: nil,
            flags: flags,
            queueFamilyIndex: queueFamilyIndex,
            queueCount: queueCount,
            pQueuePriorities: pQueuePriorities
        )
    }
}

public extension VkDeviceCreateInfo {
    /// Creates a new `VkDeviceCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the device.
    ///   - queueCreateInfoCount: The number of queue create infos.
    ///   - pQueueCreateInfos: A pointer to an array of queue create infos.
    ///   - enabledLayerCount: The number of enabled layers.
    ///   - ppEnabledLayerNames: The enabled layer names as C strings.
    ///   - enabledExtensionCount: The number of enabled extensions.
    ///   - ppEnabledExtensionNames: The enabled extension names as C strings.
    ///   - pEnabledFeatures: The enabled physical device features. May be null.
    /// - Returns: A `VkDeviceCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkDeviceCreateFlags,
        queueCreateInfoCount: UInt32,
        pQueueCreateInfos: UnsafePointer<VkDeviceQueueCreateInfo>?,
        enabledLayerCount: UInt32,
        ppEnabledLayerNames: UnsafePointer<UnsafePointer<CChar>?>!,
        enabledExtensionCount: UInt32,
        ppEnabledExtensionNames: UnsafePointer<UnsafePointer<CChar>?>!,
        pEnabledFeatures: UnsafePointer<VkPhysicalDeviceFeatures>?
    ) -> VkDeviceCreateInfo {
        return VkDeviceCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            pNext: nil,
            flags: flags,
            queueCreateInfoCount: queueCreateInfoCount,
            pQueueCreateInfos: pQueueCreateInfos,
            enabledLayerCount: enabledLayerCount,
            ppEnabledLayerNames: ppEnabledLayerNames,
            enabledExtensionCount: enabledExtensionCount,
            ppEnabledExtensionNames: ppEnabledExtensionNames,
            pEnabledFeatures: pEnabledFeatures
        )
    }
}

public extension VkCommandPoolCreateInfo {
    /// Creates a new `VkCommandPoolCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the command pool.
    ///   - queueFamilyIndex: The queue family index the command buffers will be submitted to.
    /// - Returns: A `VkCommandPoolCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkCommandPoolCreateFlags,
        queueFamilyIndex: UInt32
    ) -> VkCommandPoolCreateInfo {
        return VkCommandPoolCreateInfo(
            sType: VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
            pNext: nil,
            flags: flags,
            queueFamilyIndex: queueFamilyIndex
        )
    }
}

public extension VkCommandBufferAllocateInfo {
    /// Creates a new `VkCommandBufferAllocateInfo`.
    /// - Parameters:
    ///   - commandPool: The pool to allocate from.
    ///   - level: The level of the allocated command buffers.
    ///   - commandBufferCount: The number of command buffers to allocate.
    /// - Returns: A `VkCommandBufferAllocateInfo` structure encoding all of the above information.
    static func create(
        commandPool: VkCommandPool,
        level: VkCommandBufferLevel,
        commandBufferCount: UInt32
    ) -> VkCommandBufferAllocateInfo {
        return VkCommandBufferAllocateInfo(
            sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
            pNext: nil,
            commandPool: commandPool,
            level: level,
            commandBufferCount: commandBufferCount
        )
    }
}

public extension VkCommandBufferBeginInfo {
    /// Creates a new `VkCommandBufferBeginInfo`.
    /// - Parameters:
    ///   - flags: The usage flags for the command buffer.
    ///   - pInheritanceInfo: Optional inheritance info for secondary command buffers.
    /// - Returns: A `VkCommandBufferBeginInfo` structure encoding all of the above information.
    static func create(
        flags: VkCommandBufferUsageFlags,
        pInheritanceInfo: UnsafePointer<VkCommandBufferInheritanceInfo>?
    ) -> VkCommandBufferBeginInfo {
        return VkCommandBufferBeginInfo(
            sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
            pNext: nil,
            flags: flags,
            pInheritanceInfo: pInheritanceInfo
        )
    }
}

public extension VkSemaphoreCreateInfo {
    /// Creates a new `VkSemaphoreCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the semaphore.
    /// - Returns: A `VkSemaphoreCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkSemaphoreCreateFlags
    ) -> VkSemaphoreCreateInfo {
        return VkSemaphoreCreateInfo(
            sType: VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
            pNext: nil,
            flags: flags
        )
    }
}

public extension VkFenceCreateInfo {
    /// Creates a new `VkFenceCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the fence.
    /// - Returns: A `VkFenceCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkFenceCreateFlags
    ) -> VkFenceCreateInfo {
        return VkFenceCreateInfo(
            sType: VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
            pNext: nil,
            flags: flags
        )
    }
}

public extension VkShaderModuleCreateInfo {
    /// Creates a new `VkShaderModuleCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the shader module.
    ///   - codeSize: The size of the shader code in bytes.
    ///   - pCode: Pointer to the SPIR-V code.
    /// - Returns: A `VkShaderModuleCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkShaderModuleCreateFlags,
        codeSize: Int,
        pCode: UnsafePointer<UInt32>
    ) -> VkShaderModuleCreateInfo {
        return VkShaderModuleCreateInfo(
            sType: VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
            pNext: nil,
            flags: flags,
            codeSize: codeSize,
            pCode: pCode
        )
    }
}

public extension VkRenderPassCreateInfo {
    /// Creates a new `VkRenderPassCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the render pass.
    ///   - attachmentCount: The number of attachments.
    ///   - pAttachments: Pointer to attachment descriptions.
    ///   - subpassCount: The number of subpasses.
    ///   - pSubpasses: Pointer to subpass descriptions.
    ///   - dependencyCount: The number of subpass dependencies.
    ///   - pDependencies: Pointer to subpass dependencies.
    /// - Returns: A `VkRenderPassCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkRenderPassCreateFlags,
        attachmentCount: UInt32,
        pAttachments: UnsafePointer<VkAttachmentDescription>?,
        subpassCount: UInt32,
        pSubpasses: UnsafePointer<VkSubpassDescription>?,
        dependencyCount: UInt32,
        pDependencies: UnsafePointer<VkSubpassDependency>?
    ) -> VkRenderPassCreateInfo {
        return VkRenderPassCreateInfo(
            sType: VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
            pNext: nil,
            flags: flags,
            attachmentCount: attachmentCount,
            pAttachments: pAttachments,
            subpassCount: subpassCount,
            pSubpasses: pSubpasses,
            dependencyCount: dependencyCount,
            pDependencies: pDependencies
        )
    }
}

public extension VkFramebufferCreateInfo {
    /// Creates a new `VkFramebufferCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the framebuffer.
    ///   - renderPass: The render pass the framebuffer is compatible with.
    ///   - attachmentCount: The number of attachments.
    ///   - pAttachments: Pointer to attachment image views.
    ///   - width: Framebuffer width.
    ///   - height: Framebuffer height.
    ///   - layers: Framebuffer layers.
    /// - Returns: A `VkFramebufferCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkFramebufferCreateFlags,
        renderPass: VkRenderPass,
        attachmentCount: UInt32,
        pAttachments: UnsafePointer<VkImageView?>?,
        width: UInt32,
        height: UInt32,
        layers: UInt32
    ) -> VkFramebufferCreateInfo {
        return VkFramebufferCreateInfo(
            sType: VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
            pNext: nil,
            flags: flags,
            renderPass: renderPass,
            attachmentCount: attachmentCount,
            pAttachments: pAttachments,
            width: width,
            height: height,
            layers: layers
        )
    }
}

public extension VkPipelineLayoutCreateInfo {
    /// Creates a new `VkPipelineLayoutCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the pipeline layout.
    ///   - setLayoutCount: The number of descriptor set layouts.
    ///   - pSetLayouts: Pointer to descriptor set layouts.
    ///   - pushConstantRangeCount: The number of push constant ranges.
    ///   - pPushConstantRanges: Pointer to push constant ranges.
    /// - Returns: A `VkPipelineLayoutCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkPipelineLayoutCreateFlags,
        setLayoutCount: UInt32,
        pSetLayouts: UnsafePointer<VkDescriptorSetLayout?>?,
        pushConstantRangeCount: UInt32,
        pPushConstantRanges: UnsafePointer<VkPushConstantRange>?
    ) -> VkPipelineLayoutCreateInfo {
        return VkPipelineLayoutCreateInfo(
            sType: VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            pNext: nil,
            flags: flags,
            setLayoutCount: setLayoutCount,
            pSetLayouts: pSetLayouts,
            pushConstantRangeCount: pushConstantRangeCount,
            pPushConstantRanges: pPushConstantRanges
        )
    }
}

public extension VkImageViewCreateInfo {
    /// Creates a new `VkImageViewCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the image view.
    ///   - image: The image to view.
    ///   - viewType: The image view type.
    ///   - format: The image format.
    ///   - components: The component mapping.
    ///   - subresourceRange: The subresource range.
    /// - Returns: A `VkImageViewCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkImageViewCreateFlags,
        image: VkImage,
        viewType: VkImageViewType,
        format: VkFormat,
        components: VkComponentMapping,
        subresourceRange: VkImageSubresourceRange
    ) -> VkImageViewCreateInfo {
        return VkImageViewCreateInfo(
            sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
            pNext: nil,
            flags: flags,
            image: image,
            viewType: viewType,
            format: format,
            components: components,
            subresourceRange: subresourceRange
        )
    }
}

public extension VkSwapchainCreateInfoKHR {
    /// Creates a new `VkSwapchainCreateInfoKHR`.
    /// - Parameters:
    ///   - flags: The flags to use to create the swapchain.
    ///   - surface: The surface to present to.
    ///   - minImageCount: The minimum number of images in the swapchain.
    ///   - imageFormat: The swapchain image format.
    ///   - imageColorSpace: The swapchain image color space.
    ///   - imageExtent: The swapchain image extent.
    ///   - imageArrayLayers: The number of layers per image.
    ///   - imageUsage: The intended image usage.
    ///   - imageSharingMode: The sharing mode for swapchain images.
    ///   - queueFamilyIndexCount: The number of queue families for sharing.
    ///   - pQueueFamilyIndices: Pointer to queue family indices.
    ///   - preTransform: The surface transform to apply.
    ///   - compositeAlpha: The composite alpha mode.
    ///   - presentMode: The presentation mode.
    ///   - clipped: Whether the swapchain is clipped.
    ///   - oldSwapchain: The old swapchain, if any.
    /// - Returns: A `VkSwapchainCreateInfoKHR` structure encoding all of the above information.
    static func create(
        flags: VkSwapchainCreateFlagsKHR,
        surface: VkSurfaceKHR,
        minImageCount: UInt32,
        imageFormat: VkFormat,
        imageColorSpace: VkColorSpaceKHR,
        imageExtent: VkExtent2D,
        imageArrayLayers: UInt32,
        imageUsage: VkImageUsageFlags,
        imageSharingMode: VkSharingMode,
        queueFamilyIndexCount: UInt32,
        pQueueFamilyIndices: UnsafePointer<UInt32>?,
        preTransform: VkSurfaceTransformFlagBitsKHR,
        compositeAlpha: VkCompositeAlphaFlagBitsKHR,
        presentMode: VkPresentModeKHR,
        clipped: VkBool32,
        oldSwapchain: VkSwapchainKHR?
    ) -> VkSwapchainCreateInfoKHR {
        return VkSwapchainCreateInfoKHR(
            sType: VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
            pNext: nil,
            flags: flags,
            surface: surface,
            minImageCount: minImageCount,
            imageFormat: imageFormat,
            imageColorSpace: imageColorSpace,
            imageExtent: imageExtent,
            imageArrayLayers: imageArrayLayers,
            imageUsage: imageUsage,
            imageSharingMode: imageSharingMode,
            queueFamilyIndexCount: queueFamilyIndexCount,
            pQueueFamilyIndices: pQueueFamilyIndices,
            preTransform: preTransform,
            compositeAlpha: compositeAlpha,
            presentMode: presentMode,
            clipped: clipped,
            oldSwapchain: oldSwapchain
        )
    }
}

public extension VkSubmitInfo {
    /// Creates a new `VkSubmitInfo`.
    /// - Parameters:
    ///   - waitSemaphoreCount: The number of semaphores to wait on.
    ///   - pWaitSemaphores: Pointer to wait semaphores.
    ///   - pWaitDstStageMask: Pointer to destination stage masks.
    ///   - commandBufferCount: The number of command buffers.
    ///   - pCommandBuffers: Pointer to command buffers.
    ///   - signalSemaphoreCount: The number of semaphores to signal.
    ///   - pSignalSemaphores: Pointer to signal semaphores.
    /// - Returns: A `VkSubmitInfo` structure encoding all of the above information.
    static func create(
        waitSemaphoreCount: UInt32,
        pWaitSemaphores: UnsafePointer<VkSemaphore?>?,
        pWaitDstStageMask: UnsafePointer<VkPipelineStageFlags>?,
        commandBufferCount: UInt32,
        pCommandBuffers: UnsafePointer<VkCommandBuffer?>?,
        signalSemaphoreCount: UInt32,
        pSignalSemaphores: UnsafePointer<VkSemaphore?>?
    ) -> VkSubmitInfo {
        return VkSubmitInfo(
            sType: VK_STRUCTURE_TYPE_SUBMIT_INFO,
            pNext: nil,
            waitSemaphoreCount: waitSemaphoreCount,
            pWaitSemaphores: pWaitSemaphores,
            pWaitDstStageMask: pWaitDstStageMask,
            commandBufferCount: commandBufferCount,
            pCommandBuffers: pCommandBuffers,
            signalSemaphoreCount: signalSemaphoreCount,
            pSignalSemaphores: pSignalSemaphores
        )
    }
}

public extension VkPresentInfoKHR {
    /// Creates a new `VkPresentInfoKHR`.
    /// - Parameters:
    ///   - waitSemaphoreCount: The number of semaphores to wait on before presenting.
    ///   - pWaitSemaphores: Pointer to wait semaphores.
    ///   - swapchainCount: The number of swapchains.
    ///   - pSwapchains: Pointer to swapchains.
    ///   - pImageIndices: Pointer to image indices.
    ///   - pResults: Optional per-swapchain results.
    /// - Returns: A `VkPresentInfoKHR` structure encoding all of the above information.
    static func create(
        waitSemaphoreCount: UInt32,
        pWaitSemaphores: UnsafePointer<VkSemaphore?>?,
        swapchainCount: UInt32,
        pSwapchains: UnsafePointer<VkSwapchainKHR?>?,
        pImageIndices: UnsafePointer<UInt32>?,
        pResults: UnsafeMutablePointer<VkResult>?
    ) -> VkPresentInfoKHR {
        return VkPresentInfoKHR(
            sType: VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
            pNext: nil,
            waitSemaphoreCount: waitSemaphoreCount,
            pWaitSemaphores: pWaitSemaphores,
            swapchainCount: swapchainCount,
            pSwapchains: pSwapchains,
            pImageIndices: pImageIndices,
            pResults: pResults
        )
    }
}

public extension VkBufferCreateInfo {
    /// Creates a new `VkBufferCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the buffer.
    ///   - size: The buffer size, in bytes.
    ///   - usage: The intended usage of the buffer.
    ///   - sharingMode: The sharing mode for the buffer.
    ///   - queueFamilyIndexCount: The number of queue family indices.
    ///   - pQueueFamilyIndices: Pointer to queue family indices.
    /// - Returns: A `VkBufferCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkBufferCreateFlags,
        size: VkDeviceSize,
        usage: VkBufferUsageFlags,
        sharingMode: VkSharingMode,
        queueFamilyIndexCount: UInt32,
        pQueueFamilyIndices: UnsafePointer<UInt32>?
    ) -> VkBufferCreateInfo {
        return VkBufferCreateInfo(
            sType: VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
            pNext: nil,
            flags: flags,
            size: size,
            usage: usage,
            sharingMode: sharingMode,
            queueFamilyIndexCount: queueFamilyIndexCount,
            pQueueFamilyIndices: pQueueFamilyIndices
        )
    }
}

public extension VkImageCreateInfo {
    /// Creates a new `VkImageCreateInfo`.
    /// - Parameters:
    ///   - flags: The flags to use to create the image.
    ///   - imageType: The image type.
    ///   - format: The image format.
    ///   - extent: The image extent.
    ///   - mipLevels: The number of mip levels.
    ///   - arrayLayers: The number of array layers.
    ///   - samples: The sample count.
    ///   - tiling: The image tiling.
    ///   - usage: The intended image usage.
    ///   - sharingMode: The sharing mode for the image.
    ///   - queueFamilyIndexCount: The number of queue family indices.
    ///   - pQueueFamilyIndices: Pointer to queue family indices.
    ///   - initialLayout: The initial image layout.
    /// - Returns: A `VkImageCreateInfo` structure encoding all of the above information.
    static func create(
        flags: VkImageCreateFlags,
        imageType: VkImageType,
        format: VkFormat,
        extent: VkExtent3D,
        mipLevels: UInt32,
        arrayLayers: UInt32,
        samples: VkSampleCountFlagBits,
        tiling: VkImageTiling,
        usage: VkImageUsageFlags,
        sharingMode: VkSharingMode,
        queueFamilyIndexCount: UInt32,
        pQueueFamilyIndices: UnsafePointer<UInt32>?,
        initialLayout: VkImageLayout
    ) -> VkImageCreateInfo {
        return VkImageCreateInfo(
            sType: VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
            pNext: nil,
            flags: flags,
            imageType: imageType,
            format: format,
            extent: extent,
            mipLevels: mipLevels,
            arrayLayers: arrayLayers,
            samples: samples,
            tiling: tiling,
            usage: usage,
            sharingMode: sharingMode,
            queueFamilyIndexCount: queueFamilyIndexCount,
            pQueueFamilyIndices: pQueueFamilyIndices,
            initialLayout: initialLayout
        )
    }
}

public extension VkMemoryAllocateInfo {
    /// Creates a new `VkMemoryAllocateInfo`.
    /// - Parameters:
    ///   - allocationSize: The size of the allocation in bytes.
    ///   - memoryTypeIndex: The memory type index to allocate from.
    /// - Returns: A `VkMemoryAllocateInfo` structure encoding all of the above information.
    static func create(
        allocationSize: VkDeviceSize,
        memoryTypeIndex: UInt32
    ) -> VkMemoryAllocateInfo {
        return VkMemoryAllocateInfo(
            sType: VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
            pNext: nil,
            allocationSize: allocationSize,
            memoryTypeIndex: memoryTypeIndex
        )
    }
}

public extension VkMappedMemoryRange {
    /// Creates a new `VkMappedMemoryRange`.
    /// - Parameters:
    ///   - memory: The memory object.
    ///   - offset: The offset within the memory object.
    ///   - size: The size of the range to flush/invalidate.
    /// - Returns: A `VkMappedMemoryRange` structure encoding all of the above information.
    static func create(
        memory: VkDeviceMemory,
        offset: VkDeviceSize,
        size: VkDeviceSize
    ) -> VkMappedMemoryRange {
        return VkMappedMemoryRange(
            sType: VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE,
            pNext: nil,
            memory: memory,
            offset: offset,
            size: size
        )
    }
}
