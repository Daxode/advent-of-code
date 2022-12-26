package aoc_13

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:runtime"
main :: proc() {
    main_p1()
}

main_p1 :: proc() {
    input := string(#load("small.txt"))

    consume_number :: proc(line: ^string, should_eat: bool) -> (number: int, success: bool) {
        number_count: int
        char := line[0]
        // as long as the char is a number, keep going
        for char-'0' >= 0 && char-'0' <= 9 {
            number_count += 1
            char = line[number_count]
        }
        number_int := strconv.atoi(string(line[:number_count]))
        if should_eat {
            line^ = line[number_count:]
        }
        return number_int, number_count > 0
    }

    consume_b :: proc(line_b: ^string, 
                      indent_b: ^int, 
                      element_indexes_b: ^[100]int, 
                      element_indexes_a: ^[100]int, 
                      indenting_down: ^int,
                      indent_a: int,
                      number_a: int,
                      line_a: string) -> (success: bool) {
        eat_b: for len(line_b) > 0 {
            if number_a == -1 {
                if indenting_down^ > 0 {
                    break eat_b
                }
            } else {
                indenting_down^ = 0
            }

            switch line_b[0] {
                case '[':
                    line_b^ = line_b[1:]
                    indent_b^ += 1
                case ']':
                    test := element_indexes_b^[indent_b^:]
                    defer for elem in &test {elem = 0}
                    defer indent_b^ -= 1
                    defer line_b^ = line_b[1:]
                    fmt.println("Line A:", line_a, "Line B:", line_b^)

                    if indent_b^ != indent_a {
                        fmt.println("FailedD", indent_b^, indent_a)
                        return false
                    } 
                    if element_indexes_a[indent_a] != element_indexes_b[indent_b^] {
                        fmt.println("FailedC", element_indexes_a[indent_a], element_indexes_b[indent_b^])
                        return false
                    }

                    fmt.println("PassedA")
                case ',':
                    line_b^ = line_b[1:]
                case:
                    fmt.println("Line A:", line_a, "Line B:", line_b^)
                    
                    indent_to_compare := indent_a
                    should_bump := element_indexes_b[indent_b^] == 0 && indent_b^ < indent_a
                    if should_bump {
                        indent_to_compare = indent_a
                    }
                    if indent_to_compare != indent_a {
                        fmt.println("FailedA",indent_to_compare, indent_a)
                        return false
                    } 
                    element_indexes_b^[indent_to_compare] += 1
                    if element_indexes_a[indent_a] > element_indexes_b[indent_to_compare] {
                        fmt.println("FailedE", element_indexes_a[indent_a], element_indexes_b[indent_to_compare])
                        return false
                    }
                    
                    number_b, found_number_b := consume_number(line_b, true)
                    if number_a <= number_b {
                        indenting_down^ = indent_a-indent_b^
                        fmt.println("PassedB", indenting_down^, indent_a, indent_b^)
                        break eat_b
                    } else {
                        fmt.println("FailedB", number_a, number_b)
                        return false
                    }
            }
        }

        return true
    }

    index:= 0
    go_to_next_line: for line_a_l in strings.split_lines_iterator(&input) {
        line_a := line_a_l
        line_b, _ := strings.split_lines_iterator(&input)
        strings.split_lines_iterator(&input)
        fmt.println()
        fmt.println("Current index:", index)
        index += 1
        
        element_indexes_a: [100]int
        indent_a := 0
        element_indexes_b: [100]int
        indent_b := 0
        indenting_down := 0
        for len(line_a) > 0 {
            char_a := line_a[0]
            switch char_a {
                case '[':
                    line_a = line_a[1:]
                    indent_a += 1
                case ']':
                    if !consume_b(&line_b, &indent_b, &element_indexes_b, &element_indexes_a, &indenting_down, indent_a, -1, line_a) {
                        continue go_to_next_line
                    }

                    
                    line_a = line_a[1:]
                    element_indexes_a[indent_a] = 0
                    indent_a -= 1
                    indenting_down -= 1
                    indenting_down = max(indenting_down, 0)
                case ',':
                    line_a = line_a[1:]
                case:
                    // Consume number
                    number_a, _ := consume_number(&line_a, true)
                    element_indexes_a[indent_a] += 1
                    if !consume_b(&line_b, &indent_b, &element_indexes_b, &element_indexes_a, &indenting_down, indent_a, number_a, line_a) {
                        continue go_to_next_line
                    }
            }
        }
    }
}