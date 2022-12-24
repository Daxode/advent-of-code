package aoc_13

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
    main_p1()
}

main_p1 :: proc() {
    input := string(#load("small.txt"))

    consume_number :: proc(line: ^string) -> (number: int, success: bool) {
        number_count: int
        char := line[0]
        for char-'0' >= 0 && char-'0' <= 9 {
            number_count += 1
            char = line[number_count]
        }
        number_int := strconv.atoi(string(line[:number_count]))
        line^ = line[number_count-1:]
        return number_int, number_count > 0
    }

    consume_b :: proc(line_b: ^string, 
                      indent_b: ^int, 
                      element_indexes_b: ^[100]int, 
                      element_indexes_a: ^[100]int, 
                      indent_a: int,
                      number_a: int,
                      line_a: string) -> (success: bool) {
        eat_b: for len(line_b) > 0 {
            char_b := line_b[0]
            defer line_b^ = line_b[1:]

            switch char_b {
                case '[':
                    indent_b^ += 1
                case ']':
                    element_indexes_b^[indent_b^] = 0
                    indent_b^ -= 1
                case ',':
                    element_indexes_b^[indent_b^] += 1
                case:
                    fmt.println("Line A:", line_a, "Line B:", line_b^)
                    
                    indent_higest := max(indent_a, indent_b^)
                    current_element_eqaul := element_indexes_a[indent_higest] == element_indexes_b[indent_higest]
                    if number_a == -1 && !current_element_eqaul {
                        fmt.println("Failed")
                        return false
                    } 

                    number_b, found_number_b := consume_number(line_b)


                    if found_number_b && number_a == -1 {
                        fmt.println("Failed")
                        return false
                    }

                    if current_element_eqaul {
                        if number_a <= number_b {
                            fmt.println("Passed")
                            break eat_b
                        } else {
                            fmt.println("Failed")
                            return false
                        }
                    }
            }
        }

        return true
    }

    go_to_next_line: for line_a_l in strings.split_lines_iterator(&input) {
        line_a := line_a_l
        line_b, _ := strings.split_lines_iterator(&input)
        strings.split_lines_iterator(&input)
        
        element_indexes_a: [100]int
        indent_a := -1
        element_indexes_b: [100]int
        indent_b := -1
        for len(line_a) > 0 {
            char_a := line_a[0]
            defer line_a = line_a[1:]
            switch char_a {
                case '[':
                    indent_a += 1
                case ']':
                    if !consume_b(&line_b, &indent_b, &element_indexes_b, &element_indexes_a, indent_a, -1, line_a) {
                        continue go_to_next_line
                    }

                    element_indexes_a[indent_a] = 0
                    indent_a -= 1
                case ',':
                    element_indexes_a[indent_a] += 1
                case:
                    // Consume number
                    number_a, _ := consume_number(&line_a)
                    if !consume_b(&line_b, &indent_b, &element_indexes_b, &element_indexes_a, indent_a, number_a, line_a) {
                        continue go_to_next_line
                    }
            }
        }
    }
}