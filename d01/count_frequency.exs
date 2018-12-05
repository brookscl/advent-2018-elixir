defmodule Mathy do
  def count_frequency(list), do: do_count_frequency(list, %{})

  defp do_count_frequency([], counts), do: counts
  defp do_count_frequency([h|t], counts) do
    if Map.has_key?(counts, h) do
      do_count_frequency(t, Map.put(counts, h, counts[h] + 1))
    else
      do_count_frequency(t, Map.put_new(counts, h, 1))
    end
  end
end


numbers =
  File.stream!("test_freq_input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&(String.to_integer(&1)))
  |> Enum.to_list

IO.inspect Mathy.count_frequency(numbers)
