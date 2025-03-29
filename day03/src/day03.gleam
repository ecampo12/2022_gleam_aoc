import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

fn char_to_priority(char: String) -> Int {
  let assert Ok(utf_val) = string.to_utf_codepoints(char) |> list.first
  let val = string.utf_codepoint_to_int(utf_val)
  case val >= 97 {
    True -> val - 96
    False -> val - 38
  }
}

pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) {
    let len = string.length(line)
    let set1 =
      string.slice(line, 0, len / 2) |> string.to_graphemes |> set.from_list
    let set2 =
      string.slice(line, len / 2, len)
      |> string.to_graphemes
      |> set.from_list
    acc
    + {
      set.intersection(set1, set2)
      |> set.to_list
      |> string.concat
      |> char_to_priority
    }
  })
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n")
  |> list.sized_chunk(3)
  |> list.fold(0, fn(acc, group) {
    let first =
      list.first(group)
      |> result.unwrap("")
      |> string.to_graphemes
      |> set.from_list
    {
      list.fold(group, first, fn(bcc, x) {
        string.to_graphemes(x) |> set.from_list |> set.intersection(bcc)
      })
      |> set.to_list
      |> string.concat
      |> char_to_priority
    }
    + acc
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
