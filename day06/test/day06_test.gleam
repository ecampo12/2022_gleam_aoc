import day06.{part1, part2}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let tests = [
    #("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7),
    #("bvwbjplbgvbhsrlpgdmjqwftvncz", 5),
    #("nppdvjthqldpwncqszvftbrmjlhg", 6),
    #("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10),
    #("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11),
  ]
  list.map(tests, fn(t) { part1(t.0) |> should.equal(t.1) })
}

pub fn part2_test() {
  let tests = [
    #("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19),
    #("bvwbjplbgvbhsrlpgdmjqwftvncz", 23),
    #("nppdvjthqldpwncqszvftbrmjlhg", 23),
    #("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29),
    #("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26),
  ]
  list.map(tests, fn(t) { part2(t.0) |> should.equal(t.1) })
}
