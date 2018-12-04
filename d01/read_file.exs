File.stream!("test_input.txt") |>
Stream.map( &(Integer.parse(&1)) ) |>
Enum.to_list
