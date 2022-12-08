package aoc_2

import "core:strings"
import "core:fmt"

main :: proc(){
    fmt.println("Day 2")
    main_p1()
    main_p2_v2()
    fmt.println()
}

main_p1 :: proc(){
    input := string(#load("input.txt"))
    score: u32 = 0
    for line in strings.split_lines_iterator(&input) {
        them := line[0]-'A'
        me := line[2]-'X'
        score += u32(me+1)
        if (them==me){
            score += 3
        } else if ((them+1)%3==me) {
            score += 6
        }
    }

    fmt.println(score)
}

main_p2 :: proc(){
    input := string(#load("input.txt"))
    score: u32 = 0
    for line in strings.split_lines_iterator(&input) {
        them := line[0]-'A'
        game_state := line[2]-'X'
        score += u32(game_state*3)
        if (game_state==1){
            score += u32(them+1)
        } else if (game_state==2) {
            score += u32(((them+1)%3)+1)
        } else {
            score += u32(((them+2)%3)+1)
        }
    }

    fmt.println(score)
}

main_p2_v2 :: proc(){
    input := string(#load("input.txt"))
    score: u32 = 0
    for line in strings.split_lines_iterator(&input) {
        them := line[0]-'A'
        game_state := line[2]-'X'
        offset := (game_state+2)%3
        score += u32(game_state*3)
        score += u32(((them+offset)%3)+1)
    }

    fmt.println(score)
}