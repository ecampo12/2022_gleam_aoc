import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/result
import gleam/string
import simplifile.{read}

// values in the lists are 0 to 10, replacing 10 
// with a single char makes comparing easier.
fn simplify(input: String) -> List(String) {
  string.split(input, "\n")
  |> list.filter(fn(x) { x != "" })
  |> list.map(fn(x) { string.replace(x, "10", "A") })
}

// I've seen implementations that decode the string as a json.
// I still don't know how to work with jsons in gleam,
// so we have to recursively check the strings
fn compare(left: String, right: String) -> Order {
  let lhead = string.first(left) |> result.unwrap("")
  let rhead = string.first(right) |> result.unwrap("")
  case lhead, rhead {
    a, b if a == b ->
      compare(string.drop_start(left, 1), string.drop_start(right, 1))
    "]", _ -> order.Lt
    _, "]" -> order.Gt
    "[", b -> {
      let rest = string.drop_start(left, 1)
      let right = string.drop_start(right, 1)
      compare(rest, b <> "]" <> right)
    }
    a, "[" -> {
      let rest = string.drop_start(right, 1)
      let left = string.drop_start(left, 1)
      compare(a <> "]" <> left, rest)
    }
    _, _ -> string.compare(lhead, rhead)
  }
}

pub fn part1(input: String) -> Int {
  simplify(input)
  |> list.sized_chunk(2)
  |> list.index_fold(0, fn(acc, pair, i) {
    // I just learned this, it would've been useful to know earlier
    let assert [a, b] = pair
    case compare(a, b) {
      order.Lt -> acc + { i + 1 }
      _ -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  let dividers = ["[[2]]", "[[6]]"]
  let sort =
    simplify(input)
    |> list.append(dividers)
    |> list.sort(compare)
  list.index_fold(sort, 1, fn(acc, x, i) {
    case list.contains(dividers, x) {
      True -> acc * { i + 1 }
      False -> acc
    }
  })
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
