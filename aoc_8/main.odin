package aoc_8

import rl "vendor:raylib"
import "core:strings"
import "core:fmt"
import "core:math"
import "core:thread"
import "core:sys/windows"

main :: proc() {
    main_p1()
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