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