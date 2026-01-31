import Foundation
import Vulkan

enum VulkanError: Error {
    case result(VkResult)
}

/// Represents a Vulkan API version with helpers to compute raw values.
public struct VulkanAPIVersion: Sendable {
    public let variant: UInt32
    public let major: UInt32
    public let minor: UInt32
    public let patch: UInt32

    public init(variant: UInt32 = 0, major: UInt32, minor: UInt32, patch: UInt32 = 0) {
        self.variant = variant
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Raw Vulkan API version value, equivalent to VK_MAKE_API_VERSION.
    public var rawValue: UInt32 {
        return (variant << 29) | (major << 22) | (minor << 12) | patch
    }

    public static let v1_0 = VulkanAPIVersion(variant: 0, major: 1, minor: 0, patch: 0)
    public static let v1_1 = VulkanAPIVersion(variant: 0, major: 1, minor: 1, patch: 0)
    public static let v1_2 = VulkanAPIVersion(variant: 0, major: 1, minor: 2, patch: 0)
    public static let v1_3 = VulkanAPIVersion(variant: 0, major: 1, minor: 3, patch: 0)
}

@inline(__always) func check(_ result: VkResult) throws {
    if result != VK_SUCCESS {
        throw VulkanError.result(result)
    }
}

// Public-API alias for `check` with the same behaviour; that is, throws if the result is not VK_SUCCESS.
@inline(__always) public func vulkanResultCheck(_ result: VkResult) throws {
    if result != VK_SUCCESS {
        throw VulkanError.result(result)
    }
}

final class OwnedCString {
    let rawString: UnsafePointer<CChar>

    init(_ string: String?) {
        self.rawString = UnsafePointer<CChar>(strdup(string))
    }

    deinit {
        free(UnsafeMutablePointer(mutating: rawString))
    }
}

/// Applies the given function to the argument array, converting the arguments to C strings first.
/// - Parameters:
///   - strings: The string array to convert to C strings before calling the body.
///   - body: The function that expects C strings as a Swift array.
func withCStrings(_ strings: [String], _ body: ([UnsafePointer<CChar>?]) throws -> Void) rethrows {
    try strings.map { strdup($0) }.withUnsafeBufferPointer { buffer in
        defer { buffer.forEach { free(UnsafeMutablePointer(mutating: $0)) } }
        try body(buffer.map { UnsafePointer($0) })
    }
}

/// Applies the given function to the argument array, converting the arguments to C strings first.
/// Unlike `withCStrings(_:_:)`, uses the pointer-and-size format expected by many Vulkan structs.
/// - Parameters:
///   - strings: The string array to convert to C strings before calling the body.
///   - body: The function that expects C strings, in the count-and-pointer format.
func withCStringsPointerAndSize(_ strings: [String], _ body: (UnsafeBufferPointer<UnsafeMutablePointer<CChar>?>, UInt32) throws -> Void) rethrows {
    try strings.map { strdup($0) }.withUnsafeBufferPointer { buffer in
        defer { buffer.forEach { free(UnsafeMutablePointer(mutating: $0)) } }
        try body(buffer, UInt32(strings.count))
    }
}
