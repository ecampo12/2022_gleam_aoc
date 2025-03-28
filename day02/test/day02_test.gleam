import day02.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "A Y
B X
C Z"

pub fn part1_test() {
  part1(input) |> should.equal(15)
}

pub fn part2_test() {
  part2(input) |> should.equal(12)
}
