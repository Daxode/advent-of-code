package aoc_9

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/linalg"

import rl "vendor:raylib"
import "core:sys/windows"
import "core:thread"

main :: proc() {
    // main_p1()
    main_p2()
}



main_p1 :: proc(){
    input := string(#load("input.txt"))

    tail_been_at := make(map[[2]int]struct{}, 10000)
    head, tail: [2]int

    // Data :: struct {head, tail: ^[2]int, tail_been_at: map[[2]int]struct{}, current_line: string}
    // data := Data{&head, &tail, tail_been_at, ""}
    // thread.create_and_start_with_poly_data(&data, proc(data: ^Data){
    //     CANVAS_SIZE :: 2000
    //     rl.InitWindow(CANVAS_SIZE, CANVAS_SIZE, "Viz")
    //     for !rl.WindowShouldClose() {
    //         rl.ClearBackground(rl.BLACK)
    //         rl.BeginDrawing()
    //         val:=false
            
    //         RECT_COUNT :: 200
    //         RECT_SIZE :: CANVAS_SIZE/RECT_COUNT

    //         for y in 0..<i32(RECT_COUNT) {
    //             for x in 0..<i32(RECT_COUNT) {
    //                 val = !val
    //                 temp: [256]u8
    //                 //xy := strings.clone_to_cstring(strings.join({strconv.itoa(temp[:], int(x)), strconv.itoa(temp[:], int(y))}, ","))
    //                 //rl.DrawText(xy, x*RECT_SIZE+RECT_SIZE/10, y*RECT_SIZE+RECT_SIZE/10, RECT_SIZE/10, rl.BLACK)
    //                 rl.DrawRectangle(x*RECT_SIZE, y*RECT_SIZE, RECT_SIZE, RECT_SIZE, val?rl.WHITE:rl.GRAY)
    //             }
    //             val = !val
    //         }
    //         for vall in data.tail_been_at {
    //             val := vall + RECT_COUNT/2
    //             rl.DrawRectangle(i32(val.x*RECT_SIZE), i32(val.y*RECT_SIZE), RECT_SIZE, RECT_SIZE, {255,255,0,255})
    //         }

    //         head:= data.head^+RECT_COUNT/2
    //         tail:= data.tail^+RECT_COUNT/2
    //         rl.DrawRectangle(i32(head.x*RECT_SIZE), i32(head.y*RECT_SIZE), RECT_SIZE, RECT_SIZE, {255,0,0,100})
    //         rl.DrawRectangle(i32(tail.x*RECT_SIZE), i32(tail.y*RECT_SIZE), RECT_SIZE, RECT_SIZE, {0,255,0,100})
    //         rl.DrawText(strings.clone_to_cstring(data.current_line), 0,0, 150, rl.BLACK)
    //         rl.EndDrawing()

    //     }

    // })

    for line in strings.split_lines_iterator(&input) {
        // data.current_line = line
        is_vertical := false
        amount: int
        sign := 1
        switch line[0] {
            case 'R':
                is_vertical = true
                amount = strconv.atoi(line[2:])
            case 'L':
                is_vertical = true
                amount = -strconv.atoi(line[2:])
                sign = -1
            case 'D':
                amount = strconv.atoi(line[2:])
            case 'U':
                amount = -strconv.atoi(line[2:])
                sign = -1
        }

        for ; amount!=0; amount -= sign {
            tail_candidate := head
            head += is_vertical ? {sign, 0} : {0, sign}
            diff := linalg.abs(head-tail)
            if diff[0]-diff[1] != 0  && diff[0]+diff[1] != 1{
                tail = tail_candidate
            }
            tail_been_at[tail]={}
            // windows.Sleep(1)
        }
    }
    fmt.println(len(tail_been_at))
}

main_p2 :: proc(){
    input := string(#load("input.txt"))

    tail_been_at := make(map[[2]int]struct{}, 10000)
    head: [2]int
    tail: [9][2]int

    Data :: struct {head, tail: ^[2]int, tail_been_at: map[[2]int]struct{}, current_line: string}
    data := Data{&head, &tail, tail_been_at, ""}
    thread.create_and_start_with_poly_data(&data, proc(data: ^Data){
        CANVAS_SIZE :: 2000
        rl.InitWindow(CANVAS_SIZE, CANVAS_SIZE, "Viz")
        for !rl.WindowShouldClose() {
            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            val:=false
            
            RECT_COUNT :: 200
            RECT_SIZE :: CANVAS_SIZE/RECT_COUNT

            for y in 0..<i32(RECT_COUNT) {
                for x in 0..<i32(RECT_COUNT) {
                    val = !val
                    temp: [256]u8
                    //xy := strings.clone_to_cstring(strings.join({strconv.itoa(temp[:], int(x)), strconv.itoa(temp[:], int(y))}, ","))
                    //rl.DrawText(xy, x*RECT_SIZE+RECT_SIZE/10, y*RECT_SIZE+RECT_SIZE/10, RECT_SIZE/10, rl.BLACK)
                    rl.DrawRectangle(x*RECT_SIZE, y*RECT_SIZE, RECT_SIZE, RECT_SIZE, val?rl.WHITE:rl.GRAY)
                }
                val = !val
            }
            for vall in data.tail_been_at {
                val := vall + RECT_COUNT/2
                rl.DrawRectangle(i32(val.x*RECT_SIZE), i32(val.y*RECT_SIZE), RECT_SIZE, RECT_SIZE, {255,255,0,255})
            }

            head:= data.head^+RECT_COUNT/2
            tail:= data.tail^+RECT_COUNT/2
            rl.DrawRectangle(i32(head.x*RECT_SIZE), i32(head.y*RECT_SIZE), RECT_SIZE, RECT_SIZE, {255,0,0,100})
            rl.DrawRectangle(i32(tail.x*RECT_SIZE), i32(tail.y*RECT_SIZE), RECT_SIZE, RECT_SIZE, {0,255,0,100})
            rl.DrawText(strings.clone_to_cstring(data.current_line), 0,0, 150, rl.BLACK)
            rl.EndDrawing()

        }

    })

    for line in strings.split_lines_iterator(&input) {
        data.current_line = line
        windows.Sleep(2000)
        
        is_vertical := false
        amount: int
        sign := 1
        switch line[0] {
            case 'R':
                is_vertical = true
                amount = strconv.atoi(line[2:])
            case 'L':
                is_vertical = true
                amount = -strconv.atoi(line[2:])
                sign = -1
            case 'D':
                amount = strconv.atoi(line[2:])
            case 'U':
                amount = -strconv.atoi(line[2:])
                sign = -1
        }

        for ; amount!=0; amount -= sign {
            tail_candidate := head
            head += is_vertical ? {sign, 0} : {0, sign}
            
            diff := linalg.abs(head-tail[0])
            if diff[0]-diff[1] != 0  && diff[0]+diff[1] != 1{
                tail[0] = tail_candidate
            }

            for i in 1..<9 {
                
            }

            tail_been_at[tail[8]]={}
            windows.Sleep(500)
        }
    }
    fmt.println(len(tail_been_at))
}