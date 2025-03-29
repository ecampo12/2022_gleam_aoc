import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import simplifile.{read}

fn parse(line: String) -> #(Int, Int, Int, Int) {
  let assert Ok(re) = regexp.from_string("(\\d+)")
  case regexp.scan(re, line) {
    [a, b, c, d] -> {
      let assert Ok(a) = int.parse(a.content)
      let assert Ok(b) = int.parse(b.content)
      let assert Ok(c) = int.parse(c.content)
      let assert Ok(d) = int.parse(d.content)
      #(a, b, c, d)
    }
    _ -> #(-1, -1, -1, -1)
  }
}

fn fully_contains(line: String) -> Bool {
  let #(a, b, c, d) = parse(line)
  { a >= c && b <= d } || { c >= a && d <= b }
}

pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) {
    case fully_contains(line) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn within(r1: Int, r2: Int, x: Int) -> Bool {
  r1 <= x && x <= r2
}

fn partially_contains(line: String) -> Bool {
  let #(a, b, c, d) = parse(line)
  within(a, b, c) || within(a, b, d) || within(c, d, a) || within(c, d, b)
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) {
    case partially_contains(line) {
      True -> acc + 1
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
