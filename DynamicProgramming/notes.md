# What is DP

It is a technique to solve complex problems by dividing them into smaller problems solved once.
Then combine smaller results into big one

# Fibonacci sequence

1 1 2 3 5 8 13 21 ...

# Memoization

Technique for speeding up computations by caching results.
Next time we do not compute but get value from cache

Memoization trades-off space with calculation speed.

# Bottom up dynamic programming

1. Solve earlier sub problems so they are ready when needed later
2. Throw away earlier results when no longer needed.

Thanks to this approach we keep in memory only results that are really needed.
So, in Fibonacci sequence when we calculate F(10) we keep in memory just.

It is good to draw dependency graph to see what problems can be solved first and later removed

Directed Acyclic Graph
graph = vertices + edges
edges have directions
no cycles: can't come back to a vertex

Minimal time and space

# Examples of DP

## Flower box problem

Maximize the total high of flowers.
[3, 10, 3, 1, 2] -> [_, 10, _, _, 2]
[9, 10 9] -> [9, _, 9]

Recurrence relation
f(i) = max  {f(i - 2) + v(i),
            f(i - 1)}

## Change making problem


We have coins (denominations). Using as many denominations do certain value.

For given target and coins, minimize the number of coins needed.

Assume we want to achieve 16$ and we have coins: 1$, 5$, 12$, 19$

Available combinations:
 - 12$ + 4*1$  -> 5 coins
 - 5$ * 3 + 1$ -> 4 coins

to -> target original
i -> denominations

Recurrence relation
f(i, t) = min { f(i, to - di) + 1
                f(i - 1, to)}

# Image resizing

We can find uninteresting seams (width 1px) and no one will notice change.

We will implement seam curving on real images.
a) preprocessing to get a image in a form we can process
b) apply dynamic programming - find the least interesting seam
c) post processing - take results of DP and use them (removing pixels)


The energy at the certain pixel is numerical value how much surrounding is changing around the pixel.
The higher value, the pixel surrounding changes more. Those define interesting regions


Definition of pixel energy (simplified):
rgb = red, green blue

|dx|^2 = |drx|^2 + |dgx|^2 + |dbx|^2

|dy|^2 = |dry|^2 + |dgy|^2 + |dby|^2

e(x,y) = |dx|^2 + |dy|^2


