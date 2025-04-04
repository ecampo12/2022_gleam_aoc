import day12.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi"

pub fn part1_test() {
  part1(input) |> should.equal(31)
}

pub fn part2_test() {
  part2(input) |> should.equal(29)
}
