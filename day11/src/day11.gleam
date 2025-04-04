import gary.{type ErlangArray}
import gary/array
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

type Monkey {
  Monkey(
    id: Int,
    items: List(Int),
    op: fn(Int) -> Int,
    cond: Int,
    true: Int,
    false: Int,
  )
}

// Ugly ahh parsing, the input is kind of complicated
fn parse(input: String) -> ErlangArray(Monkey) {
  string.split(input, "\n\n")
  |> list.map(fn(m) {
    let lines = string.split(m, "\n")
    let assert Ok(i) = list.first(lines)
    let id = case string.split(i, " ") {
      [_, num] -> {
        let num = string.drop_end(num, 1)
        int.parse(num) |> result.unwrap(-1)
      }
      _ -> -1
    }
    let lines = list.drop(lines, 1)

    let assert Ok(s) = list.first(lines)
    let starts = case string.split(s, ": ") {
      [_, nums] -> {
        string.split(nums, ", ")
        |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
      }
      _ -> []
    }
    let lines = list.drop(lines, 1)

    let assert Ok(o) = list.first(lines)
    let ops = case string.trim_start(o) |> string.split(" ") {
      [_, _, _, _, op, val] ->
        case int.parse(val), op {
          Ok(n), "+" -> fn(item: Int) { item + n }
          Ok(n), "*" -> fn(item: Int) { item * n }
          Error(_), "+" -> fn(item: Int) { item + item }
          Error(_), "*" -> fn(item: Int) { item * item }
          _, _ -> fn(_item: Int) { -69 }
        }
      _ -> fn(_item: Int) { -69 }
    }
    let lines = list.drop(lines, 1)

    case
      list.map(lines, fn(line) {
        let assert Ok(val) = string.split(line, " ") |> list.last
        int.parse(val) |> result.unwrap(-1)
      })
    {
      [a, b, c] -> Monkey(id, starts, ops, a, b, c)
      _ -> Monkey(-1, [], ops, -1, -2, -3)
    }
  })
  |> array.from_list(Monkey(-1, [], fn(_x: Int) { -69 }, -1, -1, -1))
}

fn throw(
  monkeys: ErlangArray(Monkey),
  monkey: Monkey,
  worry_relief: fn(Int) -> Int,
) -> ErlangArray(Monkey) {
  list.fold(monkey.items, monkeys, fn(acc, x) {
    let new = worry_relief(monkey.op(x))
    let key = case new % monkey.cond == 0 {
      True -> monkey.true
      False -> monkey.false
    }
    let assert Ok(m) = array.get(acc, key)
    let monkey = Monkey(..m, items: list.append(m.items, [new]))
    array.set(acc, key, monkey)
    |> result.unwrap(
      array.create(Monkey(-1, [], fn(_x: Int) { -69 }, -1, -2, -3)),
    )
  })
}

fn inspect(
  monkeys: ErlangArray(Monkey),
  rounds: Int,
  worry_relief: fn(Int) -> Int,
) -> Int {
  let #(_, count) =
    list.range(1, rounds)
    |> list.fold(#(monkeys, dict.new()), fn(acc, _) {
      list.range(0, array.get_size(acc.0) - 1)
      |> list.fold(acc, fn(bcc, i) {
        let #(monkeys, count) = bcc
        let assert Ok(monkey) = array.get(monkeys, i)
        let monkeys = throw(monkeys, monkey, worry_relief)
        let count =
          dict.upsert(count, monkey.id, fn(x) {
            case x {
              Some(i) -> i + list.length(monkey.items)
              None -> list.length(monkey.items)
            }
          })
        let assert Ok(monkeys) =
          array.set(monkeys, monkey.id, Monkey(..monkey, items: []))
        #(monkeys, count)
      })
    })
  let len = dict.size(count)
  dict.values(count)
  |> list.sort(int.compare)
  |> list.drop(len - 2)
  |> int.product
}

pub fn part1(input: String) -> Int {
  let monkeys = parse(input)
  inspect(monkeys, 20, fn(x) { x / 3 })
}

pub fn part2(input: String) -> Int {
  let monkeys = parse(input)
  let mod = array.fold(monkeys, 1, fn(_i, m, acc) { acc * m.cond })
  inspect(monkeys, 10_000, fn(x) { x % mod })
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
