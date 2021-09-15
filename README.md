# Ratios

[![Build Status](https://travis-ci.org/timholy/Ratios.jl.svg?branch=master)](https://travis-ci.org/timholy/Ratios.jl)

This package provides types similar to Julia's `Rational` type, which make some sacrifices but have better computational performance at the risk of greater risk of overflow.

Currently the only type provided is `SimpleRatio(num, den)` for two integers `num` and `den`.

Demo:

```julia
julia> x, y, z = SimpleRatio(1, 8), SimpleRatio(1, 4), SimpleRatio(2, 8)
(SimpleRatio{Int}(1, 8), SimpleRatio{Int}(1, 4), SimpleRatio{Int}(2, 8))

julia> x+y
SimpleRatio{Int}(12, 32)

julia> x+z
SimpleRatio{Int}(3, 8)
```

`y` and `z` both represent the rational number `1//4`, but when performing arithmetic with `x`
`z` is preferred because it has the same denominator and is less likely to overflow.

To detect overflow, [SaferIntegers.jl](https://github.com/JeffreySarnoff/SaferIntegers.jl) is recommended:

```julia
julia> using Ratios, SaferIntegers

julia> x, y = SimpleRatio{SafeInt8}(1, 20), SimpleRatio{SafeInt8}(1, 21)
(SimpleRatio{SafeInt8}(1, 20), SimpleRatio{SafeInt8}(1, 21))

julia> x + y
ERROR: OverflowError: 20 * 21 overflowed for type Int8
Stacktrace:
[...]
```

[FastRationals](https://github.com/JeffreySarnoff/FastRationals.jl) is another package with safety and performance characteristics that lies somewhere between `SimpleRatio` and `Rational`:

```julia
julia> @benchmark x + y setup=((x, y) = (SimpleRatio(rand(-20:20), rand(2:20)), SimpleRatio(rand(-20:20), rand(2:20))))
BenchmarkTools.Trial: 10000 samples with 1000 evaluations.
 Range (min … max):  1.727 ns … 28.575 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     1.739 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.753 ns ±  0.445 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

            ▂ ▃ ▃ ▃ ▄ ▆ ▇ █ ▆ ▅  ▅ ▇ ▄ ▁
  ▂▁▂▁▃▁▅▁█▁█▁█▁█▁█▁█▁█▁█▁█▁█▁█▁▁█▁█▁█▁█▁▆▁▃▁▃▁▃▁▃▁▃▁▃▁▃▁▃▁▂ ▄
  1.73 ns        Histogram: frequency by time        1.76 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark x + y setup=((x, y) = (FastRational(rand(-20:20), rand(2:20)), FastRational(rand(-20:20), rand(2:20))))
BenchmarkTools.Trial: 10000 samples with 1000 evaluations.
 Range (min … max):  3.192 ns … 89.167 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     3.215 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   3.307 ns ±  1.820 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

    ▃█▆█▃▂
  ▄███████▅▄▃▃▃▃▃▃▃▃▃▂▂▂▂▂▂▂▂▂▂▂▁▂▂▂▂▁▂▂▂▂▂▂▁▂▂▂▂▂▂▂▂▂▁▂▂▂▂▂ ▃
  3.19 ns        Histogram: frequency by time        3.45 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark x + y setup=((x, y) = (Rational(rand(-20:20), rand(2:20)), Rational(rand(-20:20), rand(2:20))))
BenchmarkTools.Trial: 10000 samples with 996 evaluations.
 Range (min … max):  22.385 ns … 81.269 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     32.777 ns              ┊ GC (median):    0.00%
 Time  (mean ± σ):   33.162 ns ±  4.743 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

                ▁  ▇  ▄▂ ▁▆▃  ▂█▃ ▁ ▇   ▁    ▁
  ▁▁▁▁▁▄▂▁▆▂▂█▄▃█▅▆█▇▇█████████████▅█▆▂▁█▇▁▂▁█▄▁▂▁▁▆▂▁▁▁▁▃▁▁▁ ▃
  22.4 ns         Histogram: frequency by time        45.8 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.
```
