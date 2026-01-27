# Vulkan Shaders

This directory contains GLSL shader source files for the Vulkan backend.

## Shader Files

- `simple.vert` - Vertex shader for rendering gamut points
- `simple.frag` - Fragment shader for color output

## Compilation

To compile these shaders to SPIR-V bytecode, use `glslc` (from the Vulkan SDK):

```bash
glslc simple.vert -o simple.vert.spv
glslc simple.frag -o simple.frag.spv
```

Or use `glslangValidator`:

```bash
glslangValidator -V simple.vert -o simple.vert.spv
glslangValidator -V simple.frag -o simple.frag.spv
```

## Integration

The compiled SPIR-V files should be loaded at runtime in `VulkanBackend.m` using `vkCreateShaderModule`.
