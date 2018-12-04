result =
	File.stream!("input.txt")
	|> Stream.map(&String.strip/1)
	|> Stream.map(&(String.to_integer(&1)))
	|> Enum.sum

IO.inspect result
