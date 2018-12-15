defmodule ElfClaims do
  def extract_regex_as_integer(r, s) do
    String.to_integer(hd(Regex.run(r, s, capture: :all_but_first)))
  end

  def parse_single_claim(claim) do
    %{
      :id => extract_regex_as_integer(~r/^#([0-9]+?)\s/, claim),
      :col => extract_regex_as_integer(~r/\@ ([0-9]+?),/, claim),
      :row => extract_regex_as_integer(~r/,([0-9]+?):/, claim),
      :col_span => extract_regex_as_integer(~r/: ([0-9]+?)x/, claim),
      :row_span => extract_regex_as_integer(~r/x([0-9]+?)$/, claim)
    }
  end

  def find_nonoverlapping_claim(claim_list) do
    claim_map = map_claims(claim_list)
    do_find_nonoverlapping_claim(claim_list, MapSet.new(claim_map))
  end

  def do_find_nonoverlapping_claim([], _), do: -1

  def do_find_nonoverlapping_claim([h|t], master_set) do
    claim = parse_single_claim(h)
    single_claim_map = map_a_claim(claim, %{})
    single_claim_set = MapSet.new(single_claim_map)
    intersect = MapSet.intersection(master_set, single_claim_set)
    if MapSet.equal?(intersect, single_claim_set) do
      claim.id
    else
      do_find_nonoverlapping_claim(t, master_set)
    end
  end

  def map_claims(claim_list), do: do_map_claims(claim_list, %{})

  def do_map_claims([h|t], claim_map) do
    claim = parse_single_claim(h)
    do_map_claims(t, map_a_claim(claim, claim_map))
  end

  def do_map_claims([], claim_map), do: claim_map

  def map_a_claim(claim, claim_map) do
    columns = Enum.to_list(claim.col..claim.col + claim.col_span - 1)
    rows = Enum.to_list(claim.row..claim.row + claim.row_span - 1)
    do_map_a_claim(columns, rows, claim_map)
  end

  def do_map_a_claim([], _, claim_map), do: claim_map

  def do_map_a_claim([c|col_t], rows, claim_map) do
    do_map_a_claim(col_t, rows, do_map_a_single_column(c, rows, claim_map))
  end

  def do_map_a_single_column(_, [], claim_map), do: claim_map

  def do_map_a_single_column(c, [r|row_t], claim_map) do
    if Map.has_key?(claim_map, {c, r}) do
      do_map_a_single_column(c, row_t, Map.put(claim_map, {c, r}, claim_map[{c, r}] + 1))
    else
      do_map_a_single_column(c, row_t, Map.put_new(claim_map, {c, r}, 1))
    end
  end
end

# test_claims = [
#   "#1 @ 1,3: 4x4",
#   "#2 @ 3,1: 4x4",
#   "#3 @ 5,5: 2x2",
# ]


# claim_map = ElfClaims.map_claims(test_claims)

# result = Enum.filter(claim_map, fn {_, v} -> v > 1  end)

# IO.inspect length(result)

# master_set = MapSet.new(claim_map)
# single_claim_set = MapSet.new([{{1,3}, 1}])
# IO.inspect master_set
# subset = MapSet.intersection(master_set, MapSet.new([{{1,3}, 1}]))
# IO.inspect MapSet.equal?(subset, single_claim_set)

# IO.inspect ElfClaims.find_nonoverlapping_claim(test_claims)

real_claims =
  File.stream!("elf_claims.txt")
  |> Stream.map(&String.trim/1)
  |> Enum.to_list

claim_map = ElfClaims.map_claims(real_claims)

result = Enum.filter(claim_map, fn {_, v} -> v > 1  end)

IO.inspect length(result)

IO.inspect ElfClaims.find_nonoverlapping_claim(real_claims)