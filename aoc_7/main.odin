package aoc_7

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:text/edit"

main :: proc() {
    main_p1()
}

AT_MOST :: 100000

main_p1 :: proc() {
    input := string(#load("input.txt"))
    is_ls := false
    current_dir_size := 0
    path: [dynamic]string
    sum: [20]int
    result:=0
    last_path_index := 0
    until_out:=0
    for line in strings.split_lines_iterator(&input) {
        if line[0] == '$' {
            if is_ls {
                current_path_index := len(path)-1

                if last_path_index > current_path_index {
                    it := sum[current_path_index:last_path_index+1]
                    for elem in &it {
                        if elem <= AT_MOST {
                            result += elem
                        }
                        elem = 0
                    }
                    fmt.println(sum)
                } else if last_path_index == current_path_index {
                    if sum[current_path_index] <= AT_MOST {
                        result += sum[current_path_index]
                    }
                }

                it := sum[:current_path_index]
                for elem in &it {
                    elem += current_dir_size
                }
                sum[current_path_index] = current_dir_size

                fmt.println(strings.join(path[:],"/"))
                fmt.println(sum, current_dir_size)
                fmt.println()

                is_ls = false
                current_dir_size = 0
                last_path_index = current_path_index
            }

            switch line[2:4] {
                case "ls":
                    is_ls = true
                case "cd":
                    switch line[5:] {
                        case "..":
                            resize(&path, len(path)-1)
                        case:
                            append(&path, line[5:])
                    }
            }
        } else {
            it := line
            size_string, _ := strings.split_by_byte_iterator(&it,' ')
            if size_string != "dir" {
                current_dir_size += strconv.atoi(size_string)
            }
        }
    }

    if current_dir_size <= AT_MOST {
        result+=current_dir_size
    }
    it := sum[:len(path)-1]
    for elem in &it {
        elem += current_dir_size
    }

    fmt.println(result)
}