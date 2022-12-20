package aoc_9

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math/linalg"

import rl "vendor:raylib"
import "core:sys/windows"
import "core:thread"

main :: proc() {
    main_p1()
}



main_p1 :: proc(){
    input := string(#load("input.txt"))

    tail_been_at := make(map[[2]int]struct{}, 10000)
    head, tail: [2]int

    Data :: struct {head, tail: ^[2]int, tail_been_at: map[[2]int]struct{}}
    data := Data{&head, &tail, tail_been_at}
    thread.create_and_start_with_poly_data(&data, proc(data: ^Data){
        rl.InitWindow(2000, 2000, "Viz")
        for !rl.WindowShouldClose() {
            rl.ClearBackground(rl.BLACK)
            rl.BeginDrawing()
            val:=false
            for y in 0..<i32(50) {
                for x in 0..<i32(50) {
                    val = !val
                    rl.DrawRectangle(x*40, y*40, 40, 40, val?rl.WHITE:rl.GRAY)
                }
                val = !val
            }
            for vall in data.tail_been_at {
                val := vall + 25
                rl.DrawRectangle(i32(val.x*40), i32(val.y*40), 40, 40, {255,255,0,255})
            }

            head:= data.head^+25
            tail:= data.tail^+25
            rl.DrawRectangle(i32(head.x*40), i32(head.y*40), 40, 40, {255,0,0,100})
            rl.DrawRectangle(i32(tail.x*40), i32(tail.y*40), 40, 40, {0,255,0,100})
            rl.EndDrawing()

        }

    })

    for line in strings.split_lines_iterator(&input) {
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
            if diff[0]+diff[1] > 2 || diff[0]>0&&diff[1]==0 || diff[1]>0&&diff[0]==0 {
                tail = tail_candidate
            }
            tail_been_at[tail]={}
            windows.Sleep(50)
        }
    }
    fmt.println(len(tail_been_at))
}