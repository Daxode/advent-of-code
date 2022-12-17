package aoc_8

import rl "vendor:raylib"
import "core:strings"
import "core:fmt"
import "core:math"
import "core:thread"
import "core:sys/windows"
import "core:strconv"

main :: proc() {
    fmt.println("Day 8")
    main_p1()
    main_p2()
    fmt.println()
}

main_p1 :: proc() {
    input := #load("input.txt")
    width := int((-2 + math.sqrt(f32(4-4*-len(input))))/2) when ODIN_OS == .Windows else 
             int((-1 + math.sqrt(f32(1-4*-len(input))))/2)
             differ := make([dynamic]u8, width*width*4+8)
    // tree_is_visible := make([dynamic]u8, width*width+2)
             
    // RenderData :: struct {input:[]u8, width:int, differ, tree_is_visible :[dynamic]u8}
    // render_data := RenderData{input, width, differ, tree_is_visible}
    // thread.create_and_start_with_poly_data(&render_data, proc(render_data: ^RenderData){
    //     rl.InitWindow(2048, 2048, "viz")
    //     for !rl.WindowShouldClose() {
    //         rl.ClearBackground(rl.BLACK)
    //         rl.BeginDrawing()
    //         x, y:= 0, 0
    //         offset_newline := 0
    //         for b, i in render_data.input {
    //             if b=='\r' {continue}
    //             offset_newline += 2*int(b=='\n')

    //             colors := [?]rl.Color {
    //                 rl.BLACK,
    //                 rl.DARKGREEN,
    //                 rl.GREEN,
    //                 rl.LIME,
    //                 rl.DARKBLUE, 
    //                 rl.BLUE,
    //                 rl.DARKPURPLE,
    //                 rl.RED,
    //                 rl.PINK,
    //                 rl.BEIGE,
    //             }

    //             if b!='\n' {
    //                 hue := (f32(render_data.input[i]-'0')/10)*320
    //                 rl.DrawRectangle(i32(x*20), i32(y*20), 20, 20, colors[render_data.input[i]-'0'])

    //                 differ_index := (i-offset_newline)*4
    //                 if (rl.IsKeyDown(.A)) {
    //                     hue = (f32(render_data.differ[differ_index])/10)*320
    //                     rl.DrawRectangle(i32(x*20), i32(y*20), 4, 20, colors[render_data.differ[differ_index]])
    //                 } if (rl.IsKeyDown(.W)) {
    //                     hue = (f32(render_data.differ[differ_index+1])/10)*320
    //                     rl.DrawRectangle(i32(x*20), i32(y*20), 20, 4, colors[render_data.differ[differ_index+1]])
    //                 } if (rl.IsKeyDown(.D)) {
    //                     hue = (f32(render_data.differ[differ_index+2])/10)*320
    //                     rl.DrawRectangle(i32(x*20)+16, i32(y*20), 4, 20, colors[render_data.differ[differ_index+2]])
    //                 } if (rl.IsKeyDown(.S)) {
    //                     hue = (f32(render_data.differ[differ_index+3])/10)*320
    //                     rl.DrawRectangle(i32(x*20), i32(y*20)+16, 20, 4, colors[render_data.differ[differ_index+3]])
    //                 }

    //                 if (!(rl.IsKeyDown(.A) || rl.IsKeyDown(.W) || rl.IsKeyDown(.D) || rl.IsKeyDown(.S) || rl.IsKeyDown(.SPACE))){
    //                     hue = (f32(render_data.differ[differ_index])/10)*320
    //                     rl.DrawRectangle(i32(x*20), i32(y*20), 4, 20, colors[render_data.differ[differ_index]])
    //                     hue = (f32(render_data.differ[differ_index+1])/10)*320
    //                     rl.DrawRectangle(i32(x*20), i32(y*20), 20, 4, colors[render_data.differ[differ_index+1]])
    //                     hue = (f32(render_data.differ[differ_index+2])/10)*320
    //                     rl.DrawRectangle(i32(x*20)+16, i32(y*20), 4, 20, colors[render_data.differ[differ_index+2]])
    //                     hue = (f32(render_data.differ[differ_index+3])/10)*320
    //                     rl.DrawRectangle(i32(x*20), i32(y*20)+16, 20, 4, colors[render_data.differ[differ_index+3]])
    //                 }

    //                 if (rl.IsKeyDown(.SPACE)) {
    //                     rl.DrawRectangle(i32(x*20)+5, i32(y*20)+5, 10, 10, render_data.tree_is_visible[i-offset_newline]==1 ? rl.WHITE : rl.BLACK)
    //                 }
    //             }

    //             if b=='\n' {
    //                 y +=1
    //                 x=0
    //             } else {
    //                 x+=1
    //             }
    //         }
    //         rl.EndDrawing()
    //     }
    //     rl.CloseWindow()
    // })

    // left - up diff
    offset_newline := 0
    for b, i in input {
        offset_newline += 2*int(b=='\n')
        left := i-1 < 0 ? 0 : input[i-1]-'0'
        is_at_very_left := left > 9
        left = is_at_very_left ? 0 : left
        up := i-width-2 < 0 ? 0 : input[i-width-2]-'0'

        differ_index := (i-offset_newline)*4
        differ_left := differ_index-4 > 0 && !is_at_very_left ? differ[differ_index-4] : 0
        differ_up := differ_index-width*4 > 0 ? differ[(differ_index-width*4)+1] : 0
         
        newlining := b=='\r' || b=='\n'
        differ[differ_index] = newlining ? differ[differ_index] : max(differ_left, left)
        differ[differ_index+1] = newlining ? differ[differ_index+1] : max(differ_up, up)
        // windows.Sleep(1)
    }

    // right - down diff
    for i:=len(input)-1; i>0; i-=1 {
        b:= input[i]

        offset_newline -= 2*int(b=='\n')
        right := i+1 >= len(input) ? 0 : input[i+1]-'0'
        is_at_very_right := right > 9
        right = is_at_very_right ? 0 : right
        down := i+width+2 >= len(input) ? 0 : input[i+width+2]-'0'

        differ_index := (i-offset_newline)*4
        differ_right := differ_index+4 < len(differ) && !is_at_very_right ? differ[(differ_index+4)+2] : 0
        differ_down := differ_index+width*4 < len(differ) ? differ[(differ_index+width*4)+3] : 0
         
        newlining := b=='\r' || b=='\n'
        differ[differ_index+2] = newlining ? differ[differ_index+2] : max(differ_right, right)
        differ[differ_index+3] = newlining ? differ[differ_index+3] : max(differ_down, down)
        // windows.Sleep(1)
    }

    // fmt.println(transmute([][4]u8)differ[:len(differ)/4])

    // visible test
    sum_of_visibles: u32 = 0
    for b, i in input {
        offset_newline += 2*int(b=='\n')
        differ_index := (i-offset_newline)*4
         
        newlining := b=='\r' || b=='\n'
        bounds := offset_newline == 0 || offset_newline == 196 || i % (width+2) == 0 || i % (width+2) == width-1
        tree_value := u32((differ[differ_index] < b-'0' || 
                           differ[differ_index+1] < b-'0' || 
                           differ[differ_index+2] < b-'0' || 
                           differ[differ_index+3] < b-'0' ||
                           bounds) &&
                           !newlining)
        sum_of_visibles += tree_value 
        // tree_is_visible[i-offset_newline] = newlining ? tree_is_visible[i-offset_newline] : u8(tree_value)
    }

    fmt.println(sum_of_visibles)

    // for {
    //     windows.Sleep(100)
    // }
}

