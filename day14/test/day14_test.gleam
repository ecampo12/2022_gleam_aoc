import day14.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9"

pub fn part1_test() {
  part1(input) |> should.equal(24)
}

pub fn part2_test() {
  part2(input) |> should.equal(93)
}
