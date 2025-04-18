import gleam/deque.{type Deque}
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type Cube {
  Cube(x: Int, y: Int, z: Int)
}

const orthogonal = [
  Cube(1, 0, 0),
  Cube(-1, 0, 0),
  Cube(0, 1, 0),
  Cube(0, -1, 0),
  Cube(0, 0, 1),
  Cube(0, 0, -1),
]

fn delta(c: Cube, dx: Int, dy: Int, dz: Int) -> Cube {
  Cube(c.x + dx, c.y + dy, c.z + dz)
}

fn neighbors(c: Cube) -> List(Cube) {
  list.map(orthogonal, fn(n) { delta(c, n.x, n.y, n.z) })
}

fn parse(input: String) -> Set(Cube) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert [x, y, z] =
      string.split(line, ",")
      |> list.map(fn(n) { int.parse(n) |> result.unwrap(-1) })
    Cube(x, y, z)
  })
  |> set.from_list
}

pub fn part1(input: String) -> Int {
  let cubes = parse(input)
  set.fold(cubes, [], fn(acc, c) {
    [
      neighbors(c)
        |> list.filter(fn(c) { !set.contains(cubes, c) })
        |> list.length,
      ..acc
    ]
  })
  |> int.sum
}

fn min_to_max(nums: List(Int)) -> List(Int) {
  let sorted = list.sort(nums, int.compare)
  let assert [min, ..] = sorted
  let assert Ok(max) = list.last(sorted)
  list.range(min - 1, max + 1)
}

fn cooling(
  cubes: Set(Cube),
  queue: Deque(Cube),
  visited: Set(Cube),
  xs: List(Int),
  ys: List(Int),
  zs: List(Int),
) -> Set(Cube) {
  case deque.pop_front(queue) {
    Error(_) -> visited
    Ok(#(c, queue)) -> {
      let #(queue, visited) =
        neighbors(c)
        |> list.filter(fn(cube) {
          !set.contains(cubes, cube) && !set.contains(visited, cube)
        })
        |> list.fold(#(queue, visited), fn(acc, next) {
          case
            list.contains(xs, next.x)
            && list.contains(ys, next.y)
            && list.contains(zs, next.z)
          {
            False -> acc
            True -> {
              #(deque.push_back(acc.0, next), set.insert(acc.1, next))
            }
          }
        })
      cooling(cubes, queue, visited, xs, ys, zs)
    }
  }
}

pub fn part2(input: String) -> Int {
  let cubes = parse(input)
  let cube_list = set.to_list(cubes)
  let xs = list.map(cube_list, fn(c) { c.x }) |> min_to_max
  let ys = list.map(cube_list, fn(c) { c.y }) |> min_to_max
  let zs = list.map(cube_list, fn(c) { c.z }) |> min_to_max

  let start =
    Cube(
      list.first(xs) |> result.unwrap(-69),
      list.first(ys) |> result.unwrap(-69),
      list.first(zs) |> result.unwrap(-69),
    )

  let queue = deque.new() |> deque.push_back(start)
  let visited = set.new() |> set.insert(start)

  let visited = cooling(cubes, queue, visited, xs, ys, zs)
  set.fold(cubes, 0, fn(acc, c) {
    acc + { neighbors(c) |> list.count(fn(c) { set.contains(visited, c) }) }
  })
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
