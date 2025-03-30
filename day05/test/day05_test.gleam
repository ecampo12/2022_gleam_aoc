import day05.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"

pub fn part1_test() {
  part1(input) |> should.equal("CMZ")
}

pub fn part2_test() {
  part2(input) |> should.equal("MCD")
}
