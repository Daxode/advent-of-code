package aoc_12

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:math"
import "core:container/priority_queue"
import "core:thread"
import "core:sys/windows"
import "core:time"

main :: proc() {
    fmt.println("Day 12")
    main_p1()
    main_p2()
    fmt.println()
}

Node :: struct {
    index_camefrom: int,
    g_score, f_score: f32,
}

main_p1 :: proc() {
    input := #load("input.txt")
    
    // get the start and end points
    start := 0
    end := 0
    for c, i in input {
        if c == 'S' {
            start = i
        } else if c == 'E' {
            end = i
        }
    }
    
    // make sure not to change user_index
    context.user_index = end
    h :: proc(a: int) -> f32 {
        b := context.user_index
        vec_a := [2]int{a % 66, a / 66}
        vec_b := [2]int{b % 66, b / 66}
        return linalg.length2(linalg.to_f32(vec_a - vec_b))
    }
    
    open: priority_queue.Priority_Queue(int)
    priority_queue.init(&open, proc(a, b: int) -> bool { 
        nodes := (^map[int]Node)(context.user_ptr)
        return nodes[a].f_score < nodes[b].f_score
    }, priority_queue.default_swap_proc(int))
    nodes := make(map[int]Node, len(input))
    context.user_ptr = &nodes
    
    nodes[start] = Node{index_camefrom = -1, g_score = 0, f_score = h(start)}
    priority_queue.push(&open, start)
    
    // Data :: struct {input: []u8, nodes: ^map[int]Node}
    // data := Data{input, &nodes}
    // thread.create_and_start_with_poly_data(&data, proc(data: ^Data){
        //     rl.InitWindow(2048, 2048, "AoC 12")
        //     image := rl.LoadImage("../aoc_12/basic.png")
        //     defer rl.UnloadImage(image)
        //     texture_dirt := rl.LoadTextureFromImage(image)
        //     defer rl.UnloadTexture(texture_dirt)
        
        //     cam: rl.Camera3D = {
            //         position = rl.Vector3{0, 200, -100},
            //         target = rl.Vector3{0, 0, 0},
            //         up = rl.Vector3{0, 1, 0},
            //         fovy = 45,
            //         projection = .PERSPECTIVE,
            //     }
            //     rl.SetCameraMode(cam, .ORBITAL)
            //     rl.SetTargetFPS(60)
            
            //     for !rl.WindowShouldClose() {
                //         rl.UpdateCamera(&cam)
                
                //         rl.BeginDrawing()
                //         rl.ClearBackground({40, 30, 10, 255})
                //         rl.BeginMode3D(cam)
                //         for y in 0..<41 {
                    //             for x in 0..<64 {
                        //                 input_val := data.input[y*66+x]
                        //                 current_height := input_val=='S' ? 0 : input_val=='E' ? 'z'-'a' : input_val - 'a'
                        //                 pos := rl.Vector3{f32(x)-64/2, 0.5, f32(y)-41/2}
                        
                        //                 rl.DrawCubeTexture(texture_dirt, pos+{0,(f32(current_height)/2)-0.5,0}, 1, f32(current_height), 1, rl.ColorFromHSV(f32(current_height)*20, 1, 1))
                        //                 for i in 0..<current_height {
    //                     rl.DrawCubeWires(pos + {0, f32(i), 0}, 1, 1, 1, rl.BROWN)
    //                 }
    
    //                 if input_val == 'S' {
        //                     rl.DrawSphere(pos, 0.5, rl.PURPLE)
        //                 } else if input_val == 'E' {
            //                     rl.DrawSphere(pos + {0, 'z'-'a', 0}, 0.5, rl.GREEN)
            //                 }
            
            //                 nodes := data.nodes
            
            //                 draw open set
            //                 current_index := y*66+x
            //                 if current_index in nodes {
                //                     rl.DrawPlane(pos+{0,f32(current_height)-0.5,0}, {1, 1}, rl.BLUE)
                //                 }
                
                //                 draw the path
                //                 if input_val == 'E' && current_index in nodes {
                    //                     for current_index != -1 {
                        //                         rl.DrawPlane(pos+{0,f32(current_height)-0.2,0}, {1, 1}, rl.RED)
                        //                         current_index = nodes[current_index].index_camefrom
                        //                         if current_index != -1 {
                            //                             current_height = data.input[current_index]=='S' ? 0 : data.input[current_index]=='E' ? 'z'-'a' : data.input[current_index] - 'a'
    //                             pos = rl.Vector3{f32(current_index%66)-64/2, 0.5, f32(current_index/66)-41/2}
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //         rl.EndMode3D()
    //         rl.EndDrawing()
    //     }
    
    //     rl.CloseWindow()
    // })
    
    for priority_queue.len(open) > 0 {
        current := priority_queue.pop(&open)
        
        // we found the end
        if current == end {
            count := 1
            for current != -1 {
                current = nodes[current].index_camefrom
                count += 1
            }
            fmt.println(count)
            break
        }

        // get the neighbors
        neighbors := [4]int{current-1, current+1, current-66, current+66}

        // check the neighbors
        for neighbor in neighbors {
            // check if the neighbor is valid
            if neighbor < 0 || neighbor >= len(input) {
                continue
            }

            // check if the neighbor is a wall
            if input[neighbor] == '\r' || input[neighbor] == '\n' {
                continue
            }

            // can only go up 1 level
            current_height := input[current]=='S' ? 'a' : input[current]=='E' ? 'z' : input[current]
            if i32(input[neighbor])-i32(current_height)> 1 { 
                continue
            }
            
            // check if the neighbor is in the open set
            if neighbor not_in nodes {
                nodes[neighbor] = {g_score = max(f32), f_score = max(f32)}
            }

            // check if the neighbor is better
            tentative_g_score := nodes[current].g_score + 1
            if tentative_g_score >= nodes[neighbor].g_score {
                continue
            }

            // update the neighbor
            neighbor_node := Node {
                index_camefrom = current,
                g_score = tentative_g_score,
                f_score = tentative_g_score + h(neighbor),
            }
            nodes[neighbor] = neighbor_node
            priority_queue.push(&open, neighbor)
        }
    }

    // for {
    //     windows.Sleep(100)
    // }
}

