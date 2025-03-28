import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

// Just Rock, Paper, Scissors": 
//  A == X == Rock 
//  B == Y == Paper
//  C == Z == Scicssor
// returns the total score for the shape we selected, plus the outcome of the round
fn round(round: List(String)) -> Int {
  case round {
    // Ties
    ["A", "X"] -> 1 + 3
    ["B", "Y"] -> 2 + 3
    ["C", "Z"] -> 3 + 3
    // Wins
    ["A", "Y"] -> 2 + 6
    ["B", "Z"] -> 3 + 6
    ["C", "X"] -> 1 + 6
    // Loses
    ["A", "Z"] -> 3 + 0
    ["B", "X"] -> 1 + 0
    ["C", "Y"] -> 2 + 0
    _ -> -1
  }
}

pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) { { string.split(line, " ") |> round } + acc })
}

// Turns out the second value tells us the oucome of the round.
// Its up to us to figure out with shape to use.
// X = lose, Y = draw, Z = win
// A = Rock, B = Paper, C = Scicssor
fn round2(round: List(String)) -> Int {
  case round {
    // Ties
    ["A", "Y"] -> 1 + 3
    ["B", "Y"] -> 2 + 3
    ["C", "Y"] -> 3 + 3
    // Wins
    ["A", "Z"] -> 2 + 6
    ["B", "Z"] -> 3 + 6
    ["C", "Z"] -> 1 + 6
    // Loses
    ["A", "X"] -> 3 + 0
    ["B", "X"] -> 1 + 0
    ["C", "X"] -> 2 + 0
    _ -> -1
  }
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(0, fn(acc, line) { { string.split(line, " ") |> round2 } + acc })
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
