```
Strategy:

Each step of the algorithm swaps the first k = min(prefix_length, suffix_length) elements,

leaving us with a new, rotate problem, k elements smaller; we iterate until we're done.

For example, with prefix_length > suffix_length:

[a b c d e f g|h i j]

if we implement a step using the obvious primitives:
   swap first elements,
   advance the bisection point
   drop the first element of prefix

after one step, we get this:

  h i j[d e f g a b c]|

The first time we find the bisection point at the end (i.e. prefix_length == k)
we have discovered the position of the bisection point in the result: it's the
beginning of the new prefix.

Also because the bisection point reached the end, we need to somehow reset it to
its prior position to get the new rotate problem.

  h i j[d e f g|a b c]

At the end one more step we have:

  h i j a b c[g d e f]|

And we have the same problem of resetting the bisection point to get the
smaller rotate problem:

  h i j a b c[g|d e f]

After this step we have:

  h i j a b c d[g|e f]

We don't need to reset the bisection point, because it didn't reach the end.

The remaining steps look like this:

  h i j a b c d e[g|f]
  h i j a b c d e f g]|
  h i j a b c d e f|[g]

The last problem is that we need to somehow reset the bisection point in the
whole mutated input to the one we discovered:

 [h i j|a b c d e f g]

---------------

When the suffix is longer the process looks like this:

[a b c|d e f g h i j]
 d e f[a b c|g h i j]
 d e f g h i[a b c|j]

Here's where we discover the final bisection point, because after that step we have
the bisection point at the end.

 d e f g h i j[b c a]|
              ^

Remaining steps look like this:
 d e f g h i j[b c|a]
 d e f g h i j a[c|b]
 d e f g h i j a b c[]|

And here's the final result.

[d e f g h i j|a b c]
```
