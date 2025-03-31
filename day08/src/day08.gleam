import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.row + p2.row, p1.col + p2.col)
}

// Up, Down, Right, Left
const directions = [Point(1, 0), Point(-1, 0), Point(0, 1), Point(0, -1)]

fn parse(input: String) -> Dict(Point, Int) {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(acc, row, r) {
    string.to_graphemes(row)
    |> list.index_fold(acc, fn(bcc, col, c) {
      let assert Ok(val) = int.parse(col)
      dict.insert(bcc, Point(r, c), val)
    })
  })
}

fn do_check(points: Dict(Point, Int), curr: Point, dir: Point, val: Int) -> Bool {
  let next = dict.get(points, add(curr, dir))
  case next {
    // means we went over the edge of the map
    Error(_) -> True
    Ok(next_value) -> {
      case next_value < val {
        True -> do_check(points, add(curr, dir), dir, val)
        False -> False
      }
    }
  }
}

fn is_visible(points: Dict(Point, Int), curr: Point, val: Int) -> Bool {
  list.fold_until(directions, False, fn(acc, dir) {
    case do_check(points, curr, dir, val) {
      True -> list.Stop(True)
      False -> list.Continue(acc)
    }
  })
}

pub fn part1(input: String) -> Int {
  let points = parse(input)
  dict.fold(points, 0, fn(acc, key, value) {
    case is_visible(points, key, value) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn do_score(
  points: Dict(Point, Int),
  curr: Point,
  dir: Point,
  val: Int,
  score: Int,
) -> Int {
  let next = dict.get(points, add(curr, dir))
  case next {
    // means we went over the edge of the map
    Error(_) -> score
    Ok(next_value) -> {
      case next_value < val {
        True -> do_score(points, add(curr, dir), dir, val, score + 1)
        False -> score + 1
      }
    }
  }
}

fn scenic_score(points: Dict(Point, Int), curr: Point, val: Int) -> Int {
  list.fold(directions, 1, fn(acc, dir) {
    acc * do_score(points, curr, dir, val, 0)
  })
}

pub fn part2(input: String) -> Int {
  let points = parse(input)
  dict.fold(points, 0, fn(acc, key, value) {
    let tree_score = scenic_score(points, key, value)
    case acc < tree_score {
      True -> tree_score
      False -> acc
    }
  })
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
