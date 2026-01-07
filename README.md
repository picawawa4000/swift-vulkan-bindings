# VulkanBindings: Basic Vulkan bindings and wrappers for Swift

The goal of this project is not to create wrappers for every Vulkan type there is, but rather to create easy-to-use wrappers for the most commonly-used Vulkan types.

## Usage

To use this library, add the following code to the `dependencies` section of your `Package.swift` file:

```Swift
.package(url: "https://github.com/picawawa4000/swift-vulkan-bindings.git", branch: "main")
```

If you are writing an executable, you must ensure that the Vulkan dynamic library is in a place where the loader can find it.

This library exposes wrappers in the module `VulkanBindings`. The Vulkan C api is also exposed by this library and can be accessed via the module `Vulkan`.

## Currently wrapped types

See `NAMES.md` for the complete list of wrapped functions and types, along with the name of the function or class that wraps them.
