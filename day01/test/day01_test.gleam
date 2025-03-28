import day01.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000"

pub fn part1_test() {
  part1(input)
  |> should.equal(24_000)
}

pub fn part2_test() {
  part2(input)
  |> should.equal(45_000)
}
