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