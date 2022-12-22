package aoc_11

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:sort"
import "core:slice"

main :: proc() {
    fmt.println("Day 11")
    main_p1()
    main_p2()
    fmt.println()
}

Monkey :: struct {
    items: [dynamic]u64,
    operation: MonkeyOperation,
    lhs, rhs: i64,
    test_divisor: u64,
    test_true, test_false: u64,
}

MonkeyOperation :: enum {
    multiply,
    add,
}

gimme_monkeys :: proc() -> [8]Monkey {
    input := string(#load("input.txt"))
    monkey_items: [8]Monkey

    i := 0
    for line in strings.split_lines_iterator(&input) {
        monkey_index := i/7
        switch i%7 {
            case 1:
                iter := line[18:]
                for item in strings.split_iterator(&iter, ", ") {
                    append(&monkey_items[monkey_index].items, u64(strconv.atoi(item)))
                }
            case 2:
                iter := line[19:]
                lhs, _ := strings.split_iterator(&iter, " ")
                operator, _ := strings.split_iterator(&iter, " ")
                rhs := iter

                monkey_items[monkey_index].lhs = lhs == "old" ? -1 : i64(strconv.atoi(lhs))
                monkey_items[monkey_index].rhs = rhs == "old" ? -1 : i64(strconv.atoi(rhs))
                monkey_items[monkey_index].operation = operator == "*" ? MonkeyOperation.multiply : MonkeyOperation.add
            case 3:
                monkey_items[monkey_index].test_divisor = u64(strconv.atoi(line[21:]))
            case 4:
                monkey_items[monkey_index].test_true = u64(strconv.atoi(line[29:]))
            case 5:
                monkey_items[monkey_index].test_false = u64(strconv.atoi(line[30:]))
            case:
        }
        i += 1
    }

    return monkey_items
}

main_p1 :: proc() {
    monkeys := gimme_monkeys()
    monkey_inspection_counts: [8]u64

    // fmt.println("round 0")
    // for monkey, i in monkeys {
    //     fmt.println("Monkey", i, monkey.items)
    // }

    for round in 0..<20 {
        for monkey, i in &monkeys {
            for old_item in monkey.items {
                monkey_inspection_counts[i] += 1
                lhs := monkey.lhs == -1 ? old_item : u64(monkey.lhs)
                rhs := monkey.rhs == -1 ? old_item : u64(monkey.rhs)
                new_item := monkey.operation == MonkeyOperation.multiply ? lhs * rhs : lhs + rhs
                new_item /= 3
                monkey_to_throw_at := new_item % monkey.test_divisor == 0 ? monkey.test_true : monkey.test_false
                append(&monkeys[monkey_to_throw_at].items, new_item)
            }
            clear(&monkey.items)
        }
        // fmt.println("round", round)
        // for monkey, i in monkeys {
        //     fmt.println("Monkey", i, monkey.items)
        // }
    }

    sort.bubble_sort(monkey_inspection_counts[:])
    fmt.println(monkey_inspection_counts[len(monkey_inspection_counts)-1] * monkey_inspection_counts[len(monkey_inspection_counts)-2])
}

main_p2 :: proc() {
    monkeys := gimme_monkeys()
    monkey_inspection_counts: [8]u64

    divisor: u64 = 1
    for monkey in monkeys {
        divisor *= monkey.test_divisor
    }

    for round in 1..=10000 {
        for monkey, i in &monkeys {
            for old_item in monkey.items {
                monkey_inspection_counts[i] += 1
                lhs := monkey.lhs == -1 ? old_item : u64(monkey.lhs)
                rhs := monkey.rhs == -1 ? old_item : u64(monkey.rhs)
                new_item := monkey.operation == MonkeyOperation.multiply ? lhs * rhs : lhs + rhs
                new_item %= divisor
                monkey_to_throw_at := new_item % monkey.test_divisor == 0 ? monkey.test_true : monkey.test_false
                append(&monkeys[monkey_to_throw_at].items, new_item)
            }
            clear(&monkey.items)
        
        }

        // if round == 1 || round == 20 || round % 1000 == 0  {
        //     fmt.println("== After Round ", round, " ==")
        //     for monkey, i in monkeys {
        //         fmt.println("Monkey", i, "inspected items", monkey_inspection_counts[i], "times.")
        //     }
        //     fmt.println()
        // }
    }

    sort.bubble_sort(monkey_inspection_counts[:])
    fmt.println(monkey_inspection_counts[len(monkey_inspection_counts)-1] * monkey_inspection_counts[len(monkey_inspection_counts)-2])
}