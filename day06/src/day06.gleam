import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn find_marker(message: String, window: Int) -> #(List(String), Int) {
  let buffer = string.to_graphemes(message)
  let seq = list.take(buffer, window)
  list.drop(buffer, window)
  |> list.fold_until(#(seq, window), fn(acc, char) {
    let next = list.append(acc.0, [char]) |> list.drop(1)
    case list.unique(next) == next {
      True -> list.Stop(#(next, acc.1 + 1))
      False -> list.Continue(#(next, acc.1 + 1))
    }
  })
}

pub fn part1(input: String) -> Int {
  find_marker(input, 4).1
}

pub fn part2(input: String) -> Int {
  find_marker(input, 14).1
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
