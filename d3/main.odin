package day3

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"

input : string : #load("input.txt")

part1 :: proc() {
    fmt.println("Day 3 Part 1")

    input_cpy := input
    line_iter := &input_cpy
    sum := 0
    for line in strings.split_lines_iterator(line_iter) {
        line_iter := line

        mul_index := 1 
        for mul_index >= 0 {
            mul_index := strings.index(line_iter, "mul(")
            if (len(line_iter) < 4){break;}
            
            line_iter = line_iter[mul_index+4:]
            //fmt.println(line_iter)            
            to_comma_index := 1
            param_first_val := 0
            is_num := true
            for is_num {
                param_first_val, is_num = strconv.parse_int(line_iter[:to_comma_index])
                //fmt.println(line_iter[:to_comma_index])
                to_comma_index += 1
            }
            if (line_iter[to_comma_index-2] != ',')
            {
                continue;
            }

            to_parenthesis_index := to_comma_index+0
            is_num = true
            param_second_val := 0
            for is_num {
                param_second_val, is_num = strconv.parse_int(line_iter[to_comma_index-1:to_parenthesis_index])
                //fmt.println(line_iter[to_comma_index-1:to_parenthesis_index])
                to_parenthesis_index += 1
            }

            if line_iter[to_parenthesis_index-2] != ')' {
                continue;
            }
            
    
            // to_comma_index := strings.index_byte(line_iter, ',')
            // to_parenthesis_index := strings.index_byte(line_iter, ')')
            // if (to_comma_index > to_parenthesis_index)
            // {
            //     continue;
            // }

            // fmt.println(to_comma_index, to_parenthesis_index)
            // param_first := line_iter[:to_comma_index]
            // param_second := line_iter[to_comma_index+1:to_parenthesis_index]
            // param_first_val, first_is_val := strconv.parse_int(param_first)
            // param_second_val, second_is_val := strconv.parse_int(param_second)

            sum += param_first_val * param_second_val
            fmt.println(param_first_val, param_second_val)
        }
    }
    fmt.println(sum)
}

part2 :: proc() {
    fmt.println("Day 3 Part 2")

    input_cpy := input
    line_iter := &input_cpy
    sum := 0
    is_enabled := true;
    for line in strings.split_lines_iterator(line_iter) {
        line_iter := line

        mul_index := 1 
        for mul_index >= 0 {
            mul_index := strings.index(line_iter, "mul(")
            dont_index := strings.index(line_iter, "don't()")
            do_index := strings.index(line_iter, "do()")
            if (is_enabled && mul_index > dont_index && dont_index < do_index) {
                is_enabled = false;
            }
            if (!is_enabled && mul_index > do_index && dont_index > do_index)
            {
                is_enabled = true;
            }
            if (len(line_iter) < 4){break;}            

            line_iter = line_iter[mul_index+4:]
            
            to_comma_index := 1
            param_first_val := 0
            is_num := true
            for is_num {
                param_first_val, is_num = strconv.parse_int(line_iter[:to_comma_index])
                //fmt.println(line_iter[:to_comma_index])
                to_comma_index += 1
            }
            if (line_iter[to_comma_index-2] != ',')
            {
                continue;
            }

            to_parenthesis_index := to_comma_index+0
            is_num = true
            param_second_val := 0
            for is_num {
                param_second_val, is_num = strconv.parse_int(line_iter[to_comma_index-1:to_parenthesis_index])
                //fmt.println(line_iter[to_comma_index-1:to_parenthesis_index])
                to_parenthesis_index += 1
            }

            if line_iter[to_parenthesis_index-2] != ')' {
                continue;
            }

            if is_enabled {
                sum += param_first_val * param_second_val
            }
            fmt.println(param_first_val, param_second_val, is_enabled)
        }
    }
    fmt.println(sum)
}