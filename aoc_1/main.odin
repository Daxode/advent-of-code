package aoc_1

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

main :: proc(){
    fmt.println("Day 1")
    main_p1()
    main_p2()
    fmt.println()
}

main_p1 :: proc(){
    input := string(#load("input.txt"))
    max_sum := 0
    sum := 0
    for line in strings.split_lines_iterator(&input) {
        if (line != ""){
            sum += strconv.atoi(line)
        } else {
            max_sum = max(max_sum, sum)
            sum=0
        }
    }
    fmt.println(max_sum)
}

main_p2 :: proc(){
    input := string(#load("input.txt"))
    max_sum := [3]int{0,0,0}

    sum := 0
    for line in strings.split_lines_iterator(&input) {
        if (line != ""){
            sum += strconv.atoi(line)
        } else {
           max_sum[2] = sum >= max_sum[0] || sum >= max_sum[1] || sum >= max_sum[2] ? sum : max_sum[2]

           if (max_sum[2] > max_sum[1]){
               temp := max_sum[2]
               max_sum[2] = max_sum[1]
               max_sum[1] = temp
           }

           if (max_sum[1] > max_sum[0]){
                temp := max_sum[1]
                max_sum[1] = max_sum[0]
                max_sum[0] = temp
            }

            sum=0
        }
    }
    fmt.println(max_sum[0]+max_sum[1]+max_sum[2])
}