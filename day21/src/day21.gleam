import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

type Yell {
  Number(num: Int)
  Expression(lhs: String, op: String, rhs: String)
}

fn parse(input: String) -> Dict(String, Yell) {
  string.split(input, "\n")
  |> list.fold(dict.new(), fn(acc, line) {
    case string.split(line, " ") {
      [name, num] -> {
        let name = string.slice(name, 0, string.length(name) - 1)
        let assert Ok(num) = int.parse(num)
        dict.insert(acc, name, Number(num))
      }
      [name, lhs, op, rhs] -> {
        let name = string.slice(name, 0, string.length(name) - 1)
        dict.insert(acc, name, Expression(lhs, op, rhs))
      }
      _ -> acc
    }
  })
}

fn monkey_yell(monkeys: Dict(String, Yell), name: String) -> Int {
  let assert Ok(yell) = dict.get(monkeys, name)
  case yell {
    Number(n) -> n
    Expression(lhs, op, rhs) -> {
      let m1 = monkey_yell(monkeys, lhs)
      let m2 = monkey_yell(monkeys, rhs)
      case op {
        "+" -> m1 + m2
        "-" -> m1 - m2
        "*" -> m1 * m2
        "/" -> m1 / m2
        _ -> {
          panic as {
            format.sprintf("Found unknow op: ~s", op)
            |> result.unwrap("")
          }
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> monkey_yell("root")
}

fn search(monkeys: Dict(String, Yell), f: String, rhs: Int, guess: Int) -> Int {
  let monkeys = dict.insert(monkeys, "humn", Number(guess))
  let diff = monkey_yell(monkeys, f) - rhs
  case diff == 0 {
    True -> guess
    False -> {
      let mod = case diff > 1000 {
        True -> diff / 1000
        False -> 1
      }
      search(monkeys, f, rhs, guess + mod)
    }
  }
}

pub fn part2(input: String) -> Int {
  let monkeys = parse(input)
  let assert Ok(Expression(lhs, _, rhs)) = dict.get(monkeys, "root")
  let right = monkey_yell(monkeys, rhs)

  search(monkeys, lhs, right, 0)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
