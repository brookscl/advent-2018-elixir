defmodule Sleigh do
  def build_step_list(steps) do
    Enum.map(steps, fn s -> parse_step(s) end)
  end

  def parse_step(step) do
    {
      hd(Regex.run(~r/^Step (\w?)/, step, capture: :all_but_first)),
      hd(Regex.run(~r/step (\w?)/, step, capture: :all_but_first))
    }
  end

  def start_step(g) do
    hd(Enum.sort(Enum.filter(Graph.vertices(g), fn e -> length(Graph.in_edges(g, e)) == 0 end)))
  end

  def run_steps(g), do: do_run_steps(g, "")

  def do_run_steps(g, steps) do
    cond do
      length(Graph.vertices(g)) == 0 -> steps
      true -> do_run_steps(Graph.delete_vertex(g, start_step(g)), steps <> start_step(g))
    end
  end

  def build_graph(deps), do: do_build_graph(deps, Graph.new)

  def do_build_graph([], dep_graph), do: dep_graph
  def do_build_graph([{pre, post}|t], dep_graph) do
    do_build_graph(t, Graph.add_edge(dep_graph, pre, post))
  end
end

