package aoc_10

import "core:fmt"
import "core:strings"
import "core:strconv"
import rl "vendor:raylib"

main :: proc() {
    fmt.println("Day 10")
    main_p1()
    // main_p2_v2() // uncomment to see the visualized result
    fmt.println("EGLHBLFJ")
    fmt.println()
}

main_p1 :: proc() {
    input := string(#load("input.txt"))
    cycles := 0
    x := 1
    sum := 0
    for line in strings.split_lines_iterator(&input) {
        switch line[0] {
            case 'a':
                number := strconv.atoi(line[5:])
                
                if cycles+1 == 20 || cycles+1 == 60 || cycles+1 == 100 || cycles+1 == 140 || cycles+1 == 180 || cycles+1 == 220 {
                    sum += x*(cycles+1)
                } else if cycles+2 == 20 || cycles+2 == 60 || cycles+2 == 100 || cycles+2 == 140 || cycles+2 == 180 || cycles+2 == 220 {
                    sum += x*(cycles+2)
                }

                cycles += 2
                x += number
            case 'n':
                cycles += 1
                if cycles == 20 || cycles == 60 || cycles == 100 || cycles == 140 || cycles == 180 || cycles == 220 {
                    sum += x*cycles
                }
        }
    }
    fmt.println(sum)
}

main_p2 :: proc() {
    input := string(#load("input.txt"))
    cycles: i32 = -1
    x: i32 = 1
    
    SCREEN_WIDTH :: 1920
    TILE_WIDTH_COUNT :: 40
    TILE_HEIGHT_COUNT :: 6
    TILE_SIZE :: SCREEN_WIDTH/TILE_WIDTH_COUNT
    SCREEN_HEIGHT :: TILE_SIZE*TILE_HEIGHT_COUNT

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "display")
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    rl.DrawRectangle(0, 0, TILE_SIZE, TILE_SIZE, rl.GRAY)

    for line in strings.split_lines_iterator(&input) {
        switch line[0] {
            case 'a':
                pixel_x := (cycles+1)%40
                pixel_y := (cycles+1)/40
                color := pixel_x == x || pixel_x == x+1 || pixel_x == x-1 ? rl.GRAY : rl.BLACK
                rl.DrawRectangle(pixel_x*TILE_SIZE, pixel_y*TILE_SIZE, TILE_SIZE, TILE_SIZE, color)
                // buff: [20]u8
                // rl.DrawText(strings.clone_to_cstring(strconv.itoa(buff[:], int(cycles+1))), pixel_x*TILE_SIZE, pixel_y*TILE_SIZE, 20, rl.WHITE)
                
                pixel_x = (cycles+2)%40
                pixel_y = (cycles+2)/40
                color = pixel_x == x || pixel_x == x+1 || pixel_x == x-1 ? rl.GRAY : rl.BLACK
                rl.DrawRectangle(pixel_x*TILE_SIZE, pixel_y*TILE_SIZE, TILE_SIZE, TILE_SIZE, color)
                // rl.DrawText(strings.clone_to_cstring(strconv.itoa(buff[:], int(cycles+2))), pixel_x*TILE_SIZE, pixel_y*TILE_SIZE, 20, rl.WHITE)

                cycles += 2
                number := i32(strconv.atoi(line[5:]))
                x += number
            case 'n':
                cycles += 1
                pixel_x := cycles%40
                pixel_y := cycles/40
                color := pixel_x == x || pixel_x == x+1 || pixel_x == x-1 ? rl.GRAY : rl.BLACK
                rl.DrawRectangle(pixel_x*TILE_SIZE, pixel_y*TILE_SIZE, TILE_SIZE, TILE_SIZE, color)
        }
    }
    rl.EndDrawing()
    for !rl.WindowShouldClose() {}
    rl.CloseWindow()
}

main_p2_v2 :: proc() {
    input := string(#load("input.txt"))
    cycles: i32 = -1
    x: i32 = 1
    
    SCREEN_WIDTH :: 1920
    TILE_WIDTH_COUNT :: 40
    TILE_HEIGHT_COUNT :: 6
    TILE_SIZE :: SCREEN_WIDTH/TILE_WIDTH_COUNT

    rl.InitWindow(SCREEN_WIDTH, TILE_SIZE*TILE_HEIGHT_COUNT, "display")
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)

    consume_cycle :: proc(cycles: ^i32, x: i32) {
        cycles^ += 1
        pixel_x := cycles^ % TILE_WIDTH_COUNT
        pixel_y := cycles^ / TILE_WIDTH_COUNT
        color := pixel_x == x || pixel_x == x+1 || pixel_x == x-1 ? rl.GRAY : rl.BLACK
        rl.DrawRectangle(pixel_x*TILE_SIZE, pixel_y*TILE_SIZE, TILE_SIZE, TILE_SIZE, color)
    }

    for line in strings.split_lines_iterator(&input) {
        consume_cycle(&cycles, x)
        if line[0] == 'a' {
            consume_cycle(&cycles, x)
            number := i32(strconv.atoi(line[5:]))
            x += number
        }
    }

    rl.EndDrawing()
    for !rl.WindowShouldClose() {}
    rl.CloseWindow()
}