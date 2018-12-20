defmodule Sleigh do
  def compute_steps(steps) do
    deps = Enum.map(steps, fn s -> parse_step(s) end)
    build_graph(deps)
  end

  def parse_step(step) do
    {
      hd(Regex.run(~r/^Step (\w?)/, step, capture: :all_but_first)),
      hd(Regex.run(~r/step (\w?)/, step, capture: :all_but_first))
    }
  end

  def build_graph(deps), do: do_build_graph(deps, %{})

  def do_build_graph([], dep_map), do: dep_map
  def do_build_graph([{pre, post}|t], dep_map) do
    if Map.has_key?(dep_map, pre) do
      do_map_a_single_column(c, row_t, Map.put(dep_map, {c, r}, dep_map[{c, r}] + 1))
    else
      do_map_a_single_column(c, row_t, Map.put_new(dep_map, {c, r}, 1))
    end
  end
end

steps = [
  "Step C must be finished before step A can begin.",
  "Step C must be finished before step F can begin.",
  "Step A must be finished before step B can begin.",
  "Step A must be finished before step D can begin.",
  "Step B must be finished before step E can begin.",
  "Step D must be finished before step E can begin.",
  "Step F must be finished before step E can begin.",
]

{"C", "A"} = Sleigh.parse_step(hd(steps))

IO.inspect Sleigh.compute_steps(steps)