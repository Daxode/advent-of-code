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
    // main_p2_viz()
    main_p2()
    fmt.println()
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
    GRID_SIZE :: 32

    input := string(#load("input.txt"))
    voxels, _ := bit_array.create(GRID_SIZE*GRID_SIZE*GRID_SIZE-1)
    flood_fill, _ := bit_array.create(GRID_SIZE*GRID_SIZE*GRID_SIZE-1)
    stack := make([dynamic]int, 0, GRID_SIZE*GRID_SIZE*GRID_SIZE)
    sides: map[[2]int]struct{} // [0] is the side, [1] is the direction both are indexes into voxels
    
    Data :: struct {voxels, flood_fill: bit_array.Bit_Array, dirs: [6]int, sides: ^map[[2]int]struct{}, stack: ^[dynamic]int}
    data := Data{voxels^, flood_fill^, {}, &sides, &stack}
    thread.create_and_start_with_poly_data(&data, proc(data: ^Data) {
        rl.InitWindow(2048, 2048, "Advent of Code 2022 - Day 18")
        rl.SetTargetFPS(60)
        cam := rl.Camera{rl.Vector3{0, 0, 0}, rl.Vector3{0, 0, 0}, rl.Vector3{0, 1, 0}, 70, .PERSPECTIVE}
        rl.SetCameraMode(cam, .FREE)

        fill_show := 0
        stack_show := 0
        for !rl.WindowShouldClose() {
            rl.UpdateCamera(&cam)

            fill_show += int(rl.IsKeyDown(.RIGHT)) - int(rl.IsKeyDown(.LEFT))
            fill_show = clamp(fill_show, 0, GRID_SIZE)
            stack_show += int(rl.IsKeyDown(.DOWN)) - int(rl.IsKeyDown(.UP))
            stack_show = clamp(stack_show, 0, GRID_SIZE)

            rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            rl.BeginMode3D(cam)
            
            // draw voxels
            voxel_iter := bit_array.make_iterator(&data.voxels)
            for voxel, index in bit_array.iterate_by_all(&voxel_iter) {
                point := rl.Vector3{f32(index / GRID_SIZE / GRID_SIZE), f32(index / GRID_SIZE % GRID_SIZE), f32(index % GRID_SIZE)}
                point -= GRID_SIZE/2
                if voxel {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.RED)
                }
            }

            // draw flood fill
            flood_iter := bit_array.make_iterator(&data.flood_fill)
            for voxel, index in bit_array.iterate_by_all(&flood_iter) {
                point := rl.Vector3{f32(index / GRID_SIZE / GRID_SIZE), f32(index / GRID_SIZE % GRID_SIZE), f32(index % GRID_SIZE)}
                point -= GRID_SIZE/2
                if voxel && point.x+(GRID_SIZE/2) < f32(fill_show) {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.GREEN)
                }
            }

            // draw sides
            for side in data.sides {
                index_0 := side[0]
                point_0 := rl.Vector3{f32(index_0 / GRID_SIZE / GRID_SIZE), f32(index_0 / GRID_SIZE % GRID_SIZE), f32(index_0 % GRID_SIZE)}
                point_0 -= GRID_SIZE/2

                index_1 := side[1]
                point_1 := rl.Vector3{f32(index_1 / GRID_SIZE / GRID_SIZE), f32(index_1 / GRID_SIZE % GRID_SIZE), f32(index_1 % GRID_SIZE)}
                point_1 -= GRID_SIZE/2

                // rl.DrawLine3D(point_0, point_1,{0,0,255,150})
                // draw square between points
                rl.DrawCubeWiresV((point_0+point_1)/2, {
                    point_0.x == point_1.x ? .6 : .01, 
                    point_0.y == point_1.y ? .6 : .01, 
                    point_0.z == point_1.z ? .6 : .01,
                }, rl.Fade(rl.BLUE, 1))
            }


            // draw stack
            for index in data.stack {
                point := rl.Vector3{f32(index / GRID_SIZE / GRID_SIZE), f32(index / GRID_SIZE % GRID_SIZE), f32(index % GRID_SIZE)}
                point -= GRID_SIZE/2
                if point.x+GRID_SIZE/2 < f32(stack_show) {
                    rl.DrawCubeWires(point, 1, 1, 1, rl.YELLOW)
                }
            }

            // draw directions
            for i in 0..<6 {
                index := data.dirs[i]
                point := rl.Vector3{f32(index / GRID_SIZE / GRID_SIZE), f32(index / GRID_SIZE % GRID_SIZE), f32(index % GRID_SIZE)}
                point -= GRID_SIZE/2
                rl.DrawCubeWires(point, 1, 1, 1, rl.PURPLE)
            }
            
            rl.EndMode3D()

            rl.DrawText("Sum: ", 10, 10, 20, rl.WHITE)
            temp: [32]byte
            text := strconv.itoa(temp[:], len(data.sides))
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
        index := i*GRID_SIZE*GRID_SIZE + j*GRID_SIZE + k
        bit_array.set(voxels, index)
        // windows.Sleep(1)
    }

    append(&stack, 0)
    bit_array.set(flood_fill, 0)
    
    for len(stack) > 0 {
        index := pop(&stack)
        windows.Sleep(1)

        dirs := [6]int{
            index + GRID_SIZE*GRID_SIZE,
            index - GRID_SIZE*GRID_SIZE,
            index - GRID_SIZE,
            index + GRID_SIZE,
            index + 1,
            index - 1,
        }
        data.dirs = dirs

        voxel_present, _ := bit_array.get(voxels, index)
        if !voxel_present {
            for dir, i in dirs {
                // check for valid direction
                if dir < 0 || dir >= GRID_SIZE*GRID_SIZE*GRID_SIZE {continue}
                    flood_dir_present, _:= bit_array.get(flood_fill, dir)
                    dir_present, _ := bit_array.get(voxels, dir)
                    if dir_present {
                        sides[[2]int{index, dir}] = {}
                    }
                    if !flood_dir_present && !dir_present {
                        bit_array.set(flood_fill, dir)
                        append(&stack, dir)
                    }
            }
        }
    }
    fmt.println(len(sides))

    for {windows.Sleep(100)}
}

