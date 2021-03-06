# the distance between two points is the sum of the absolute differences
#
# infinite if a point is on the edge that is closest to it?

defmodule Coord do
  def build_grid(coords) do
    {max_x, max_y} = grid_max(coords)
    IO.puts("Max x = #{max_x}, Max y = #{max_y}")
    g = do_build_grid(Enum.to_list(0..max_x), Enum.to_list(0..max_y), coords, %{})
    m = Map.values(g)
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    :maps.filter fn k, _ -> !infinite?(k, g, max_x, max_y) end, m
  end

  def grid_max(coords) do
    max_x = Enum.max(Enum.map(coords, fn {x, _} -> x end))
    max_y = Enum.max(Enum.map(coords, fn {_, y} -> y end))
    {max_x, max_y}
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
    cond do
      d == min -> do_record_closest_neighbor(x, y, t, d, [h] ++ winners)
      d < min  -> do_record_closest_neighbor(x, y, t, d, [h])
      true     -> do_record_closest_neighbor(x, y, t, min, winners)
    end
  end

  def calculate_sum_of_distances(coords) do
    {max_x, max_y} = grid_max(coords)
    g = do_calculate_sums(Enum.to_list(0..max_x), Enum.to_list(0..max_y), coords, %{})
  end

  def do_calculate_sums([], _, _, sum_map), do: sum_map
  def do_calculate_sums([x|x_t], y_list, coords, sum_map) do
    do_calculate_sums(x_t, y_list, coords, do_calc_sum_single(x, y_list, coords, sum_map))
  end

  def do_calc_sum_single(_, [], _, sum_map), do: sum_map
  def do_calc_sum_single(x, [y|y_t], coords, sum_map) do
    do_calc_sum_single(x, y_t, coords, Map.put(sum_map, {x, y}, sum_distances({x, y}, coords)))
  end

  def sum_distances({x, y}, coords) do
    Enum.reduce(coords, 0, fn c, acc -> distance(c, {x, y}) + acc end)
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

sum_grid = Coord.calculate_sum_of_distances(c)

happy_grid = :maps.filter fn _, v -> v < 32 end, sum_grid

IO.inspect happy_grid
IO.puts("Happy location count is #{Map.size(happy_grid)}")

real_coords =
  File.stream!("coordinates.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.split(&1, ", "))
  |> Enum.map(fn(pairs) -> {String.to_integer(List.first(pairs)), String.to_integer(List.last(pairs))} end)
  |> Enum.to_list

grid = Coord.build_grid(real_coords)
IO.inspect grid

IO.puts("Max is #{ Enum.max(Map.values(grid))}")

sum_grid = Coord.calculate_sum_of_distances(real_coords)

happy_grid = :maps.filter fn _, v -> v < 10000 end, sum_grid

IO.inspect happy_grid
IO.puts("Happy location count is #{Map.size(happy_grid)}")
