package snek

import "core:fmt"
import "core:sys/windows"
import "core:math/linalg"
import rl "vendor:raylib"
import "core:time"
import "core:math/rand"

main :: proc() {
    rl.InitWindow(0, 0, "Snek")
    SCREEN_SIZE:i32 = rl.GetMonitorHeight(rl.GetCurrentMonitor()) * 3/4
    rl.SetWindowSize(SCREEN_SIZE, SCREEN_SIZE)
    rl.SetWindowPosition(i32(f32(SCREEN_SIZE)*0.1), i32(f32(SCREEN_SIZE)*0.1))
//    rl.ClearWindowState({.WINDOW_UNDECORATED})
    BOARD_SIZE :: 20
    ELEMENT_SIZE := SCREEN_SIZE/BOARD_SIZE
    

    apples := make(map[[2]i32]struct{}, 100)
    APPLE_TIME :: 10.
    apple_time_left := 0.
    random_state := rand.create(123)

    body := make([dynamic][2]i32, 0, 100)
    append(&body, [2]i32{BOARD_SIZE/2, BOARD_SIZE/2})

    body_interpolated := make([dynamic][2]f32, 0, 100)
    append(&body_interpolated, [2]f32{f32(SCREEN_SIZE)/2, f32(SCREEN_SIZE)/2})

    MOVE_TIME :: 0.1
    direction := [2]i32{0, 1}
    move_time_left := 0.1
    
    start_time := time.tick_now()
    last_time := start_time

    snek_dead := false

    for !rl.WindowShouldClose() {
        current_time := time.tick_now()
        delta_time := time.duration_seconds(time.tick_diff(last_time, current_time))
        last_time = current_time

        if !snek_dead {
            // spawn apple
            apple_time_left -= delta_time
            if apple_time_left <= 0 {
                apple_time_left += APPLE_TIME

                for {
                    apple_pos := [2]i32{rand.int31_max(BOARD_SIZE, &random_state), rand.int31_max(BOARD_SIZE, &random_state)}
                    collides := false
                    for elem in body {
                        if elem == apple_pos {
                            collides = true
                            break
                        }
                    }
                    if !collides {
                        apples[apple_pos] = {}
                        break
                    }
                }
            }

            // move snake
            move_time_left -= delta_time
            //fmt.println(delta_time)
            if rl.IsKeyDown(.RIGHT) {
                direction = {1, 0}
            } else if rl.IsKeyDown(.LEFT) {
                direction = {-1, 0}
            } else if rl.IsKeyDown(.UP) {
                direction = {0, -1}
            } else if rl.IsKeyDown(.DOWN) {
                direction = {0, 1}
            }

            // check for apple
            if _, ok := apples[body[0]]; ok {
                //fmt.println("apple")
                delete_key(&apples, body[0])
                append(&body, body[len(body)-1])
                append(&body_interpolated, body_interpolated[len(body_interpolated)-1])
                move_time_left = 0.

                if len(apples) == 0 {
                    apple_time_left = 0.
                }
            }
            
            // move snake
            if move_time_left <= 0 {
                //fmt.println("move")
                move_time_left += MOVE_TIME

                for i := len(body)-1; i > 0; i-=1 {
                    body[i] = body[i-1]
                }
                body[0] = body[0] + direction
            }


            // check for collision
            for elem in body[1:] {
                if body[0] == elem {
                    //fmt.println("collision")
                    snek_dead = true
                    break
                }
            }

            // check for out of bounds
            if body[0].x < 0 || body[0].x >= BOARD_SIZE || body[0].y < 0 || body[0].y >= BOARD_SIZE {
                //fmt.println("out of bounds")
                snek_dead = true
            }
        } else {
            if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.R)  {
                snek_dead = false
                clear(&body)
                clear(&body_interpolated)
                append(&body, [2]i32{BOARD_SIZE/2, BOARD_SIZE/2})
                append(&body_interpolated, [2]f32{f32(SCREEN_SIZE/2), f32(SCREEN_SIZE/2)})
                clear(&apples)
                apple_time_left = 0.
                direction = [2]i32{0, 1}
                move_time_left = 0.1
            }
        }


        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        
        toggle := false
        for x in 0..<BOARD_SIZE {
            for y in 0..<BOARD_SIZE {
                rl.DrawRectangle(i32(x)*ELEMENT_SIZE, i32(y)*ELEMENT_SIZE, ELEMENT_SIZE, ELEMENT_SIZE, toggle ? {0,0,0,255} : {40,10,30,255})
                toggle = !toggle
            }
            toggle = !toggle
        }

        for elem, i in body {
            interp := body_interpolated[i]
            desired_pos := linalg.to_f32(elem)*f32(ELEMENT_SIZE)
            if linalg.length2(desired_pos - body_interpolated[i]) > 0.1 {
                dir := linalg.normalize0(desired_pos - body_interpolated[i])
                interp = interp + dir*f32(delta_time)*f32(SCREEN_SIZE)*0.6
                body_interpolated[i] = interp
            }
        }

        // toggle = false
        // for elem in body {
        //     toggle = !toggle
        //     rl.DrawRectangle(elem.x*ELEMENT_SIZE, elem.y*ELEMENT_SIZE, ELEMENT_SIZE, ELEMENT_SIZE, toggle ? rl.GREEN : rl.BLUE)
        // }

        hue: f32 = 0.
        for elem in body_interpolated {
            toggle = !toggle
            hue += 40
            rl.DrawCircle(i32(elem.x)+ELEMENT_SIZE/2, i32(elem.y)+ELEMENT_SIZE/2, f32(ELEMENT_SIZE/2), rl.ColorFromHSV(hue, 1, 1))
        }

        for elem in apples {
            rl.DrawRectangle(elem.x*ELEMENT_SIZE, elem.y*ELEMENT_SIZE, ELEMENT_SIZE, ELEMENT_SIZE, rl.RED)
        }

        rl.DrawFPS(0,0)

        if snek_dead {
            rl.DrawRectangle(0, 0, SCREEN_SIZE, SCREEN_SIZE, {0,0,0,100})
            title: cstring = "Snek is dead"
            title_length := rl.MeasureText(title, 120)
            rl.DrawText(title, SCREEN_SIZE/2-title_length/2, SCREEN_SIZE/2-60, 120, rl.RED)
            title = "Press R to restart"
            title_length = rl.MeasureText(title, 40)
            rl.DrawText(title, SCREEN_SIZE/2-title_length/2, SCREEN_SIZE/2+120-60, 40, rl.RED)
        }
        
        rl.EndDrawing()
    }

    rl.CloseWindow()
}