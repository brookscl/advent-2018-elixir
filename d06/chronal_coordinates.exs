# the distance between two points is the sum of the absolute differences
#
# infinite if a point is on the edge that is closest to it?

defmodule Coord do
  def build_grid(coords) do
    max_x = Enum.max(Enum.map(coords, fn {x, _} -> x end))
    max_y = Enum.max(Enum.map(coords, fn {_, y} -> y end))
    IO.puts("Max x = #{max_x}, Max y = #{max_y}")
    g = do_build_grid(Enum.to_list(0..max_x), Enum.to_list(0..max_y), coords, %{})
    m = Map.values(g)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    :maps.filter fn k, _ -> !infinite?(k, g, max_x, max_y) end, m
  end

  def infinite?(coord, grid, max_x, max_y) do
    cond do
      Map.size(:maps.filter fn {x, _}, v -> x == 0 and v == coord end, grid) > 0  -> true
      Map.size(:maps.filter fn {_, y}, v -> y == 0 and v == coord end, grid) > 0  -> true
      Map.size(:maps.filter fn {x, _}, v -> x == max_x and v == coord end, grid) > 0  -> true
      Map.size(:maps.filter fn {_, y}, v -> y == max_y and v == coord end, grid) > 0  -> true
      true -> false
    end
  end

  def do_build_grid([], _, _, neighbor_map), do: neighbor_map

  def do_build_grid([x|x_t], y_list, coords, neighbor_map) do
    do_build_grid(x_t, y_list, coords, do_build_grid_single(x, y_list, coords, neighbor_map))
  end

  def do_build_grid_single(_, [], _, neighbor_map), do: neighbor_map

  def do_build_grid_single(x, [y|y_t], coords, neighbor_map) do
    do_build_grid_single(x, y_t, coords, record_closest_neighbor(x, y, coords, neighbor_map))
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x1-x2) + abs(y1-y2)
  end

  def record_closest_neighbor(x, y, coords, neighbor_map) do
    winners = do_record_closest_neighbor(x, y, coords, 99999, [])
    if length(winners) > 1 do
      # IO.puts("Dropping {#{x}, #{y}} because multiple owners")
      Map.put_new(neighbor_map, {x, y}, {-1, -1})
    else
      Map.put_new(neighbor_map, {x, y}, hd(winners))
    end
  end

  def do_record_closest_neighbor(_, _, [], _, winners), do: winners

  def do_record_closest_neighbor(x, y, [h|t], min, winners) do
    d = distance({x,y}, h)
    # IO.puts("min is #{min}, distance is #{d}, {x,y} = {#{x}, #{y}}, h is #{Enum.join(Tuple.to_list(h), ", ")}, winner is #{Enum.join(Tuple.to_list(winner), ", ")}")
    cond do
      d == min -> do_record_closest_neighbor(x, y, t, d, [h] ++ winners)
      d < min  -> do_record_closest_neighbor(x, y, t, d, [h])
      true     -> do_record_closest_neighbor(x, y, t, min, winners)
    end
  end
end

c = [
  {1, 1},
  {1, 6},
  {8, 3},
  {3, 4},
  {5, 5},
  {8, 9},
]

2 = Coord.distance({1,1}, {0,0})
15 = Coord.distance({8,9}, {1,1})

grid = Coord.build_grid(c)
IO.inspect grid

IO.puts("Max is #{ Enum.max(Map.values(grid))}")

real_coords =
  File.stream!("coordinates.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split(&1, ", "))
  |> Enum.map(fn(pairs) -> {String.to_integer(List.first(pairs)), String.to_integer(List.last(pairs))} end)
  |> Enum.to_list

grid = Coord.build_grid(real_coords)
IO.inspect grid

IO.puts("Max is #{ Enum.max(Map.values(grid))}")

