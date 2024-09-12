from timeit import timeit
from typing import Dict
def fib(n: int) -> int:
    if n == 0: return 1
    if n == 1: return 1
    return fib(n - 1) + fib(n - 2)


print(timeit('fib(10)', number=100, globals=globals()))

def fib_cached(n: int, cache: Dict[int, int]={}) -> int:
    if n == 0: return 1
    if n == 1: return 1

    if n in cache:
        return cache[n]

    result = fib_cached(n - 1, cache) + fib_cached(n - 2, cache)
    cache[n] = result
    return result

print(timeit('fib_cached(900)', number=100, globals=globals()))

def fib_bottom_up(n: int):
    a = 1 # f(n - 2)
    b = 1 # f(n - 1)

    for _ in range(2, n + 1):
        a, b = b, a + b

    return b

print(timeit('fib_bottom_up(900)', number=100, globals=globals()))
