import day18.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5"

pub fn part1_test() {
  part1(input) |> should.equal(64)
}

pub fn part2_test() {
  part2(input) |> should.equal(58)
}
