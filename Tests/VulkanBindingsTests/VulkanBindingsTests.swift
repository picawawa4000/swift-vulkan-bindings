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

    // Create an instance.
    // Since this is Swift (and therefore more likely to run on a Mac),
    // this `if` macro is very important.
#if os(macOS)
    let instance = try VulkanOwnedInstance(
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

    // Get the physical devices.
    let physicalDevices = try instance.enumeratePhysicalDevices()
    print("Found \(physicalDevices.count) physical devices")

    // It doesn't take that many steps to turn this loop into a suitability check.
    for physicalDevice in physicalDevices {
        let properties = physicalDevice.getProperties()
        // Prints as a tuple of ints because I don't know how to convert this into a string
        // Python `chr()` for the win, I guess
        print(" - \(properties.deviceName)")

        let features = physicalDevice.getFeatures()
        print("   - Tessellation shader support: \(features.tessellationShader)")
    }
}
