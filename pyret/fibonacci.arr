fun greater-zero(n :: Number) -> Boolean:
  n > 0
end

fun fib(n :: Number%(greater-zero)):
  if (n == 1) or (n == 2):
    1
  else:
    fib(n - 2) + fib(n - 1)
  end
where:
  fib(1) is 1
  fib(2) is 1
  fib(3) is 2
  fib(4) is 3
  fib(5) is 5
end