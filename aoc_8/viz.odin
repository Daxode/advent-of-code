package aoc_8

import "vendor:cgltf"
import "vendor:raylib"
import "core:fmt"
import "core:mem"

draw_tree :: proc(x,y: int) {
    idk := #load("untitled.glb")
    data, res := cgltf.parse({}, raw_data(idk), len(idk))
    _=cgltf.load_buffers({},data,data.buffers[0].uri)
    
    for mesh in data.meshes {
        fmt.println(mesh.name)
        for primitive in mesh.primitives {
            for attribute in primitive.attributes {
                attribute_data := attribute.data
                fmt.println(attribute.name)
                buffer_view := attribute_data.buffer_view
                buffer_ptr := mem.ptr_offset(transmute([^]u8)buffer_view.buffer.data, buffer_view.offset)
                raw_slice := buffer_ptr[:buffer_view.size/attribute_data.stride]

                if attribute_data.type == .vec2 && attribute_data.component_type == .r_32f {
                    slice := transmute([][2]f32)raw_slice
                    fmt.println(slice)
                } else if attribute_data.type == .vec3 && attribute_data.component_type == .r_32f {
                    slice := transmute([][3]f32)raw_slice
                    fmt.println(slice)
                }
            }
        }
        fmt.println()
    }

    for node in data.nodes {
        fmt.println(node.translation)
        fmt.println(node.rotation)
    }

}