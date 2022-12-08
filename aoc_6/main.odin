package aoc_6

import "core:fmt"
import "core:strings"
import "core:slice"
import "core:mem"

main :: proc(){
    main_p2()
}

main_p1 :: proc(){
    input := #load("input.txt")
    view := input[:4]
    val:=0
    for i in 0..<len(input) {
        if view[0] != view[1] && view[0] != view[2] && view[0] != view[3] &&
           view[1] != view[2] && view[1] != view[3] &&
           view[2] != view[3] {
            val=i
            break
        }
        shift_slice_by_one(&view)
    }

    shift_slice_by_one :: proc(val: ^[]$E) {
        length := len(val)
        new_slice := mem.ptr_offset(slice.as_ptr(val^), 1)[:length]
        val^ = new_slice
    }

    fmt.println(val+4)
}

main_p1_v2 :: proc(){
    input := #load("input.txt")
    val:=0
    for i in 0..<len(input) {
        view := input[i:]
        if view[0] != view[1] && view[0] != view[2] && view[0] != view[3] &&
           view[1] != view[2] && view[1] != view[3] &&
           view[2] != view[3] {
            val=i
            break
        }
    }

    fmt.println(val+4)
}

main_p2 :: proc(){
    input := #load("input.txt")
    val := 0
    set := make(map[u8]struct{}, 14)
    for i in 0..<len(input)-13 {
        view := input[i:i+14]
        for j in 0..<14 {
            set[view[j]] = {}
        }
        if len(set)==14 {
           val = i 
           break
        }
        clear(&set)
    }

    fmt.println(val+14)
}