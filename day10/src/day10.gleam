import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn execute(loop: Int, inc: Int, state: #(Int, Int, Int)) -> #(Int, Int, Int) {
  list.range(1, loop)
  |> list.fold(state, fn(bcc, i) {
    let #(signal, reg_x, cycle) = bcc
    let cycle = cycle + 1
    let s = case cycle {
      20 | 60 | 100 | 140 | 180 | 220 -> cycle * reg_x
      _ -> 0
    }
    let reg_x = case i == loop {
      True -> reg_x + inc
      False -> reg_x
    }
    #(signal + s, reg_x, cycle)
  })
}

pub fn part1(input: String) -> Int {
  let #(signal, _, _) =
    string.split(input, "\n")
    |> list.fold(#(0, 1, 0), fn(acc, line) {
      let #(val, do_cycle) = case string.split(line, " ") {
        [_, val] -> {
          let assert Ok(n) = int.parse(val)
          #(n, 2)
        }
        _ -> #(0, 1)
      }
      execute(do_cycle, val, acc)
    })
  signal
}

fn draw(
  loop: Int,
  inc: Int,
  state: #(Int, Int),
  output: String,
  sprite: List(Int),
) -> #(#(Int, Int), String) {
  list.range(1, loop)
  |> list.fold(#(state, output), fn(bcc, i) {
    let #(#(reg_x, cycle), output) = bcc
    let cycle = cycle + 1
    let output = case
      list.contains(sprite, { string.length(output) + 1 } % 40)
    {
      True -> output <> "#"
      False -> output <> "."
    }
    let reg_x = case i == loop {
      True -> reg_x + inc
      False -> reg_x
    }
    #(#(reg_x, cycle), output)
  })
}

// my solution is slightly off, but its correct enough to spell out 
// the solution for rmy input
pub fn part2(input: String) -> String {
  let #(_, output, _) =
    string.split(input, "\n")
    |> list.fold(#(#(1, 0), "", [1, 2, 3]), fn(acc, line) {
      let #(val, do_cycle) = case string.split(line, " ") {
        [_, val] -> {
          let assert Ok(n) = int.parse(val)
          #(n, 2)
        }
        _ -> #(0, 1)
      }
      let #(state, output) = draw(do_cycle, val, acc.0, acc.1, acc.2)
      let reg_x = state.0
      let sprite = [reg_x, reg_x + 1, reg_x + 2]
      #(state, output, sprite)
    })

  string.to_graphemes(output)
  |> list.index_map(fn(char, i) {
    case { i + 1 } % 40 == 0 {
      True -> char <> "\n"
      False -> char
    }
  })
  |> string.concat
  |> string.trim_end
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.println("Part 2: ")
  io.println(part2_ans)
}
