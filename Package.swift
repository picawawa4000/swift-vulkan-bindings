// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VulkanBindings",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Vulkan",
            targets: ["Vulkan"]
        ),
        .library(
            name: "VulkanBindings",
            targets: ["VulkanBindings"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .systemLibrary(
            name: "Vulkan",
            pkgConfig: "vulkan",
            providers: [
                .apt(["libvulkan-dev"]),
                .brew(["vulkan-loader"])
            ]
        ),
        .target(
            name: "VulkanBindings",
            dependencies: ["Vulkan"]
        ),
        .testTarget(
            name: "VulkanBindingsTests",
            dependencies: ["VulkanBindings"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-rpath",
                    "-Xlinker", "/usr/local/lib"
                ])
            ]
        ),
    ]
)
