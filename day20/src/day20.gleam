import gleam/bool
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> List(Int) {
  string.split(input, "\n")
  |> list.map(fn(x) { int.parse(x) |> result.unwrap(-100) })
}

fn get_index(a: List(#(Int, Int)), element: #(Int, Int)) -> Int {
  list.fold_until(a, 0, fn(acc, x) {
    case x == element {
      True -> list.Stop(acc)
      False -> list.Continue(acc + 1)
    }
  })
}

fn remove(a: List(#(Int, Int)), index: Int) -> List(#(Int, Int)) {
  let #(l, r) = list.split(a, index)
  list.append(l, list.drop(r, 1))
}

fn insert(
  a: List(#(Int, Int)),
  index: Int,
  element: #(Int, Int),
) -> List(#(Int, Int)) {
  let #(l, r) = list.split(a, index)
  list.append(l, list.append([element], r))
}

fn do_rounds(mixed: List(#(Int, Int)), round: Int) -> List(#(Int, Int)) {
  use <- bool.guard(round == 0, mixed)

  list.range(0, list.length(mixed) - 1)
  |> list.fold(mixed, fn(acc, i) {
    let assert Ok(pair) = list.find(mixed, fn(x) { x.1 == i })
    let from = get_index(acc, pair)
    let mix = remove(acc, from)
    let len = list.length(mix)
    let to = { from + { pair.0 % len } + len } % len
    insert(mix, to, pair)
  })
  |> do_rounds(round - 1)
}

fn decrypt(input: List(Int), key: Int, rounds: Int) -> Int {
  let mixed = list.index_map(input, fn(x, i) { #(x * key, i) })
  let mixed = do_rounds(mixed, rounds) |> list.index_map(fn(x, i) { #(i, x.0) })
  let assert Ok(#(start, _)) = list.find(mixed, fn(x) { x.1 == 0 })
  list.range(1, 3)
  |> list.fold(0, fn(acc, offset) {
    let index = { start + offset * 1000 } % list.length(mixed)
    let assert Ok(#(number, _)) = list.key_pop(mixed, index)
    acc + number
  })
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> decrypt(1, 1)
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> decrypt(811_589_153, 10)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
