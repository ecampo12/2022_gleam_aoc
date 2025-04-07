import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
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

const start = Point(500, 0)

const directions = [Point(0, 1), Point(-1, 1), Point(1, 1)]

fn parse(input: String) -> #(Set(Point), Int) {
  let assert Ok(re) = regexp.from_string("\\d+")
  let cave =
    string.split(input, "\n")
    |> list.fold(set.new(), fn(acc, line) {
      let x =
        regexp.scan(re, line)
        |> list.map(fn(x) { int.parse(x.content) |> result.unwrap(-1) })
        |> list.sized_chunk(2)
      list.zip(x, list.drop(x, 1))
      |> list.fold(acc, fn(bcc, pair) {
        let assert [x1, y1] = pair.0
        let assert [x2, y2] = pair.1
        list.range(int.min(x1, x2), int.max(x1, x2))
        |> list.flat_map(fn(r) {
          list.range(int.min(y1, y2), int.max(y1, y2))
          |> list.map(fn(c) { Point(r, c) })
        })
        |> list.fold(bcc, fn(ccc, x) { set.insert(ccc, x) })
      })
    })
  let abyss = set.fold(cave, 0, fn(acc, p) { int.max(p.col, acc) })
  #(cave, abyss + 1)
}

fn fall(cave: Set(Point), floor: Int, sand: Point) -> Point {
  let next =
    list.map(directions, fn(x) { add(x, sand) })
    |> list.filter(fn(x) { !set.contains(cave, x) })
  case sand.col == floor || list.is_empty(next) {
    True -> sand
    False -> {
      let assert Ok(head) = list.first(next)
      fall(cave, floor, head)
    }
  }
}

fn simulate(cave: Set(Point), floor: Int, pred: fn(Point) -> Bool) -> Int {
  let sand = fall(cave, floor, start)
  case pred(sand) {
    True -> set.size(cave)
    False -> simulate(set.insert(cave, sand), floor, pred)
  }
}

pub fn part1(input: String) -> Int {
  let #(cave, floor) = parse(input)
  simulate(cave, floor, fn(x) { x.col == floor }) - set.size(cave)
}

pub fn part2(input: String) -> Int {
  let #(cave, floor) = parse(input)
  simulate(cave, floor, fn(x) { x == start }) - set.size(cave) + 1
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
