defmodule Mathy do
	def sum_list(list), do: do_sum_list(list, 0)

	defp do_sum_list([], acc),		do: acc
	defp do_sum_list([h|t], acc), do: do_sum_list(t, acc + h)
end

numbers =
	File.stream!("input.txt")
	|> Stream.map(&String.strip/1)
	|> Stream.map(&(String.to_integer(&1)))
	|> Enum.to_list

IO.inspect Mathy.sum_list(numbers)
