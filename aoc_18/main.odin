package aoc_18

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:thread"
import rl "vendor:raylib"
import "core:container/bit_array"
import "core:sys/windows"

main :: proc() {
    fmt.println("Day 18")
    main_p1()
    // main_p1_viz()
    main_p2_viz()
}

main_p1 :: proc() {
    input := string(#load("input.txt"))
    voxels, _ := bit_array.create(32*32*32-1)
    for line in strings.split_lines_iterator(&input) {
        line_it := line
        i_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        j_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        k_a := line_it
        i := strconv.atoi(i_a)
        j := strconv.atoi(j_a)
        k := strconv.atoi(k_a)
        index := i*32*32 + j*32 + k
        bit_array.set(voxels, index)
    }
    sum := 0
    voxel_iter := bit_array.make_iterator(voxels)
    for voxel, index in bit_array.iterate_by_all(&voxel_iter) {
        if !voxel {continue}
        dirs := [6]int{
            index + 32*32,
            index - 32*32,
            index - 32,
            index + 32,
            index + 1,
            index - 1,
        }
        for dir in dirs {
            dir_present, _ := bit_array.get(voxels, dir)
            if !dir_present {sum+=1}
        }
    }
    fmt.println(sum)
}

main_p1_viz :: proc() {
    input := string(#load("input.txt"))
    voxels, _ := bit_array.create(32*32*32-1)
    for line in strings.split_lines_iterator(&input) {
        line_it := line
        i_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        j_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        k_a := line_it
        i := strconv.atoi(i_a)
        j := strconv.atoi(j_a)
        k := strconv.atoi(k_a)
        index := i*32*32 + j*32 + k
        bit_array.set(voxels, index)
    }
    
    Data :: struct {voxels: bit_array.Bit_Array, dirs: [6]int}
    data := Data{voxels^, {}}
    thread.create_and_start_with_poly_data(&data, proc(data: ^Data) {
        rl.InitWindow(2048, 2048, "Advent of Code 2022 - Day 18")
        rl.SetTargetFPS(60)
        cam := rl.Camera{rl.Vector3{0, 20, -40}, rl.Vector3{0, 0, 0}, rl.Vector3{0, 1, 0}, 45, .PERSPECTIVE}
        rl.SetCameraMode(cam, .ORBITAL)
        for !rl.WindowShouldClose() {
            rl.UpdateCamera(&cam)

            rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            rl.BeginMode3D(cam)
            
            for i in 0..<6 {
                index := data.dirs[i]
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 10
                rl.DrawCubeWires(point, 1, 1, 1, rl.GREEN)
            }

            voxel_iter := bit_array.make_iterator(&data.voxels)
            for voxel, index in bit_array.iterate_by_all(&voxel_iter) {
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 10
                if voxel {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.RED)
                }
            }

            rl.EndMode3D()
            rl.EndDrawing()

        }
        rl.CloseWindow()
    })

    windows.Sleep(1000)
    sum := 0
    voxel_iter := bit_array.make_iterator(voxels)
    for voxel, index in bit_array.iterate_by_all(&voxel_iter) {
        if !voxel {continue}

        dirs := [6]int{
            index + 32*32,
            index - 32*32,
            index - 32,
            index + 32,
            index + 1,
            index - 1,
        }

        data.dirs = dirs

        for dir in dirs {
            dir_present, _ := bit_array.get(voxels, dir)
            if !dir_present {sum+=1}
        }

        windows.Sleep(1)
    }
    fmt.println(sum)

    for {windows.Sleep(100)}
}

main_p2_viz :: proc() {
    input := string(#load("small.txt"))
    voxels, _ := bit_array.create(32*32*32-1)
    flood_fill, _ := bit_array.create(32*32*32-1)
    sum := 0
    stack := make([dynamic]int, 0, 32*32*32)
    
    Data :: struct {voxels, flood_fill: bit_array.Bit_Array, dirs: [6]int, sum: ^int, stack: [dynamic]int}
    data := Data{voxels^, flood_fill^, {}, &sum, stack}
    thread.create_and_start_with_poly_data(&data, proc(data: ^Data) {
        rl.InitWindow(2048, 2048, "Advent of Code 2022 - Day 18")
        rl.SetTargetFPS(60)
        cam := rl.Camera{rl.Vector3{0, 20, -40}, rl.Vector3{0, 0, 0}, rl.Vector3{0, 1, 0}, 45, .PERSPECTIVE}
        rl.SetCameraMode(cam, .FREE)
        for !rl.WindowShouldClose() {
            rl.UpdateCamera(&cam)

            rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            rl.BeginMode3D(cam)
            
            // draw voxels
            voxel_iter := bit_array.make_iterator(&data.voxels)
            for voxel, index in bit_array.iterate_by_all(&voxel_iter) {
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 16
                if voxel {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.RED)
                }
            }

            // draw flood fill
            flood_iter := bit_array.make_iterator(&data.flood_fill)
            for voxel, index in bit_array.iterate_by_all(&flood_iter) {
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 16
                if voxel {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.GREEN)
                }
            }

            // draw stack
            for index in data.stack {
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 16
                rl.DrawCubeWires(point, 1, 1, 1, rl.BLUE)
            }

            // draw directions
            for i in 0..<6 {
                index := data.dirs[i]
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 16
                rl.DrawCubeWires(point, 1, 1, 1, rl.PURPLE)
            }
            
            rl.EndMode3D()

            rl.DrawText("Sum: ", 10, 10, 20, rl.WHITE)
            temp: [32]byte
            text := strconv.itoa(temp[:], data.sum^)
            rl.DrawText(strings.clone_to_cstring(text), 60, 10, 20, rl.WHITE)
            rl.EndDrawing()
        }
        rl.CloseWindow()
    })

    windows.Sleep(1000)

    for line in strings.split_lines_iterator(&input) {
        line_it := line
        i_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        j_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        k_a := line_it
        i := strconv.atoi(i_a)
        j := strconv.atoi(j_a)
        k := strconv.atoi(k_a)
        index := i*32*32 + j*32 + k
        bit_array.set(voxels, index)
        // windows.Sleep(1)
    }

    append(&stack, 0)
    bit_array.set(flood_fill, 0)
    
    for len(stack) > 0 {
        index := pop(&stack)
        // sum = index
        windows.Sleep(1)

        dirs := [6]int{
            index + 32*32,
            index - 32*32,
            index - 32,
            index + 32,
            index + 1,
            index - 1,
        }

        data.dirs = dirs

        voxel_present, _ := bit_array.get(voxels, index)
        for dir in dirs {
            // check for valid direction
            if dir < 0 || dir >= 32*32*32 {continue}

            if voxel_present {
                dir_present, _ := bit_array.get(voxels, dir)
                if !dir_present {sum+=1}
            } else {
                flood_dir_present, _:= bit_array.get(flood_fill, dir)
                if !flood_dir_present {
                    bit_array.set(flood_fill, dir)
                    append(&stack, dir)
                }
            }
        }
    }
    fmt.println(sum)

    for {windows.Sleep(100)}
}