main_p2 :: proc() {
    input := #load("input.txt")
    width := int((-2 + math.sqrt(f32(4-4*-len(input))))/2) when ODIN_OS == .Windows else 
             int((-1 + math.sqrt(f32(1-4*-len(input))))/2)
    runner := make([dynamic]u8, width*width*4*9+3*4*9)

    // RenderData :: struct {input:[]u8, width:int, runner :[dynamic]u8}
    // render_data := RenderData{input, width, runner}
    // thread.create_and_start_with_poly_data(&render_data, proc(render_data: ^RenderData){
    //     rl.InitWindow(1980, 1980, "viz")
    //     for !rl.WindowShouldClose() {
    //         rl.ClearBackground(rl.BLACK)
    //         rl.BeginDrawing()
    //         x, y:= 0, 0
    //         offset_newline := 0
    //         for b, i in render_data.input {
    //             if b=='\r' {continue}
    //             offset_newline += 2*int(b=='\n')

    //             colors := [?]rl.Color {
    //                 rl.BLACK,
    //                 rl.DARKGREEN,
    //                 rl.GREEN,
    //                 rl.LIME,
    //                 rl.DARKBLUE, 
    //                 rl.BLUE,
    //                 rl.DARKPURPLE,
    //                 rl.RED,
    //                 rl.PINK,
    //                 rl.BEIGE,
    //             }

    //             if b!='\n' {
    //                 rl.DrawRectangle(i32(x*20), i32(y*20), 20, 20, colors[render_data.input[i]-'0'])
    //                 runner_index := (i-offset_newline)*4*9
    //                 number_pressed := (rl.IsKeyDown(.ONE) ? 1 :
    //                                    rl.IsKeyDown(.TWO) ? 2 : 
    //                                    rl.IsKeyDown(.THREE) ? 3 : 
    //                                    rl.IsKeyDown(.FOUR) ? 4 : 
    //                                    rl.IsKeyDown(.FIVE) ? 5 : 
    //                                    rl.IsKeyDown(.SIX) ? 6 : 
    //                                    rl.IsKeyDown(.SEVEN) ? 7 : 
    //                                    rl.IsKeyDown(.EIGHT) ? 8 : 
    //                                    rl.IsKeyDown(.NINE) ? 9 : 1)-1

    //                 if (rl.IsKeyDown(.LEFT)) {
    //                     temp: [256]byte
    //                     number := int(render_data.runner[runner_index+number_pressed])
    //                     text := strings.clone_to_cstring(strconv.itoa(temp[:], number))
    //                     rl.DrawText(text, i32(x*20)+1, i32(y*20)+5, 5, rl.WHITE)
    //                 }
    //                 if (rl.IsKeyDown(.UP)) {
    //                     temp: [256]byte
    //                     number := int(render_data.runner[runner_index+number_pressed+9])
    //                     text := strings.clone_to_cstring(strconv.itoa(temp[:], number))
    //                     rl.DrawText(text, i32(x*20)+1, i32(y*20)+5, 5, rl.WHITE)
    //                 }
    //                 if (rl.IsKeyDown(.RIGHT)) {
    //                     temp: [256]byte
    //                     number := int(render_data.runner[runner_index+number_pressed+9*2])
    //                     text := strings.clone_to_cstring(strconv.itoa(temp[:], number))
    //                     rl.DrawText(text, i32(x*20)+1, i32(y*20)+5, 5, rl.WHITE)
    //                 }
    //                 if (rl.IsKeyDown(.DOWN)) {
    //                     temp: [256]byte
    //                     number := int(render_data.runner[runner_index+number_pressed+9*3])
    //                     text := strings.clone_to_cstring(strconv.itoa(temp[:], number))
    //                     rl.DrawText(text, i32(x*20)+1, i32(y*20)+5, 5, rl.WHITE)
    //                 }
    //             }

    //             if b=='\n' {
    //                 y +=1
    //                 x=0
    //             } else {
    //                 x+=1
    //             }
    //         }
    //         rl.EndDrawing()
    //     }
    //     rl.CloseWindow()
    // })

    offset_newline := 0
    for b, i in input {
        offset_newline += 2*int(b=='\n')
        left := i-1 < 0 ? 0 : input[i-1]-'0'
        is_at_very_left := left > 9
        left = is_at_very_left ? 0 : left
        up := i-width-2 < 0 ? 0 : input[i-width-2]-'0'

        newlining := b=='\r' || b=='\n'
        
        runner_index := (i-offset_newline)*4*9
        
        runner_left_1 := runner_index-4*9   >= 0 && !is_at_very_left ? runner[runner_index-4*9]   : 0
        runner_left_2 := runner_index-4*9+1 >= 0 && !is_at_very_left ? runner[runner_index-4*9+1] : 0
        runner_left_3 := runner_index-4*9+2 >= 0 && !is_at_very_left ? runner[runner_index-4*9+2] : 0
        runner_left_4 := runner_index-4*9+3 >= 0 && !is_at_very_left ? runner[runner_index-4*9+3] : 0
        runner_left_5 := runner_index-4*9+4 >= 0 && !is_at_very_left ? runner[runner_index-4*9+4] : 0
        runner_left_6 := runner_index-4*9+5 >= 0 && !is_at_very_left ? runner[runner_index-4*9+5] : 0
        runner_left_7 := runner_index-4*9+6 >= 0 && !is_at_very_left ? runner[runner_index-4*9+6] : 0
        runner_left_8 := runner_index-4*9+7 >= 0 && !is_at_very_left ? runner[runner_index-4*9+7] : 0
        runner_left_9 := runner_index-4*9+8 >= 0 && !is_at_very_left ? runner[runner_index-4*9+8] : 0

        runner[runner_index]   = newlining ? runner[runner_index]   : b-'0' < 1 ? runner_left_1 + 1 : 1
        runner[runner_index+1] = newlining ? runner[runner_index+1] : b-'0' < 2 ? runner_left_2 + 1 : 1
        runner[runner_index+2] = newlining ? runner[runner_index+2] : b-'0' < 3 ? runner_left_3 + 1 : 1
        runner[runner_index+3] = newlining ? runner[runner_index+3] : b-'0' < 4 ? runner_left_4 + 1 : 1
        runner[runner_index+4] = newlining ? runner[runner_index+4] : b-'0' < 5 ? runner_left_5 + 1 : 1
        runner[runner_index+5] = newlining ? runner[runner_index+5] : b-'0' < 6 ? runner_left_6 + 1 : 1
        runner[runner_index+6] = newlining ? runner[runner_index+6] : b-'0' < 7 ? runner_left_7 + 1 : 1
        runner[runner_index+7] = newlining ? runner[runner_index+7] : b-'0' < 8 ? runner_left_8 + 1 : 1
        runner[runner_index+8] = newlining ? runner[runner_index+8] : b-'0' < 9 ? runner_left_9 + 1 : 1

        runner_up_1 := 9+runner_index-width*4*9   >= 0 ? runner[9+runner_index-width*4*9]   : 0
        runner_up_2 := 9+runner_index-width*4*9+1 >= 0 ? runner[9+runner_index-width*4*9+1] : 0
        runner_up_3 := 9+runner_index-width*4*9+2 >= 0 ? runner[9+runner_index-width*4*9+2] : 0
        runner_up_4 := 9+runner_index-width*4*9+3 >= 0 ? runner[9+runner_index-width*4*9+3] : 0
        runner_up_5 := 9+runner_index-width*4*9+4 >= 0 ? runner[9+runner_index-width*4*9+4] : 0
        runner_up_6 := 9+runner_index-width*4*9+5 >= 0 ? runner[9+runner_index-width*4*9+5] : 0
        runner_up_7 := 9+runner_index-width*4*9+6 >= 0 ? runner[9+runner_index-width*4*9+6] : 0
        runner_up_8 := 9+runner_index-width*4*9+7 >= 0 ? runner[9+runner_index-width*4*9+7] : 0
        runner_up_9 := 9+runner_index-width*4*9+8 >= 0 ? runner[9+runner_index-width*4*9+8] : 0

        runner[9+runner_index]   = newlining ? runner[9+runner_index]   : b-'0' < 1 ? runner_up_1 + 1 : 1
        runner[9+runner_index+1] = newlining ? runner[9+runner_index+1] : b-'0' < 2 ? runner_up_2 + 1 : 1
        runner[9+runner_index+2] = newlining ? runner[9+runner_index+2] : b-'0' < 3 ? runner_up_3 + 1 : 1
        runner[9+runner_index+3] = newlining ? runner[9+runner_index+3] : b-'0' < 4 ? runner_up_4 + 1 : 1
        runner[9+runner_index+4] = newlining ? runner[9+runner_index+4] : b-'0' < 5 ? runner_up_5 + 1 : 1
        runner[9+runner_index+5] = newlining ? runner[9+runner_index+5] : b-'0' < 6 ? runner_up_6 + 1 : 1
        runner[9+runner_index+6] = newlining ? runner[9+runner_index+6] : b-'0' < 7 ? runner_up_7 + 1 : 1
        runner[9+runner_index+7] = newlining ? runner[9+runner_index+7] : b-'0' < 8 ? runner_up_8 + 1 : 1
        runner[9+runner_index+8] = newlining ? runner[9+runner_index+8] : b-'0' < 9 ? runner_up_9 + 1 : 1
    }

    max_score := 0
    for i:=len(input)-1; i>0; i-=1 {
        b:= input[i]
        offset_newline -= 2*int(b=='\n')
        right := i+1 >= len(input) ? 0 : input[i+1]-'0'
        is_at_very_right := right > 9
        right = is_at_very_right ? 0 : right
        down := i+width+2 >= len(input) ? 0 : input[i+width+2]-'0'         

        newlining := b=='\r' || b=='\n'

        runner_index := (i-offset_newline)*4*9
        
        runner_right_1 := 2*9+runner_index+4*9   < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9]   : 0
        runner_right_2 := 2*9+runner_index+4*9+1 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+1] : 0
        runner_right_3 := 2*9+runner_index+4*9+2 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+2] : 0
        runner_right_4 := 2*9+runner_index+4*9+3 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+3] : 0
        runner_right_5 := 2*9+runner_index+4*9+4 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+4] : 0
        runner_right_6 := 2*9+runner_index+4*9+5 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+5] : 0
        runner_right_7 := 2*9+runner_index+4*9+6 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+6] : 0
        runner_right_8 := 2*9+runner_index+4*9+7 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+7] : 0
        runner_right_9 := 2*9+runner_index+4*9+8 < len(runner) && !is_at_very_right ? runner[2*9+runner_index+4*9+8] : 0

        runner[9*2+runner_index]   = newlining ? runner[9*2+runner_index]   : b-'0' < 1 ? runner_right_1 + 1 : 1
        runner[9*2+runner_index+1] = newlining ? runner[9*2+runner_index+1] : b-'0' < 2 ? runner_right_2 + 1 : 1
        runner[9*2+runner_index+2] = newlining ? runner[9*2+runner_index+2] : b-'0' < 3 ? runner_right_3 + 1 : 1
        runner[9*2+runner_index+3] = newlining ? runner[9*2+runner_index+3] : b-'0' < 4 ? runner_right_4 + 1 : 1
        runner[9*2+runner_index+4] = newlining ? runner[9*2+runner_index+4] : b-'0' < 5 ? runner_right_5 + 1 : 1
        runner[9*2+runner_index+5] = newlining ? runner[9*2+runner_index+5] : b-'0' < 6 ? runner_right_6 + 1 : 1
        runner[9*2+runner_index+6] = newlining ? runner[9*2+runner_index+6] : b-'0' < 7 ? runner_right_7 + 1 : 1
        runner[9*2+runner_index+7] = newlining ? runner[9*2+runner_index+7] : b-'0' < 8 ? runner_right_8 + 1 : 1
        runner[9*2+runner_index+8] = newlining ? runner[9*2+runner_index+8] : b-'0' < 9 ? runner_right_9 + 1 : 1

        runner_down_1 := 3*9+runner_index+width*4*9   < len(runner) ? runner[3*9+runner_index+width*4*9]   : 0
        runner_down_2 := 3*9+runner_index+width*4*9+1 < len(runner) ? runner[3*9+runner_index+width*4*9+1] : 0
        runner_down_3 := 3*9+runner_index+width*4*9+2 < len(runner) ? runner[3*9+runner_index+width*4*9+2] : 0
        runner_down_4 := 3*9+runner_index+width*4*9+3 < len(runner) ? runner[3*9+runner_index+width*4*9+3] : 0
        runner_down_5 := 3*9+runner_index+width*4*9+4 < len(runner) ? runner[3*9+runner_index+width*4*9+4] : 0
        runner_down_6 := 3*9+runner_index+width*4*9+5 < len(runner) ? runner[3*9+runner_index+width*4*9+5] : 0
        runner_down_7 := 3*9+runner_index+width*4*9+6 < len(runner) ? runner[3*9+runner_index+width*4*9+6] : 0
        runner_down_8 := 3*9+runner_index+width*4*9+7 < len(runner) ? runner[3*9+runner_index+width*4*9+7] : 0
        runner_down_9 := 3*9+runner_index+width*4*9+8 < len(runner) ? runner[3*9+runner_index+width*4*9+8] : 0

        runner[3*9+runner_index]   = newlining ? runner[3*9+runner_index]   : b-'0' < 1 ? runner_down_1 + 1 : 1
        runner[3*9+runner_index+1] = newlining ? runner[3*9+runner_index+1] : b-'0' < 2 ? runner_down_2 + 1 : 1
        runner[3*9+runner_index+2] = newlining ? runner[3*9+runner_index+2] : b-'0' < 3 ? runner_down_3 + 1 : 1
        runner[3*9+runner_index+3] = newlining ? runner[3*9+runner_index+3] : b-'0' < 4 ? runner_down_4 + 1 : 1
        runner[3*9+runner_index+4] = newlining ? runner[3*9+runner_index+4] : b-'0' < 5 ? runner_down_5 + 1 : 1
        runner[3*9+runner_index+5] = newlining ? runner[3*9+runner_index+5] : b-'0' < 6 ? runner_down_6 + 1 : 1
        runner[3*9+runner_index+6] = newlining ? runner[3*9+runner_index+6] : b-'0' < 7 ? runner_down_7 + 1 : 1
        runner[3*9+runner_index+7] = newlining ? runner[3*9+runner_index+7] : b-'0' < 8 ? runner_down_8 + 1 : 1
        runner[3*9+runner_index+8] = newlining ? runner[3*9+runner_index+8] : b-'0' < 9 ? runner_down_9 + 1 : 1


        can_index := !(b=='0' || newlining)
        runner_left  := int( can_index &&     runner_index-      4*9+int(b-'0'-1) > 0           ? runner[    runner_index-      4*9+int(b-'0'-1)] : 0)
        runner_up    := int( can_index && 1*9+runner_index-width*4*9+int(b-'0'-1) > 0           ? runner[1*9+runner_index-width*4*9+int(b-'0'-1)] : 0)
        runner_right := int( can_index && 2*9+runner_index+      4*9+int(b-'0'-1) < len(runner) ? runner[2*9+runner_index+      4*9+int(b-'0'-1)] : 0)
        runner_down  := int( can_index && 3*9+runner_index+width*4*9+int(b-'0'-1) < len(runner) ? runner[3*9+runner_index+width*4*9+int(b-'0'-1)] : 0)
        max_score = max(max_score, runner_left*runner_up*runner_right*runner_down)
    }
    fmt.println(max_score)

    // for {
    //     windows.Sleep(100)
    // }
}