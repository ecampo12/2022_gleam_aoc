import gleam/bool
import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

type Point {
  Point(r: Int, c: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.r + p2.r, p1.c + p2.c)
}

fn parse(input: String) -> #(Dict(Point, String), List(String)) {
  let assert [map, seq] = string.split(input, "\n\n")
  let map =
    string.split(map, "\n")
    |> list.index_fold(dict.new(), fn(acc, line, r) {
      string.to_graphemes(line)
      |> list.index_fold(acc, fn(bcc, char, c) {
        case char {
          "." | "#" -> dict.insert(bcc, Point(r, c), char)
          _ -> acc
        }
      })
    })

  let seq =
    string.replace(seq, "R", " R ")
    |> string.replace("L", " L ")
    |> string.split(" ")
  #(map, seq)
}

fn wrap_around(
  map: Dict(Point, String),
  curr: Point,
  dir: Point,
) -> Result(Point, Nil) {
  case dir.r, dir.c {
    0, c -> {
      let sorted =
        dict.filter(map, fn(k, _) { k.r == curr.r })
        |> dict.keys
        |> list.sort(fn(a, b) { int.compare(a.c, b.c) })
      use <- bool.guard(c == -1, list.last(sorted))
      list.first(sorted)
    }
    r, 0 -> {
      let sorted =
        dict.filter(map, fn(k, _) { k.c == curr.c })
        |> dict.keys
        |> list.sort(fn(a, b) { int.compare(a.r, b.r) })
      use <- bool.guard(r == -1, list.last(sorted))
      list.first(sorted)
    }
    _, _ -> Error(Nil)
  }
}

fn move(map: Dict(Point, String), curr: Point, dir: Point, steps: Int) -> Point {
  use <- bool.guard(steps == 0, curr)
  let next = add(curr, dir)
  let tile = dict.get(map, next) |> result.unwrap("")
  case tile {
    "#" -> curr
    "." -> move(map, next, dir, steps - 1)
    _ -> {
      let assert Ok(next) = wrap_around(map, curr, dir)
      use <- bool.guard(dict.get(map, next) == Ok("#"), curr)
      move(map, next, dir, steps - 1)
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(map, seq) = parse(input)
  let assert [start] =
    dict.filter(map, fn(k, _) { k.r == 0 })
    |> dict.keys
    |> list.sort(fn(a, b) { int.compare(a.c, b.c) })
    |> list.take(1)
  let direction = Point(0, 1)
  let #(pos, dir) =
    list.fold(seq, #(start, direction), fn(acc, inst) {
      let #(curr, dir) = acc
      case inst {
        "R" -> #(curr, Point(dir.c, -dir.r))
        "L" -> #(curr, Point(-dir.c, dir.r))
        steps -> {
          let assert Ok(steps) = int.parse(steps)
          #(move(map, curr, dir, steps), dir)
        }
      }
    })
  let facing = case dir {
    Point(0, 1) -> 0
    Point(1, 0) -> 1
    Point(0, -1) -> 2
    Point(-1, 0) -> 3
    _ -> -1
  }
  1000 * { pos.r + 1 } + 4 * { pos.c + 1 } + facing
}

// Was easier to solve for hte shape of my input than it was to come up with a general solution
//      +cc--+dd--+
//      g    |    b
//      g    |    b
//      |    |    |
//      +----+aa==+
//      f    a
//      f    a
//      |    |
// +ff--+----+
// |    |    |
// g    |    b
// g    |    b
// +----+ee--+
// c    e
// c    e
// |    |
// +dd--+
// Each region is 50 x 50
fn wrap_cube(curr: Point, dir: Point) -> #(Point, Point) {
  let Point(row, col) = curr
  // a
  case dir, curr {
    Point(1, 0), _ if 100 <= col && col < 150 && row >= 50 -> #(
      Point(50 + col % 50, 99),
      Point(0, -1),
    )
    Point(0, 1), _ if col >= 100 && 50 <= row && row < 100 -> #(
      Point(49, 100 + row % 50),
      Point(-1, 0),
    )
    // b
    Point(0, 1), _ if col >= 150 && 0 <= row && row < 50 -> #(
      Point(149 - row % 50, 99),
      Point(0, -1),
    )
    Point(0, 1), _ if col >= 100 && 100 <= row && row < 150 -> #(
      Point(49 - row % 50, 149),
      Point(0, -1),
    )
    // c
    Point(-1, 0), _ if 50 <= col && col < 100 && row < 0 -> #(
      Point(150 + col % 50, 0),
      Point(0, 1),
    )
    Point(0, -1), _ if col < 0 && 150 <= row && row < 200 -> #(
      Point(0, 50 + row % 50),
      Point(1, 0),
    )
    // d
    Point(-1, 0), _ if 100 <= col && col < 150 && row < 0 -> #(
      Point(199, col % 50),
      Point(-1, 0),
    )
    Point(1, 0), _ if 0 <= col && col < 50 && row >= 200 -> #(
      Point(0, 100 + col % 50),
      Point(1, 0),
    )
    // e
    Point(1, 0), _ if 50 <= col && col < 100 && row >= 150 -> #(
      Point(150 + col % 50, 49),
      Point(0, -1),
    )
    Point(0, 1), _ if col >= 50 && 150 <= row && row < 200 -> #(
      Point(149, 50 + row % 50),
      Point(-1, 0),
    )
    // f
    Point(0, -1), _ if col < 50 && 50 <= row && row < 100 -> #(
      Point(100, row % 50),
      Point(1, 0),
    )
    Point(-1, 0), _ if 0 <= col && col < 50 && row < 100 -> #(
      Point(50 + col % 50, 50),
      Point(0, 1),
    )
    // g
    Point(0, -1), _ if col < 50 && 0 <= row && row < 50 -> #(
      Point(149 - row % 50, 0),
      Point(0, 1),
    )
    Point(0, -1), _ if col < 0 && 100 <= row && row < 150 -> #(
      Point(49 - row % 50, 50),
      Point(0, 1),
    )
    _, _ -> #(curr, dir)
  }
}

