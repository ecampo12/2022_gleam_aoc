import day10.{part1, part2}
import gleeunit
import gleeunit/should
import simplifile.{read}

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let assert Ok(input) = read("test/test_input.txt")
  part1(input) |> should.equal(13_140)
}

pub fn part2_test() {
  let assert Ok(input) = read("test/test_input.txt")
  let assert Ok(output) = read("test/test_output.txt")
  part2(input) |> should.equal(output)
}
