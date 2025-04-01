import day09.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2"

const large_input = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20"

pub fn part1_test() {
  part1(input) |> should.equal(13)
}

pub fn part2_test() {
  part2(input) |> should.equal(1)
  part2(large_input) |> should.equal(36)
}
