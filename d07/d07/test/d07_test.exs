defmodule SleighTest do
  use ExUnit.Case
  doctest Sleigh

  def steps() do
    [
      "Step C must be finished before step A can begin.",
      "Step C must be finished before step F can begin.",
      "Step A must be finished before step B can begin.",
      "Step A must be finished before step D can begin.",
      "Step B must be finished before step E can begin.",
      "Step D must be finished before step E can begin.",
      "Step F must be finished before step E can begin.",
    ]
  end

  test "parse a single step" do
    assert Sleigh.parse_step(hd(steps())) == {"C", "A"}
  end

  test "build step list" do
    assert length(Sleigh.build_step_list(steps())) == 7
  end

  test "build graph" do
    g = Sleigh.build_graph(Sleigh.build_step_list(steps()))
    assert length(Graph.vertices(g)) == 6
  end

  test "find start of steps" do
    g = Sleigh.build_graph(Sleigh.build_step_list(steps()))
    assert Sleigh.start_step(g) == "C"
  end

  test "run the steps - single edge" do
    g = Sleigh.build_graph([{"A", "B"}])
    assert Sleigh.run_steps(g) == "AB"
  end

  test "run the steps - sample" do
    g = Sleigh.build_graph(Sleigh.build_step_list(steps()))
    assert Sleigh.run_steps(g) == "CABDFE"
  end

  test "run against real data" do
    real_steps =
      File.stream!("full_steps.txt")
      |> Stream.map(&String.trim/1)
      |> Enum.to_list
    g = Sleigh.build_graph(Sleigh.build_step_list(real_steps))
    assert Sleigh.run_steps(g) == "IOFSJQDUWAPXELNVYZMHTBCRGK"
  end

end
