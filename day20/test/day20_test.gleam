import day20.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "1
2
-3
3
-2
0
4"

pub fn part1_test() {
  part1(input) |> should.equal(3)
}

pub fn part2_test() {
  part2(input) |> should.equal(1_623_178_306)
}
