import day04.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8"

pub fn part1_test() {
  part1(input) |> should.equal(2)
}

pub fn part2_test() {
  part2(input) |> should.equal(4)
}