fn cube_move(
  map: Dict(Point, String),
  curr: Point,
  dir: Point,
  steps: Int,
) -> #(Point, Point) {
  use <- bool.guard(steps == 0, #(curr, dir))
  let next = add(curr, dir)
  let tile = dict.get(map, next) |> result.unwrap("")
  case tile {
    "#" -> #(curr, dir)
    "." -> cube_move(map, next, dir, steps - 1)
    _ -> {
      let #(next, ndir) = wrap_cube(next, dir)
      use <- bool.guard(dict.get(map, next) == Ok("#"), #(curr, dir))
      cube_move(map, next, ndir, steps - 1)
    }
  }
}

pub fn part2(input: String) -> Int {
  let #(map, seq) = parse(input)
  let assert [start] =
    dict.filter(map, fn(k, _) { k.r == 0 })
    |> dict.keys
    |> list.sort(fn(a, b) { int.compare(a.c, b.c) })
    |> list.take(1)
  let direction = Point(0, 1)

  let #(pos, dir) =
    list.fold(seq, #(start, direction), fn(acc, inst) {
      let #(curr, dir) = acc
      case inst {
        "R" -> #(curr, Point(dir.c, -dir.r))
        "L" -> #(curr, Point(-dir.c, dir.r))
        steps -> {
          let assert Ok(steps) = int.parse(steps)
          cube_move(map, curr, dir, steps)
        }
      }
    })
  let facing = case dir {
    Point(0, 1) -> 0
    Point(1, 0) -> 1
    Point(0, -1) -> 2
    Point(-1, 0) -> 3
    _ -> -1
  }
  1000 * { pos.r + 1 } + 4 * { pos.c + 1 } + facing
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
