import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> List(Int) {
  string.split(input, "\n\n")
  |> list.map(fn(elf) {
    let lines = string.split(elf, "\n")
    list.fold(lines, 0, fn(acc, line) {
      let assert Ok(calorie) = int.parse(line)
      acc + calorie
    })
  })
}

pub fn part1(input: String) -> Int {
  let elves = parse(input)
  list.max(elves, int.compare)
  |> result.unwrap(0)
}

pub fn part2(input: String) -> Int {
  let elves = parse(input)
  list.sort(elves, int.compare) |> list.reverse |> list.take(3) |> int.sum
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
