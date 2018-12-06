defmodule Checksums do
  def count_letters(s, i) do
    f = Checksums.count_frequency(String.graphemes(s))
    if length(Enum.filter(f, fn {_, v} -> v == i end)) > 0, do: 1, else: 0
  end


  def count_frequency(list), do: do_count_frequency(list, %{})

  defp do_count_frequency([], counts), do: counts
  defp do_count_frequency([h|t], counts) do
    if Map.has_key?(counts, h) do
      do_count_frequency(t, Map.put(counts, h, counts[h] + 1))
    else
      do_count_frequency(t, Map.put_new(counts, h, 1))
    end
  end

  def compute_counts(box_list, check), do: do_compute_counts(box_list, check, 0)

  defp do_compute_counts([], _, counts), do: counts

  defp do_compute_counts([h|t], check, counts) do
    do_compute_counts(t, check, counts + count_letters(h, check))
  end
end

boxes =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.to_list


l1 = "abcdef"
l2 = "bababc"
l3 = "abcccd"
l4 = "aabcdd"
l5 = "aabcdd"
l6 = "abcdee"
l7 = "ababab"

0 = Checksums.count_letters(l1, 2)
0 = Checksums.count_letters(l1, 3)
1 = Checksums.count_letters(l2, 2)
1 = Checksums.count_letters(l2, 3)
0 = Checksums.count_letters(l3, 2)
1 = Checksums.count_letters(l3, 3)
1 = Checksums.count_letters(l4, 2)
0 = Checksums.count_letters(l4, 3)
1 = Checksums.count_letters(l5, 2)
0 = Checksums.count_letters(l5, 3)
1 = Checksums.count_letters(l6, 2)
0 = Checksums.count_letters(l6, 3)
0 = Checksums.count_letters(l7, 2)
1 = Checksums.count_letters(l7, 3)

twos = Checksums.compute_counts(boxes, 2)
threes = Checksums.compute_counts(boxes, 3)
IO.inspect twos * threes