package aoc_3

import "core:strings"
import "core:fmt"
import "core:bytes"

main :: proc(){
    main_p2()
}

main_p1 :: proc(){
    input := string(#load("input.txt"))
    score: u32
    for line in strings.split_lines_iterator(&input) {
        half_line_length := len(line)/2
        for current_byte in transmute([]byte) line[half_line_length:] {
            if (strings.index_byte(line[:half_line_length], current_byte) != -1){
                score += current_byte >= 'a' ? u32(current_byte-'a'+1) : u32(current_byte-'A'+27)
                break
            }
        }
    }
    fmt.println(score)
}

main_p2 :: proc(){
    input := string(#load("input.txt"))
    score: u32
    index: u16
    buffer: [dynamic]u8
    first_line: string
    for line in strings.split_lines_iterator(&input) {
        switch index%3 {
            case 0:
                first_line = line
            case 1:
                for current_byte in transmute([]byte) line {
                    if (strings.index_byte(first_line, current_byte) != -1){
                        append(&buffer, current_byte)
                    }
                }
            case 2:
                for current_byte in buffer {
                    if (strings.index_byte(line, current_byte) != -1){
                        // fmt.println(rune(current_byte), current_byte >= 'a' ? u32(current_byte-'a'+1) : u32(current_byte-'A'+27), buffer)
                        score += current_byte >= 'a' ? u32(current_byte-'a'+1) : u32(current_byte-'A'+27)
                        break
                    }
                }
                clear(&buffer)
        }
        index+=1
    }
    fmt.println(score)
}