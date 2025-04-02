import gary.{type ErlangArray}
import gary/array
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

fn update_rope(rope: ErlangArray(Point)) -> ErlangArray(Point) {
  let len = array.get_size(rope)
  list.range(0, len - 2)
  |> list.fold(rope, fn(bcc, i) {
    let assert Ok(head) = bcc |> array.get(i)
    let assert Ok(tail) = bcc |> array.get(i + 1)
    let dx = head.row - tail.row
    let dy = head.col - tail.col
    let tail = case int.absolute_value(dx) > 1 || int.absolute_value(dy) > 1 {
      True -> {
        case dx == 0, dy == 0 {
          True, _ -> add(tail, Point(0, dy / 2))
          _, True -> add(tail, Point(dx / 2, 0))
          _, _ -> {
            case dx > 0, dy > 0 {
              True, True -> Point(1, 1)
              True, False -> Point(1, -1)
              False, True -> Point(-1, 1)
              False, False -> Point(-1, -1)
            }
            |> add(tail)
          }
        }
      }
      False -> tail
    }
    bcc
    |> array.set(i + 1, tail)
    |> result.unwrap(array.create(Point(-1, 1)))
  })
}

fn traverse(
  rope: ErlangArray(Point),
  visited: Set(Point),
  dir: Point,
  steps: Int,
) -> #(ErlangArray(Point), Set(Point)) {
  let len = array.get_size(rope)
  list.range(1, steps)
  |> list.fold(#(rope, visited), fn(acc, _) {
    let assert Ok(head) = acc.0 |> array.get(0)
    let new_head = add(head, dir)
    let assert Ok(new_rope) = acc.0 |> array.set(0, new_head)
    let new_rope = update_rope(new_rope)
    let assert Ok(tail) = new_rope |> array.get(len - 1)
    let visited = set.insert(acc.1, tail)
    #(new_rope, visited)
  })
}

fn simulate(input: String, rope_length: Int) -> Int {
  let assert Ok(rope) = array.create_fixed_size(rope_length, Point(0, 0))

  let tail_visit = [Point(0, 0)] |> set.from_list
  let #(_, visited) =
    string.split(input, "\n")
    |> list.fold(#(rope, tail_visit), fn(acc, dir) {
      let #(rope, tail_visit) = acc
      case string.split(dir, " ") {
        [dir, steps] -> {
          let assert Ok(steps) = int.parse(steps)
          case dir {
            "U" -> traverse(rope, tail_visit, Point(-1, 0), steps)
            "D" -> traverse(rope, tail_visit, Point(1, 0), steps)
            "R" -> traverse(rope, tail_visit, Point(0, 1), steps)
            "L" -> traverse(rope, tail_visit, Point(0, -1), steps)
            _ -> acc
          }
        }
        _ -> acc
      }
    })
  set.size(visited)
}

pub fn part1(input: String) -> Int {
  simulate(input, 2)
}

pub fn part2(input: String) -> Int {
  simulate(input, 10)
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
