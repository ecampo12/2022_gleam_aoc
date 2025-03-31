import day08.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "30373
25512
65332
33549
35390"

pub fn part1_test() {
  part1(input) |> should.equal(21)
}

pub fn part2_test() {
  part2(input) |> should.equal(8)
}
