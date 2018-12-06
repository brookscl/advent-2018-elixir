defmodule Mathy do
  def count_running_frequency(list), do: do_count_frequency(list, list, %{}, 0)

  defp do_count_frequency([], original, counts, sum) do
    do_count_frequency(original, original, counts, sum)
  end
  defp do_count_frequency([h|t], original, counts, sum) do
    if Map.has_key?(counts, sum) do
      sum
    else
      do_count_frequency(t, original, Map.put_new(counts, sum, 1), sum + h)
    end
  end
end


numbers =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&(String.to_integer(&1)))
  |> Enum.to_list

IO.inspect Mathy.count_running_frequency(numbers)
