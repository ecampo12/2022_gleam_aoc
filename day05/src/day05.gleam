import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import simplifile.{read}

// The given puzzle input is a text representation of a stack. So I has to do some transformations
// to turn it into actual stacks.
fn parse(input: String) -> #(Dict(String, Deque(String)), List(List(String))) {
  case string.split(input, "\n\n") {
    [stacks, instructions] -> {
      let stacks =
        string.split(stacks, "\n")
        |> list.map(fn(line) {
          string.replace(line, "[", " ")
          |> string.replace("]", " ")
          |> string.to_graphemes
        })
        |> list.transpose
        |> list.map(fn(line) {
          list.reverse(line) |> string.concat |> string.trim
        })
        |> list.filter(fn(x) { x != "" })
        |> list.fold(dict.new(), fn(acc, x) {
          let x = string.to_graphemes(x)
          let assert Ok(key) = list.first(x)
          let q =
            list.drop(x, 1)
            |> deque.from_list
          dict.insert(acc, key, q)
        })

      let assert Ok(re) = regexp.from_string("(\\d+)")
      let instructions =
        string.split(instructions, "\n")
        |> list.map(fn(line) {
          regexp.scan(re, line)
          |> list.map(fn(x) { x.content })
        })
      #(stacks, instructions)
    }
    _ -> #(dict.new(), [])
  }
}

pub fn part1(input: String) -> String {
  let #(stacks, instructions) = parse(input)
  list.fold(instructions, stacks, fn(acc, inst) {
    case inst {
      [num, from, to] -> {
        let assert Ok(amount) = int.parse(num)
        list.range(1, amount)
        |> list.fold(acc, fn(bcc, _x) {
          let assert Ok(s1) = dict.get(bcc, from)
          let assert Ok(s2) = dict.get(bcc, to)
          let assert Ok(#(val, s1)) = deque.pop_back(s1)
          let s2 = deque.push_back(s2, val)
          dict.insert(bcc, from, s1) |> dict.insert(to, s2)
        })
      }
      _ -> acc
    }
  })
  |> dict.to_list
  |> list.fold("", fn(acc, x) {
    let assert Ok(#(val, _)) = deque.pop_back(x.1)
    acc <> val
  })
}

pub fn part2(input: String) -> String {
  let #(stacks, instructions) = parse(input)
  list.fold(instructions, stacks, fn(acc, inst) {
    case inst {
      [num, from, to] -> {
        let assert Ok(amount) = int.parse(num)
        let #(curr_dict, crates) =
          list.range(1, amount)
          |> list.fold(#(acc, []), fn(bcc, _x) {
            let assert Ok(s1) = dict.get(bcc.0, from)
            let assert Ok(s2) = dict.get(bcc.0, to)
            let assert Ok(#(val, s1)) = deque.pop_back(s1)
            #(
              dict.insert(bcc.0, from, s1) |> dict.insert(to, s2),
              list.prepend(bcc.1, val),
            )
          })
        list.fold(crates, curr_dict, fn(bcc, x) {
          let assert Ok(s2) = dict.get(bcc, to)
          let s2 = deque.push_back(s2, x)
          dict.insert(bcc, to, s2)
        })
      }
      _ -> acc
    }
  })
  |> dict.to_list
  |> list.fold("", fn(acc, x) {
    let assert Ok(#(val, _)) = deque.pop_back(x.1)
    acc <> val
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
