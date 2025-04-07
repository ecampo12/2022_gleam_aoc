import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

type Point {
  Point(x: Int, y: Int)
}

type Info {
  Info(sensor: Point, beacon: Point, distance: Int)
}

type Interval {
  Interval(min: Int, max: Int)
}

fn size(i: Interval) -> Int {
  i.max - i.min + 1
}

fn merge(inter1: Interval, inter2: Interval) -> Interval {
  Interval(int.min(inter1.min, inter2.min), int.max(inter1.max, inter2.max))
}

fn touching(inter1: Interval, inter2: Interval) -> Bool {
  case inter2.min < inter1.min {
    True -> inter1.min - inter2.max <= 1
    False -> inter2.min - inter1.max <= 1
  }
}

fn parse(input: String) -> List(Info) {
  let assert Ok(re) = regexp.from_string("-?\\d+")
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert [x1, y1, x2, y2] =
      regexp.scan(re, line)
      |> list.map(fn(x) { int.parse(x.content) |> result.unwrap(-1) })
    Info(
      Point(x1, y1),
      Point(x2, y2),
      int.absolute_value(x1 - x2) + int.absolute_value(y1 - y2),
    )
  })
}

fn build(infos: List(Info), y: Int) -> List(Interval) {
  list.fold(infos, [], fn(acc, info) {
    let extra = info.distance - int.absolute_value(info.sensor.y - y)
    case extra < 0 {
      True -> acc
      False -> {
        let next = Interval(info.sensor.x - extra, info.sensor.x + extra)
        let #(in, out) = list.partition(acc, fn(x) { touching(x, next) })
        list.fold(in, next, fn(acc, n) { merge(acc, n) })
        |> list.prepend(out, _)
      }
    }
  })
}

pub fn part1(input: String, row: Int) -> Int {
  let info = parse(input)
  let assert Ok(head) = build(info, row) |> list.first
  size(head)
  - {
    list.map(info, fn(x) { x.beacon })
    |> list.filter(fn(b) { b.y == row })
    |> list.unique
    |> list.length
  }
}

fn tune_frequency(info: List(Info), row: Int) -> Int {
  case build(info, row) {
    [a, b] -> { 4_000_000 * { int.min(a.max, b.max) + 1 } } + row
    _ -> tune_frequency(info, row + 1)
  }
}

pub fn part2(input: String) -> Int {
  parse(input) |> tune_frequency(0)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input, 2_000_000)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
