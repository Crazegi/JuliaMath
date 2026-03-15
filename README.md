# Math Theory Lab (Julia CLI)

A non-browser, performance-focused command-line app in an unusual language (Julia).

## What it includes

- Modular exponentiation with BigInt
- Fast doubling Fibonacci
- Binomial coefficient C(n, k)
- Catalan numbers
- Integer partition p(n)
- Deterministic Miller-Rabin for 64-bit numbers
- Chinese Remainder Theorem solver
- Black-Scholes call option pricing
- Riemann zeta approximation via Dirichlet-eta
- Newton-Raphson cubic root solver
- Logistic map Lyapunov exponent

## Run

1. Install Julia (1.10+ recommended).
2. Open a terminal in this folder.
3. Run:

   julia math_theory_lab.jl

## Probability Program (Second Mode)

A separate polished probability-focused CLI is available in `probability_studio.jl`.

Run it with:

   julia probability_studio.jl

It includes:

- At least one success in n trials
- Binomial exact and cumulative probabilities
- Poisson exact-event probability
- Bayes posterior probability
- Geometric first-success probability

## Trigonometry Program

A dedicated trigonometry CLI is available in `trigonometry_studio.jl`.

Run it with:

   julia trigonometry_studio.jl

It includes:

- Basic sin, cos, tan, cot for one angle
- Inverse trig values (arcsin, arccos, arctan)
- Law of Cosines (find side)
- Law of Cosines (find angle)
- Triangle summary from two sides + included angle
- Trig wave equation y = A*sin(Bx + C) + D
- Trig identity checker sin^2 + cos^2 = 1

## Notes on performance

- Uses BigInt for exact huge integer computations.
- Uses O(log n) methods where possible (modular power, Fibonacci).
- Uses in-place loops and bounds-safe optimizations for heavy iterations.
- Shows compute time for each calculation.
