// globaler Stack
const stack = new Array();

function stackFib(n) {
  if (n === 1 || n === 2) {
    stack.push(1);
  } else {
    stackFib(n - 1);
    stackFib(n - 2);
    stack.push(stack.pop() + stack.pop());
  }
}


function fib(n) {
  stack.length = 0;
  stackFib(n);
  return stack.pop();
}

// Test
console.log(fib(5) === 8);

