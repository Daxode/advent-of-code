package aoc_5

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:mem"

main :: proc(){
    fmt.println("Day 5")
    main_p1()
    main_p2()
    fmt.println()
}

main_p1 :: proc(){
    input := string(#load("input.txt"))
    line_index := 0
    stacks: [9][dynamic]u8
    for line in strings.split_lines_iterator(&input) {
        if (line_index < 8){
            // parse stacks
            for i in 0..<9 {
                val := line[(i*4)+1]
                if val != ' ' {
                    append(&stacks[i],val)
                }
            }
            line_index+=1
            if (line_index == 8) {
                for stack in stacks {
                    slice.reverse(stack[:])
                }
                strings.split_lines_iterator(&input) 
                strings.split_lines_iterator(&input)
            }
        } else {
            // parse instructions
            amount,from,to:int
            segment_iterator := line
            segment_index := 0
            for segment in strings.split_by_byte_iterator(&segment_iterator, ' ') {
                switch segment_index {
                    case 1:
                        amount = strconv.atoi(segment)
                    case 3:
                        from = strconv.atoi(segment)
                    case 5:
                        to = strconv.atoi(segment)
                }
                segment_index+=1
            }

            // Small crane
            for i in 0..<amount {
                append(&stacks[to-1], pop(&stacks[from-1]))
            }
        }
    }
    for stack in stacks {
        fmt.print(rune(stack[len(stack)-1]))
    }
    fmt.println()
}

main_p2 :: proc(){
    input := string(#load("input.txt"))
    line_index := 0

    stacks: [9][dynamic]u8
    for line in strings.split_lines_iterator(&input) {
        if (line_index < 8){
            // parse stacks
            for i in 0..<9 {
                val := line[(i*4)+1]
                if val != ' ' {
                    append(&stacks[i],val)
                }
            }
            line_index+=1
            if (line_index == 8) {
                for stack in stacks {
                    slice.reverse(stack[:])
                }
                strings.split_lines_iterator(&input) 
                strings.split_lines_iterator(&input)
            }
        } else {
            // parse instructions
            amount,from,to:int
            segment_iterator := line
            segment_index := 0
            for segment in strings.split_by_byte_iterator(&segment_iterator, ' ') {
                switch segment_index {
                    case 1:
                        amount = strconv.atoi(segment)
                    case 3:
                        from = strconv.atoi(segment)
                    case 5:
                        to = strconv.atoi(segment)
                }
                segment_index+=1
            }

            // Big Crane
            amount = min(amount, len(stacks[from-1]))
            old_length := len(stacks[to-1])
            new_length := len(stacks[from-1])-amount
            resize(&stacks[to-1], old_length+amount)
            copy(stacks[to-1][old_length:], stacks[from-1][new_length:])
            resize(&stacks[from-1], new_length)
        }
    }

    for stack in stacks {
        fmt.print(rune(stack[len(stack)-1]))
    }
    fmt.println()
}