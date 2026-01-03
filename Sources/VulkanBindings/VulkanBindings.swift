import Foundation
import Vulkan

enum VulkanError: Error {
    case result(VkResult)
}

@inline(__always) func check(_ result: VkResult) throws {
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