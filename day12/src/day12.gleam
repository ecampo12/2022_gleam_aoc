import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import gleamy/priority_queue.{type Queue} as pq
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.row + p2.row, p1.col + p2.col)
}

fn parse(input: String) -> Dict(Point, Int) {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(acc, row, r) {
    string.to_graphemes(row)
    |> list.index_fold(acc, fn(bcc, col, c) {
      let num = case string.to_utf_codepoints(col) {
        [val, ..] -> string.utf_codepoint_to_int(val)
        _ -> -1
      }
      dict.insert(bcc, Point(r, c), num)
    })
  })
}

const directions = [Point(-1, 0), Point(1, 0), Point(0, -1), Point(0, 1)]

fn traverse(
  points: Dict(Point, Int),
  end: Point,
  queue: Queue(#(Point, Int)),
  visited: Set(Point),
) -> Int {
  case pq.pop(queue) {
    Error(_) -> -1
    Ok(#(state, new_queue)) -> {
      let #(point, steps) = state
      case point == end, set.contains(visited, point) {
        True, _ -> steps
        False, True -> traverse(points, end, new_queue, visited)
        False, False -> {
          let visited = set.insert(visited, point)
          list.map(directions, fn(d) { add(point, d) })
          |> list.filter(fn(p) { dict.has_key(points, p) })
          |> list.fold(new_queue, fn(q, p) {
            let curr = dict.get(points, point) |> result.unwrap(-1)
            let next = dict.get(points, p) |> result.unwrap(-1)
            case { curr + 1 } >= next {
              True -> {
                pq.push(q, #(p, steps + 1))
              }
              False -> q
            }
          })
          |> traverse(points, end, _, visited)
        }
      }
    }
  }
}

fn dijstra(map: Dict(Point, Int), start: Point, end: Point) -> Int {
  let queue = pq.new(fn(a: #(Point, Int), b) { int.compare(a.1, b.1) })
  let visited = set.new()
  let start_state = #(start, 0)
  let queue = pq.push(queue, start_state)
  traverse(map, end, queue, visited)
}

pub fn part1(input: String) -> Int {
  let map = parse(input)
  let #(start, end) =
    dict.fold(map, #(Point(-1, -1), Point(-1, -1)), fn(acc, key, value) {
      case value {
        83 -> #(key, acc.1)
        69 -> #(acc.0, key)
        _ -> acc
      }
    })

  // need to update the values of start and end because the ascii value of "S" is too low to
  // reach any square. The ascii value of "E" will cuase any near by square to skip to it, resulting in a path that too short
  let map = dict.insert(map, start, 96) |> dict.insert(end, 123)
  io.debug(end)
  dijstra(map, start, end)
}

pub fn part2(input: String) -> Int {
  let map = parse(input)
  let #(end, a_list) =
    dict.fold(map, #(Point(-1, -1), []), fn(acc, key, value) {
      case value {
        69 -> #(key, acc.1)
        97 -> #(acc.0, [key, ..acc.1])
        _ -> acc
      }
    })
  let map = dict.insert(map, end, 123)
  list.map(a_list, fn(a) { dijstra(map, a, end) })
  |> list.filter(fn(x) { x != -1 })
  |> list.sort(int.compare)
  |> list.first
  |> result.unwrap(0)
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
