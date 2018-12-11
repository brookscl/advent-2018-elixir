defmodule CheckBoxes do
  def common_letters(string_list) do
    do_scan_all(string_list, string_list)
  end

  def do_scan_all(string_list, [h|t]) do
    # IO.inspect "Checking: " <> h
    commons = do_search_common(string_list, h)
    if commons != "", do: commons, else: do_scan_all(string_list, t)
  end

  def do_scan_all(_, []), do: ""

  def do_search_common([h|t], to_check) do
    # IO.inspect "    Comparing: " <> to_check <> " with " <> h
    commons = similar(h, to_check)
    if commons != "", do: commons, else: do_search_common(t, to_check)
  end

  def do_search_common([], _), do: ""

  # Compares two strings to see if they differ by just one character
  def similar(s1, s2) do
    if s1 != s2 and String.length(s1) == String.length(s2) do
      commons = do_similar(String.graphemes(s1), String.graphemes(s2), "")
      if String.length(commons) == String.length(s1) - 1, do: commons, else: ""
    else
      ""
    end
  end

  def do_similar([h1|t1], [h2|t2], commons) do
    if h1 == h2 do
      do_similar(t1, t2, commons <> h1)
    else
      do_similar(t1, t2, commons)
    end
  end

  def do_similar([], [], commons), do: commons

end

boxes = [
"abcde",
"fghij",
"klmno",
"pqrst",
"fguij",
"axcye",
"wvxyz",
]

IO.inspect CheckBoxes.common_letters(boxes)
"fgij" = CheckBoxes.common_letters(boxes)

real_boxes =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.to_list

IO.inspect CheckBoxes.common_letters(real_boxes)