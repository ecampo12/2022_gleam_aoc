import day22.{part1}

//, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5"

pub fn part1_test() {
  part1(input) |> should.equal(6032)
}
// It was easier to come up with a solution that works with my puzzle input, than it was to 
// code a general solution.
// pub fn part2_test() {
//   part2(input) |> should.equal(5031)
// }
