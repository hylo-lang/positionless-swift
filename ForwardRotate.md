# Forward Rotate

Strategy:
- Each step of the algorithm swaps the first k elements,
  where k = min(prefix_length, suffix_length)
- leaving us with a new rotate problem, k elements smaller.
- iterate until we're done.

## Example with prefix_length > suffix_length:

```
0: [a b c d e f g|h i j]
```

if we implement a step using the obvious primitives:
- swap first elements,
- advance the bisection point
- drop the first element of prefix

after step 1, we get this:

```
1a: h i j[d e f g a b c]|
         ^
         +---- final bisection point
```

The first time we find the bisection point at the end (i.e. prior
suffix_length == k) we have discovered the position of the bisection
point in the result: it's the beginning of the new prefix.

Also, because the bisection point reached the end, to get the new
rotate problem we need to **somehow** reset it to its prior position:

```
1: h i j[d e f g|a b c]
```

After step 2 we have:

```
2a: h i j a b c[g d e f]|
```

And we have the same problem of resetting the bisection point to get the
smaller rotate problem:

```
2: h i j a b c[g|d e f]
```

After step 3 we have:

```
3: h i j a b c d[g|e f]
```

We don't need to reset the bisection point, because it didn't reach the end.

The results of the remaining steps look like this:

```
4: h i j a b c d e[g|f]
5: h i j a b c d e f [g]|
6: h i j a b c d e f|[g]
```

The last problem is that we need to **somehow** reset the bisection point in the
whole mutated input to the one we discovered:
```
7: [h i j|a b c d e f g]
```
## Example with prefix_length < suffix_length:

```
0: [a b c|d e f g h i j]
1:  d e f[a b c|g h i j]
2:  d e f g h i[a b c|j]
```

Here's where we discover the final bisection point, because after that step we have
the bisection point at the end.

```
3a: d e f g h i j[a b c]|
                 ^
```

We also need to **somehow** reset it to its prior position to get the
next rotate problem:

```
3: d e f g h i j|[a b c]
4: d e f g h i j [a b c]|
```

And once again we need to **somehow** set the bisection point to the
discovered one in the final result:

```
5: [d e f g h i j|a b c]
```
