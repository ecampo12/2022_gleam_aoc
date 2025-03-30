import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type FileSystem {
  Dir(name: String, content: Dict(String, FileSystem))
  File(name: String, size: Int)
}

fn build_file_system(input: String) -> FileSystem {
  let terminal =
    string.split(input, "\n")
    |> list.drop(1)
  { Dir("/", dict.new()) |> do_build(terminal) }.0
}

fn do_build(
  curr_node: FileSystem,
  terminal: List(String),
) -> #(FileSystem, List(String)) {
  let line = list.take(terminal, 1) |> string.concat
  let terminal = list.drop(terminal, 1)
  case string.contains(line, "$"), line {
    True, "$ ls" -> do_build(curr_node, terminal)
    True, "$ cd .." -> #(curr_node, terminal)
    True, _ -> {
      let assert Ok(dir_name) = string.split(line, " ") |> list.last
      // we use the whole file path because there are repeated filename
      let #(sub_dir, terminal) =
        Dir(curr_node.name <> "/" <> dir_name, dict.new()) |> do_build(terminal)
      case curr_node {
        Dir(_, content) -> {
          let update_content = dict.insert(content, dir_name, sub_dir)
          Dir(..curr_node, content: update_content)
          |> do_build(terminal)
        }
        // should never happen
        _ -> #(Dir("messed up!", dict.new()), [])
      }
    }
    False, _ -> {
      case string.split(line, " ") {
        [size, name] -> {
          let fs = case int.parse(size) {
            Ok(size) -> File(name, size)
            Error(_) -> Dir(name, dict.new())
          }
          case curr_node {
            Dir(_, content) -> {
              let update_content = dict.insert(content, name, fs)
              Dir(..curr_node, content: update_content)
              |> do_build(terminal)
            }
            _ -> #(Dir("messed up!", dict.new()), [])
          }
        }
        // end of terminal
        _ -> #(curr_node, [])
      }
    }
  }
}

fn calculate_file_size(
  fs: FileSystem,
  files: Dict(String, Int),
) -> Dict(String, Int) {
  case fs {
    Dir(name, content) -> {
      let #(files, size) =
        dict.fold(content, #(files, 0), fn(acc, _key, value) {
          case value {
            Dir(name, _) -> {
              let files = calculate_file_size(value, acc.0)
              let assert Ok(dir_size) = dict.get(files, name)
              #(dict.insert(files, name, dir_size), acc.1 + dir_size)
            }
            File(_, size) -> #(acc.0, acc.1 + size)
          }
        })
      dict.insert(files, name, size)
    }
    _ -> files
  }
}

pub fn part1(input: String) -> Int {
  build_file_system(input)
  |> calculate_file_size(dict.new())
  |> dict.filter(fn(_key, value) { value <= 100_000 })
  |> dict.fold(0, fn(acc, _key, value) { acc + value })
}

pub fn part2(input: String) -> Int {
  let dirs =
    build_file_system(input)
    |> calculate_file_size(dict.new())
  let assert Ok(used_memory) = dict.get(dirs, "/")
  let required_space = used_memory - 40_000_000
  dict.fold(dirs, used_memory, fn(acc, _key, value) {
    case required_space < value && value < acc {
      True -> value
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
