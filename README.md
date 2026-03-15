# Julia Math Studio

High-performance command-line math toolkit in Julia, focused on clear UX and serious computation.

![Language](https://img.shields.io/badge/language-Julia-9558B2.svg)
![Apps](https://img.shields.io/badge/apps-3-blue.svg)
![Interface](https://img.shields.io/badge/interface-CLI-0A7B83.svg)
![Focus](https://img.shields.io/badge/focus-performance-orange.svg)

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Applications](#applications)
- [Batch Mode](#batch-mode)
- [Exported Results](#exported-results)
- [Testing](#testing)
- [Math Theory Lab](#math-theory-lab)
- [Probability Studio](#probability-studio)
- [Trigonometry Studio](#trigonometry-studio)
- [Performance Design](#performance-design)
- [Repository Structure](#repository-structure)
- [Roadmap](#roadmap)

## Overview

This repository contains three polished CLI applications:

1. `math_theory_lab.jl` for advanced math theories and heavy computations
2. `probability_studio.jl` for practical probability calculations
3. `trigonometry_studio.jl` for trigonometric workflows and Law of Cosines

Each app includes:

- Detailed input guidance
- User-friendly prompts and summaries
- Structured result panels
- Per-calculation compute-time reporting
- Automatic export to `.txt` and `.csv`

## Quick Start

### 1. Install Julia

- Recommended: Julia `1.10+`
- Verify:

```powershell
julia --version
```

### 2. Run an App

From this project directory:

```powershell
julia math_theory_lab.jl
julia probability_studio.jl
julia trigonometry_studio.jl
```

## Applications

| App | Purpose | Main Domains |
|---|---|---|
| `math_theory_lab.jl` | Advanced, hard-to-do-in-head calculations | Number theory, combinatorics, finance, chaos, approximations |
| `probability_studio.jl` | Event-likelihood and decision calculations | Binomial, Poisson, Bayes, geometric |
| `trigonometry_studio.jl` | Angle/triangle and trig equation tools | sin/cos/tan/cot, inverse trig, cosine law |

## Batch Mode

All three apps support file-based batch execution from their menu.

Ready examples are included in:

- `batch_examples/math_batch.txt`
- `batch_examples/probability_batch.txt`
- `batch_examples/trigonometry_batch.txt`

## Exported Results

Every computed result is exported automatically to both `.txt` and `.csv`.

Export location:

- `exports/math_theory_lab/`
- `exports/probability_studio/`
- `exports/trigonometry_studio/`

## Testing

Run the core-formula test suite:

```powershell
julia tests/runtests.jl
```

This suite validates numerical correctness for key formulas across all three apps.

## Math Theory Lab

File: `math_theory_lab.jl`

### Included Models

- Modular exponentiation with `BigInt`
- Fast doubling Fibonacci
- Binomial coefficient $C(n, k)$
- Catalan numbers
- Integer partition $p(n)$
- Deterministic Miller-Rabin (64-bit)
- Chinese Remainder Theorem solver
- Black-Scholes call option model
- Riemann zeta approximation (Dirichlet-eta)
- Newton-Raphson cubic root
- Logistic map Lyapunov exponent
- Euler totient $\phi(n)$
- Lucas-Lehmer Mersenne test
- Pell equation fundamental solution
- Stirling approximation error

### UX Features

- Detailed field-by-field input prompts
- Theory descriptions directly in menu
- High-visibility result blocks
- Demo benchmark mode for all theories

## Probability Studio

File: `probability_studio.jl`

### Included Models

- At least one success in $n$ independent trials
- Binomial exact and cumulative probabilities
- Poisson exact-event probability
- Bayes posterior probability
- Geometric first-success probability

### UX Features

- Input guides explain meaning of each variable
- Real-world scenario hints in menu
- Input summary shown before each compute
- Structured output card with percentages and timing

## Trigonometry Studio

File: `trigonometry_studio.jl`

### Included Modes

- Basic trig for one angle: sin, cos, tan, cot
- Inverse trig: arcsin, arccos, arctan
- Law of Cosines (solve side)
- Law of Cosines (solve angle)
- Triangle summary (side, area, perimeter)
- Trig equation evaluator: $y = A\sin(Bx + C) + D$
- Identity checker: $\sin^2(x) + \cos^2(x) = 1$

### UX Features

- Degree/radian unit selection
- Explanatory prompts and examples
- Geometry/trig validity checks
- Clean, readable result presentation

## Performance Design

- Uses `BigInt` for exact large-number arithmetic
- Employs fast algorithms where applicable (for example $O(\log n)$)
- Uses loop-oriented numeric routines for CLI efficiency
- Reports compute time for every result

## Repository Structure

```text
.
├── README.md
├── math_theory_lab.jl
├── probability_studio.jl
└── trigonometry_studio.jl
```

## Roadmap

1. Export results to `.txt`/`.csv`
2. Add batch input mode from files
3. Add test suite for all core formulas
