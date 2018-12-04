fizzbuzz = fn
  (0, 0, _) -> "FizzBuzz"
  (0, _, _) -> "Fizz"
  (_, 0, _) -> "Buzz"
  (_, _, x) -> x
end

"FizzBuzz" = fizzbuzz.(0,0,5)
"Fizz" = fizzbuzz.(0,1,5)
"Buzz" = fizzbuzz.(1,0,5)
 5 = fizzbuzz.(1,1,5)

remfizz = fn n -> fizzbuzz.(rem(n,3), rem(n,5), n) end

IO.puts remfizz.(10)
IO.puts remfizz.(11)
IO.puts remfizz.(12)
IO.puts remfizz.(13)
IO.puts remfizz.(14)
IO.puts remfizz.(15)