main_p2 :: proc() {
    input := #load("input.txt")
    
    // get the start and end points
    start := make([dynamic]int, 0, 100)
    end := 0
    for c, i in input {
        if c == 'S' || c == 'a' {
            append(&start, i)
        } else if c == 'E' {
            end = i
        }
    }
    
    // make sure not to change user_index
    context.user_index = end
    h :: proc(a: int) -> f32 {
        b := context.user_index
        vec_a := [2]int{a % 66, a / 66}
        vec_b := [2]int{b % 66, b / 66}
        return linalg.length2(linalg.to_f32(vec_a - vec_b))
    }
    
    open: priority_queue.Priority_Queue(int)
    priority_queue.init(&open, proc(a, b: int) -> bool { 
        nodes := (^map[int]Node)(context.user_ptr)
        return nodes[a].f_score < nodes[b].f_score
    }, priority_queue.default_swap_proc(int))
    nodes := make(map[int]Node, len(input))
    context.user_ptr = &nodes
    
    lowest := max(int)
    for start_point in start {
        priority_queue.clear(&open)
        clear(&nodes)
        nodes[start_point] = Node{index_camefrom = -1, g_score = 0, f_score = h(start_point)}
        priority_queue.push(&open, start_point)
        
        for priority_queue.len(open) > 0 {
            current := priority_queue.pop(&open)
            
            // we found the end
            if current == end {
                count := 1
                for current != -1 {
                    current = nodes[current].index_camefrom
                    count += 1
                }
                lowest = min(lowest, count)
                break
            }
    
            // get the neighbors
            neighbors := [4]int{current-1, current+1, current-66, current+66}
    
            // check the neighbors
            for neighbor in neighbors {
                // check if the neighbor is valid
                if neighbor < 0 || neighbor >= len(input) {
                    continue
                }
    
                // check if the neighbor is a wall
                if input[neighbor] == '\r' || input[neighbor] == '\n' {
                    continue
                }
    
                // can only go up 1 level
                current_height := input[current]=='S' ? 'a' : input[current]=='E' ? 'z' : input[current]
                if i32(input[neighbor])-i32(current_height)> 1 { 
                    continue
                }
                
                // check if the neighbor is in the open set
                if neighbor not_in nodes {
                    nodes[neighbor] = {g_score = max(f32), f_score = max(f32)}
                }
    
                // check if the neighbor is better
                tentative_g_score := nodes[current].g_score + 1
                if tentative_g_score >= nodes[neighbor].g_score {
                    continue
                }
    
                // update the neighbor
                neighbor_node := Node {
                    index_camefrom = current,
                    g_score = tentative_g_score,
                    f_score = tentative_g_score + h(neighbor),
                }
                nodes[neighbor] = neighbor_node
                priority_queue.push(&open, neighbor)
            }
        }
    }
    fmt.println(lowest)
}