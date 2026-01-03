import Testing
import Vulkan
@testable import VulkanBindings

@Test func example() async throws {
    // API demonstration; not really a test
#if DEBUG
    let validationLayers = ["VK_LAYER_KHRONOS_validation"]
#else
    let validationLayers = []
#endif

#if os(macOS)
    let instance = try OwnedVulkanInstance(
        flags: [.enumeratePortability],
        enabledLayers: validationLayers,
        enabledExtensions: [VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME]
    )
#else
    let instance = try OwnedVulkanInstance(
        flags: [],
        enabledLayers: validationLayers,
        enabledExtensions: []
    )
#endif
}
