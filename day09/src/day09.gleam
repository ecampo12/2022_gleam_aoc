import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.row + p2.row, p1.col + p2.col)
}

fn distance(p1: Point, p2: Point) -> Float {
  let assert Ok(dr) = int.power(p1.row - p2.row, 2.0)
  let assert Ok(dc) = int.power(p1.col - p2.col, 2.0)
  float.square_root(dr +. dc) |> result.unwrap(0.0)
}

fn traverse(
  head: Point,
  tail: Point,
  visited: Set(Point),
  dir: Point,
  steps: Int,
  max_distance: Float,
) -> #(Point, Point, Set(Point)) {
  case steps == 0 {
    True -> #(head, tail, visited)
    False -> {
      let new_head = add(head, dir)
      case distance(new_head, tail) >=. max_distance {
        False -> traverse(new_head, tail, visited, dir, steps - 1, max_distance)
        True -> {
          let tail = head
          let update_visit = set.insert(visited, tail)
          traverse(new_head, tail, update_visit, dir, steps - 1, max_distance)
        }
      }
    }
  }
}

// Idea: we move the head around like normal, and we only move the tail if it is more than one space away from the head.
// We will move the tail to the previous position of the head, so we will need to keep track of the previous head position.
pub fn part1(input: String) -> Int {
  let head = Point(0, 0)
  let tail = Point(0, 0)
  let tail_visit = [Point(0, 0)] |> set.from_list
  let #(_, _, visited) =
    string.split(input, "\n")
    |> list.fold(#(head, tail, tail_visit), fn(acc, dir) {
      let #(head, tail, tail_visit) = acc
      case string.split(dir, " ") {
        [dir, steps] -> {
          let assert Ok(steps) = int.parse(steps)
          case dir {
            "U" -> traverse(head, tail, tail_visit, Point(-1, 0), steps, 2.0)
            "D" -> traverse(head, tail, tail_visit, Point(1, 0), steps, 2.0)
            "R" -> traverse(head, tail, tail_visit, Point(0, 1), steps, 2.0)
            "L" -> traverse(head, tail, tail_visit, Point(0, -1), steps, 2.0)
            _ -> acc
          }
        }
        _ -> acc
      }
    })
  set.size(visited)
}

pub fn part2(input: String) -> Int {
  let head = Point(0, 0)
  let tail = Point(0, 0)
  let tail_visit = [Point(0, 0)] |> set.from_list
  let #(_, _, visited) =
    string.split(input, "\n")
    |> list.fold(#(head, tail, tail_visit), fn(acc, dir) {
      let #(head, tail, tail_visit) = acc
      case string.split(dir, " ") {
        [dir, steps] -> {
          let assert Ok(steps) = int.parse(steps)
          case dir {
            "U" -> traverse(head, tail, tail_visit, Point(-1, 0), steps, 10.0)
            "D" -> traverse(head, tail, tail_visit, Point(1, 0), steps, 10.0)
            "R" -> traverse(head, tail, tail_visit, Point(0, 1), steps, 10.0)
            "L" -> traverse(head, tail, tail_visit, Point(0, -1), steps, 10.0)
            _ -> acc
          }
        }
        _ -> acc
      }
    })
  set.size(visited)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