main_p2 :: proc() {    
    input := string(#load("input.txt"))
    voxels, _ := bit_array.create(GRID_SIZE*GRID_SIZE*GRID_SIZE-1)

    GRID_SIZE :: 32
    
    for line in strings.split_lines_iterator(&input) {
        line_it := line
        i_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        j_a, _ := strings.split_by_byte_iterator(&line_it, ',')
        k_a := line_it
        i := strconv.atoi(i_a)
        j := strconv.atoi(j_a)
        k := strconv.atoi(k_a)
        index := i*GRID_SIZE*GRID_SIZE + j*GRID_SIZE + k
        bit_array.set(voxels, index)
    }
    
    stack := make([dynamic]int, 0, GRID_SIZE*GRID_SIZE*GRID_SIZE)
    flood_fill, _ := bit_array.create(GRID_SIZE*GRID_SIZE*GRID_SIZE-1)

    append(&stack, 0)
    bit_array.set(flood_fill, 0)
    sum := 0
    for len(stack) > 0 {
        index := pop(&stack)

        dirs := [6]int{
            index + GRID_SIZE*GRID_SIZE,
            index - GRID_SIZE*GRID_SIZE,
            index - GRID_SIZE,
            index + GRID_SIZE,
            index + 1,
            index - 1,
        }

        voxel_present, _ := bit_array.get(voxels, index)
        if !voxel_present {
            for dir, i in dirs {
                // check for valid direction
                if dir < 0 || dir >= GRID_SIZE*GRID_SIZE*GRID_SIZE {continue}

                dir_present, _ := bit_array.get(voxels, dir)
                if dir_present {
                    sum += 1
                } else {
                    flood_dir_present, _:= bit_array.get(flood_fill, dir)
                    if !flood_dir_present{
                        bit_array.set(flood_fill, dir)
                        append(&stack, dir)
                    }
                }
            }
        }
    }
    fmt.println(sum)
}