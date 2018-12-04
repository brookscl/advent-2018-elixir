defmodule Mathy do
  def check_dups(list), do: do_check_dups(list, %{})

  defp do_check_dups([], counts), do: counts
  defp do_check_dups([h|t], counts) do
    if Map.has_key?(counts, h) do
      do_check_dups(t, Map.put(counts, h, counts[h] + 1))
    else
      do_check_dups(t, Map.put_new(counts, h, 1))
    end
  end
end


numbers =
  File.stream!("test_freq_input.txt")
  |> Stream.map(&String.strip/1)
  |> Stream.map(&(String.to_integer(&1)))
  |> Enum.to_list

IO.inspect Mathy.check_dups(numbers)
