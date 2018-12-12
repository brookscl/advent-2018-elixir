defmodule ElfClaims do
  def extract_regex_as_integer(r, s) do
    String.to_integer(hd(Regex.run(r, s, capture: :all_but_first)))
  end

  def parse_single_claim(claim) do
    %{
      :col => extract_regex_as_integer(~r/\@ ([0-9]+?),/, claim),
      :row => extract_regex_as_integer(~r/,([0-9]+?):/, claim),
      :col_span => extract_regex_as_integer(~r/: ([0-9]+?)x/, claim),
      :row_span => extract_regex_as_integer(~r/x([0-9]+?)$/, claim)
    }
  end

  def map_claims(claim_list), do: do_map_claims(claim_list, %{})

  def do_map_claims([h|t], claim_map) do
    claim = parse_single_claim(h)
    IO.inspect map_a_claim(claim, claim_map)
  end

  def map_a_claim(claim, claim_map) do
    for c <- claim.col..claim.col + claim.col_span - 1 do
      for r <- claim.row..claim.row + claim.row_span - 1 do
        if Map.has_key?(claim_map, {c, r}) do
          Map.put(claim_map, {c, r}, claim_map[{c, r}] + 1)
        else
          Map.put_new(claim_map, {c, r}, 1)
          IO.inspect {c, r}
        end        
      end
    end
    claim_map
  end
end

test_claims = [
  "#1 @ 1,3: 4x4",
  "#2 @ 3,1: 4x4",
  "#3 @ 5,5: 2x2",
]

# claim = ElfClaims.parse_single_claim(hd(test_claims))

ElfClaims.map_claims(test_claims)