defmodule Carty do
  def generator(cols, rows), do: do_generator(cols, rows, %{})

  def do_generator([], _, cartesian_map), do: cartesian_map

  def do_generator([c|col_t], rows, cartesian_map) do
    do_generator(col_t, rows, do_generator_single(c, rows, cartesian_map))
  end

  def do_generator_single(_, [], cartesian_map), do: cartesian_map

  def do_generator_single(c, [r|row_t], cartesian_map) do
    if Map.has_key?(cartesian_map, {c, r}) do
      do_generator_single(c, row_t, Map.put(cartesian_map, {c, r}, cartesian_map[{c, r}] + 1))
    else
      do_generator_single(c, row_t, Map.put_new(cartesian_map, {c, r}, 1))
    end
  end
end

IO.inspect Carty.generator(Enum.to_list(1..3), Enum.to_list(1..2))