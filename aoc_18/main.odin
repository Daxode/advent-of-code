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
    
    Data :: struct {voxels, flood_fill: bit_array.Bit_Array, dirs: [6]int}
    data := Data{voxels^, flood_fill^, {}}
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
            
            // for i in 0..<6 {
            //     index := data.dirs[i]
            //     point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
            //     point -= 10
            //     rl.DrawCubeWires(point, 1, 1, 1, rl.GREEN)
            // }

            voxel_iter := bit_array.make_iterator(&data.voxels)
            for voxel, index in bit_array.iterate_by_all(&voxel_iter) {
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 16
                if voxel {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.RED)
                }
            }

            flood_iter := bit_array.make_iterator(&data.flood_fill)
            for voxel, index in bit_array.iterate_by_all(&flood_iter) {
                point := rl.Vector3{f32(index / 32 / 32), f32(index / 32 % 32), f32(index % 32)}
                point -= 16
                if voxel {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.GREEN)
                }
            }

            rl.EndMode3D()
            rl.EndDrawing()

        }
        rl.CloseWindow()
    })

    windows.Sleep(1000)

    fill :: proc(index: int, flood_fill, voxels: ^bit_array.Bit_Array, sides: ^int) {
        windows.Sleep(1)
        already_checked, _ := bit_array.get(flood_fill, index)
        if already_checked {return}
        bit_array.set(flood_fill, index)
        
        voxel_present, _ := bit_array.get(voxels, index)
        dirs := [6]int{
            index + 32*32,
            index - 32*32,
            index - 32,
            index + 32,
            index + 1,
            index - 1,
        }
        for dir in dirs {
            if voxel_present {
                dir_present, _ := bit_array.get(voxels, dir)
                if !dir_present {
                    sides^ += 1
                }
            } else if dir >= 0 && dir < 32*32*32 {
                fill(dir, flood_fill, voxels, sides)
            }
        }
    }

    sides := 0
    fill(0, flood_fill, voxels, &sides)
    fmt.println(sides)

    for {windows.Sleep(100)}
}