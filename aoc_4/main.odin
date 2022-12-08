package aoc_4

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc(){
    main_p2()
}

main_p1 :: proc(){
    input := string(#load("input.txt"))
    score:=0
    for line_current in strings.split_lines_iterator(&input) {
        line:=line_current
        vals: [4]int
        i: int
        for elf_current in strings.split_by_byte_iterator(&line, ',') {
            elf:=elf_current
            for table in strings.split_by_byte_iterator(&elf, '-') {
                vals[i] = strconv.atoi(table)
                i+=1
            }
        }

        if ((vals[0] >= vals[2] && vals[1] <= vals[3]) || (vals[2] >= vals[0] && vals[3] <= vals[1])){
            score+=1
        }
    }
    fmt.println(score)
}

main_p2 :: proc(){
    input := string(#load("input.txt"))
    score:=0
    for line_current in strings.split_lines_iterator(&input) {
        line:=line_current
        vals: [4]int
        i: int
        for elf_current in strings.split_by_byte_iterator(&line, ',') {
            elf:=elf_current
            for table in strings.split_by_byte_iterator(&elf, '-') {
                vals[i] = strconv.atoi(table)
                i+=1
            }
        }

        if (
            (vals[0] >= vals[2] && vals[0] <= vals[3]) || 
            (vals[1] >= vals[2] && vals[1] <= vals[3]) ||
            (vals[2] >= vals[0] && vals[2] <= vals[1]) || 
            (vals[3] >= vals[0] && vals[3] <= vals[1])){
            score+=1
        }
    }
    fmt.println(score)
}