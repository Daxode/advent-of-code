package aoc_12

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:math"
import "core:container/priority_queue"
import "core:thread"
import "core:sys/windows"

main :: proc() {
    main_p1()
}

main_p1 :: proc() {
    input := #load("input.txt")

    Data :: struct {input: []u8}
    data := Data{input}
    thread.create_and_start_with_poly_data(&data, proc(data: ^Data){
        rl.InitWindow(2048, 2048, "AoC 12")
        image := rl.LoadImage("../aoc_12/basic.png")
        defer rl.UnloadImage(image)
        texture_dirt := rl.LoadTextureFromImage(image)
        defer rl.UnloadTexture(texture_dirt)
        
        cam: rl.Camera3D = {
            position = rl.Vector3{0, 70, -100},
            target = rl.Vector3{0, 0, 0},
            up = rl.Vector3{0, 1, 0},
            fovy = 45,
            projection = .PERSPECTIVE,
        }
        rl.SetCameraMode(cam, .ORBITAL)
        rl.SetTargetFPS(60)
        
        for !rl.WindowShouldClose() {
            rl.UpdateCamera(&cam)

            rl.BeginDrawing()
            rl.ClearBackground({40, 30, 10, 255})
            rl.BeginMode3D(cam)
            for y in 0..<41 {
                for x in 0..<64 {
                    input_val := data.input[y*66+x]
                    current_height := input_val=='S' ? 0 : input_val=='E' ? 'z'-'a' : input_val - 'a'
                    pos := rl.Vector3{f32(x)-64/2, 0.5, f32(y)-41/2}

                    rl.DrawCubeTexture(texture_dirt, pos+{0,(f32(current_height)/2)-0.5,0}, 1, f32(current_height), 1, rl.ColorFromHSV(f32(current_height)*20, 1, 1))
                    for i in 0..<current_height {
                        rl.DrawCubeWires(pos + {0, f32(i), 0}, 1, 1, 1, rl.BROWN)
                    }

                    if input_val == 'S' {
                        rl.DrawSphere(pos, 0.5, rl.PURPLE)
                    } else if input_val == 'E' {
                        rl.DrawSphere(pos + {0, 'z'-'a', 0}, 0.5, rl.GREEN)
                    }
                }
            }
            rl.EndMode3D()
            rl.EndDrawing()
        }

        rl.CloseWindow()
    })

    for {
        windows.Sleep(100)
    }
}