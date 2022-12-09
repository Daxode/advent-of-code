package aoc_7

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
    main_p1()
}

main_p1 :: proc() {
    input := string(#load("input.txt"))
    is_ls := false
    current_dir_size := 0
    path: [dynamic]string
    for line in strings.split_lines_iterator(&input) {
        if line[0] == '$' {
            if is_ls {
                fmt.println("folder size:",current_dir_size)
                is_ls = false
                current_dir_size = 0
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
                            fmt.println(path)
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
}