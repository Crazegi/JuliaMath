#!/usr/bin/env julia

# Math Theory Lab - unusual language edition (Julia CLI)
# Performance-focused computational toolkit for advanced mathematical models.

using Dates

struct TheoryEntry
    key::String
    name::String
    complexity::String
    description::String
end

const THEORIES = [
    TheoryEntry("mod_pow", "Modular Exponentiation", "O(log exponent)", "Compute (base^exponent) mod modulus with BigInt"),
    TheoryEntry("fibonacci", "Fast Doubling Fibonacci", "O(log n)", "Huge Fibonacci numbers with exact arithmetic"),
    TheoryEntry("binomial", "Binomial Coefficient C(n,k)", "O(min(k, n-k))", "Exact large combinatorics"),
    TheoryEntry("catalan", "Catalan Number", "BigInt combinatorics", "Counts trees, paths, and parenthesizations"),
    TheoryEntry("partition", "Integer Partition p(n)", "~O(n*sqrt(n))", "Euler pentagonal recurrence"),
    TheoryEntry("miller_rabin", "Miller-Rabin (64-bit deterministic)", "Fast primality", "Deterministic primality for 64-bit inputs"),
    TheoryEntry("crt", "Chinese Remainder Theorem", "O(k^2)", "Solve simultaneous congruences"),
    TheoryEntry("black_scholes", "Black-Scholes Call Option", "O(1)", "Stochastic finance pricing model"),
    TheoryEntry("zeta", "Riemann Zeta Approximation", "O(terms)", "Dirichlet-eta accelerated series"),
    TheoryEntry("newton_root", "Newton-Raphson Cubic Root", "O(iterations)", "Root of x^3 - c = 0"),
    TheoryEntry("lyapunov", "Logistic Map Lyapunov Exponent", "O(steps)", "Chaos sensitivity metric"),
    TheoryEntry("totient", "Euler Totient phi(n)", "~O(sqrt(n))", "Counts integers up to n that are coprime with n"),
    TheoryEntry("lucas_lehmer", "Lucas-Lehmer for Mersenne Primes", "O(p)", "Tests if M_p = 2^p - 1 is prime (p prime)"),
    TheoryEntry("pell", "Pell Equation Fundamental Solution", "Continued fractions", "Find minimal (x,y) solving x^2 - D*y^2 = 1"),
    TheoryEntry("stirling", "Stirling Approximation Error", "O(1)", "Compares ln(n!) against Stirling approximation")
]

function prompt_line(msg::String)
    print(msg)
    line = readline(stdin; keep=false)
    return strip(line)
end

function prompt_value(label::String, format::String, example::String)
    return prompt_line("$(label) [$(format)] e.g. $(example): ")
end

function read_bigint(label::String; format::String="integer", example::String="42", minv::Union{Nothing,BigInt}=nothing, maxv::Union{Nothing,BigInt}=nothing)
    while true
        s = prompt_value(label, format, example)
        try
            x = parse(BigInt, s)
            if minv !== nothing && x < minv
                println("Value must be >= $(minv).")
                continue
            end
            if maxv !== nothing && x > maxv
                println("Value must be <= $(maxv).")
                continue
            end
            return x
        catch
            println("Invalid integer. Please follow the shown format.")
        end
    end
end

function read_int(label::String; format::String="whole number", example::String="10", minv::Union{Nothing,Int}=nothing, maxv::Union{Nothing,Int}=nothing)
    while true
        s = prompt_value(label, format, example)
        try
            x = parse(Int, s)
            if minv !== nothing && x < minv
                println("Value must be >= $(minv).")
                continue
            end
            if maxv !== nothing && x > maxv
                println("Value must be <= $(maxv).")
                continue
            end
            return x
        catch
            println("Invalid whole number. Please follow the shown format.")
        end
    end
end

function read_float(label::String; format::String="decimal number", example::String="3.14", minv::Union{Nothing,Float64}=nothing, maxv::Union{Nothing,Float64}=nothing)
    while true
        s = prompt_value(label, format, example)
        try
            x = parse(Float64, s)
            if !isfinite(x)
                println("Value must be finite.")
                continue
            end
            if minv !== nothing && x < minv
                println("Value must be >= $(minv).")
                continue
            end
            if maxv !== nothing && x > maxv
                println("Value must be <= $(maxv).")
                continue
            end
            return x
        catch
            println("Invalid decimal number. Please follow the shown format.")
        end
    end
end

function read_bigint_list(label::String; example::String="2,3,2")
    while true
        s = prompt_value(label, "comma-separated integers", example)
        parts = split(s, ',')
        vals = BigInt[]
        ok = true
        for p in parts
            t = strip(p)
            if isempty(t)
                ok = false
                break
            end
            try
                push!(vals, parse(BigInt, t))
            catch
                ok = false
                break
            end
        end
        if ok && !isempty(vals)
            return vals
        end
        println("Invalid list. Use comma-separated integers, e.g. $(example)")
    end
end

function modpow_big(base::BigInt, exponent::BigInt, modulus::BigInt)
    exponent < 0 && error("Exponent must be >= 0")
    modulus <= 0 && error("Modulus must be > 0")
    b = mod(base, modulus)
    e = exponent
    result = BigInt(1)
    while e > 0
        if isodd(e)
            result = mod(result * b, modulus)
        end
        b = mod(b * b, modulus)
        e >>= 1
    end
    return result
end

function fib_pair(n::BigInt)
    if n == 0
        return BigInt(0), BigInt(1)
    end
    a, b = fib_pair(n >> 1)
    c = a * ((b << 1) - a)
    d = a * a + b * b
    if isodd(n)
        return d, c + d
    else
        return c, d
    end
end

function fibonacci_fast(n::BigInt)
    n < 0 && error("n must be >= 0")
    return first(fib_pair(n))
end

function binomial_big(n::BigInt, k::BigInt)
    (n < 0 || k < 0) && error("n and k must be >= 0")
    k > n && return BigInt(0)
    kk = min(k, n - k)
    num = BigInt(1)
    i = BigInt(1)
    while i <= kk
        num = (num * (n - kk + i)) ÷ i
        i += 1
    end
    return num
end

function catalan_big(n::BigInt)
    n < 0 && error("n must be >= 0")
    return binomial_big(2n, n) ÷ (n + 1)
end

function partition_number(n::Int)
    n < 0 && error("n must be >= 0")
    p = [BigInt(0) for _ in 0:n]
    p[1] = BigInt(1)

    @inbounds for i in 1:n
        k = 1
        total = BigInt(0)
        while true
            pent1 = (k * (3 * k - 1)) >>> 1
            pent2 = (k * (3 * k + 1)) >>> 1
            if pent1 > i && pent2 > i
                break
            end

            sign = iseven(k) ? -1 : 1
            if pent1 <= i
                total += sign * p[i - pent1 + 1]
            end
            if pent2 <= i
                total += sign * p[i - pent2 + 1]
            end
            k += 1
        end
        p[i + 1] = total
    end

    return p[n + 1]
end

function miller_rabin_64(n::BigInt)
    n < 2 && return false
    n > BigInt(typemax(UInt64)) && error("This deterministic test supports n <= 2^64-1")

    small_primes = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small_primes
        if n == p
            return true
        end
        if mod(n, p) == 0
            return false
        end
    end

    d = n - 1
    s = 0
    while iseven(d)
        d >>= 1
        s += 1
    end

    bases = (2, 325, 9375, 28178, 450775, 9780504, 1795265022)
    for a0 in bases
        a = mod(BigInt(a0), n)
        a == 0 && continue
        x = modpow_big(a, d, n)
        if x == 1 || x == n - 1
            continue
        end

        witness = true
        for _ in 1:(s - 1)
            x = mod(x * x, n)
            if x == n - 1
                witness = false
                break
            end
        end

        if witness
            return false
        end
    end

    return true
end

function ext_gcd(a::BigInt, b::BigInt)
    old_r, r = a, b
    old_s, s = BigInt(1), BigInt(0)
    old_t, t = BigInt(0), BigInt(1)

    while r != 0
        q = old_r ÷ r
        old_r, r = r, old_r - q * r
        old_s, s = s, old_s - q * s
        old_t, t = t, old_t - q * t
    end

    return old_r, old_s, old_t
end

function mod_inverse(a::BigInt, m::BigInt)
    g, x, _ = ext_gcd(a, m)
    abs(g) != 1 && error("No modular inverse exists")
    return mod(x, m)
end

function chinese_remainder(remainders::Vector{BigInt}, moduli::Vector{BigInt})
    length(remainders) == length(moduli) || error("Mismatched vector sizes")
    !isempty(remainders) || error("At least one congruence is required")

    for m in moduli
        m > 1 || error("All moduli must be > 1")
    end

    for i in eachindex(moduli)
        for j in (i + 1):length(moduli)
            gcd(moduli[i], moduli[j]) == 1 || error("Moduli must be pairwise coprime")
        end
    end

    M = BigInt(1)
    for m in moduli
        M *= m
    end

    x = BigInt(0)
    @inbounds for i in eachindex(moduli)
        mi = moduli[i]
        ai = mod(remainders[i], mi)
        Mi = M ÷ mi
        inv = mod_inverse(mod(Mi, mi), mi)
        x += ai * Mi * inv
    end

    return mod(x, M), M
end

function normal_cdf(x::Float64)
    t = 1.0 / (1.0 + 0.2316419 * abs(x))
    d = 0.3989422804014327 * exp(-0.5 * x * x)
    p = d * t * (0.31938153 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    return x >= 0 ? 1.0 - p : p
end

function black_scholes_call(S::Float64, K::Float64, r::Float64, sigma::Float64, T::Float64)
    (S > 0 && K > 0 && sigma > 0 && T > 0) || error("S,K,sigma,T must be > 0")
    d1 = (log(S / K) + (r + 0.5 * sigma * sigma) * T) / (sigma * sqrt(T))
    d2 = d1 - sigma * sqrt(T)
    return S * normal_cdf(d1) - K * exp(-r * T) * normal_cdf(d2)
end

function zeta_eta(s::Float64, terms::Int)
    s > 1.0 || error("s must be > 1")
    terms >= 2 || error("terms must be >= 2")

    # Kahan-compensated alternating sum for better stability.
    eta = 0.0
    c = 0.0
    @inbounds for n in 1:terms
        add = inv(n^s)
        term = isodd(n) ? add : -add
        y = term - c
        t = eta + y
        c = (t - eta) - y
        eta = t
    end
    factor = 1.0 - 2.0^(1.0 - s)
    return eta / factor
end

function newton_cuberoot(c::Float64, initial::Float64, iterations::Int)
    iterations >= 1 || error("iterations must be >= 1")
    x = initial
    @inbounds for _ in 1:iterations
        f = x * x * x - c
        fp = 3.0 * x * x
        fp == 0.0 && error("Derivative reached zero, change initial guess")
        x -= f / fp
    end
    return x
end

function lyapunov_logistic(r::Float64, x0::Float64, steps::Int, discard::Int)
    steps >= 10 || error("steps must be >= 10")
    discard >= 0 || error("discard must be >= 0")
    discard < steps || error("discard must be smaller than steps")

    x = x0
    sumv = 0.0
    used = 0
    @inbounds for i in 1:steps
        x = r * x * (1.0 - x)
        if i > discard
            d = abs(r * (1.0 - 2.0 * x))
            if d > 0
                sumv += log(d)
                used += 1
            end
        end
    end
    used > 0 || error("No usable derivative samples")
    return sumv / used, used
end

function euler_totient_big(n::BigInt)
    n >= 1 || error("n must be >= 1")
    result = n
    x = n
    p = BigInt(2)

    while p * p <= x
        if mod(x, p) == 0
            while mod(x, p) == 0
                x ÷= p
            end
            result -= result ÷ p
        end
        p = (p == 2) ? 3 : p + 2
    end

    if x > 1
        result -= result ÷ x
    end

    return result
end

function lucas_lehmer_test(p::Int)
    p >= 2 || error("p must be >= 2")
    if p == 2
        return true, BigInt(3)
    end

    M = (BigInt(1) << p) - 1
    s = BigInt(4)
    @inbounds for _ in 1:(p - 2)
        s = mod(s * s - 2, M)
    end
    return s == 0, M
end

function is_square_int(n::Int)
    n < 0 && return false
    r = isqrt(n)
    return r * r == n
end

function pell_fundamental_solution(D::Int)
    D > 1 || error("D must be > 1")
    is_square_int(D) && error("D must be non-square")

    a0 = isqrt(D)
    m = 0
    d = 1
    a = a0

    h_prev2 = BigInt(0)
    h_prev1 = BigInt(1)
    k_prev2 = BigInt(1)
    k_prev1 = BigInt(0)

    h = BigInt(a)
    k = BigInt(1)
    iter = 0

    while h * h - BigInt(D) * k * k != 1
        m = d * a - m
        d = (D - m * m) ÷ d
        a = (a0 + m) ÷ d

        h_prev2, h_prev1 = h_prev1, h
        k_prev2, k_prev1 = k_prev1, k
        h = BigInt(a) * h_prev1 + h_prev2
        k = BigInt(a) * k_prev1 + k_prev2

        iter += 1
        iter > 200_000 && error("Iteration limit reached for Pell solver")
    end

    return h, k, iter
end

function stirling_ln_factorial_error(n::Int)
    n >= 1 || error("n must be >= 1")
    n_f = float(n)
    exact = 0.0
    @inbounds for k in 2:n
        exact += log(float(k))
    end
    approx = n_f * log(n_f) - n_f + 0.5 * log(2.0 * pi * n_f)
    return exact, approx, abs(exact - approx)
end

function fmt_big(x::BigInt)
    s = string(x)
    return "digits=" * string(length(s)) * "\nvalue=" * s
end

function format_duration(elapsed_ms::Float64)
    if elapsed_ms < 1
        return string(round(elapsed_ms * 1000, digits=3)) * " us"
    elseif elapsed_ms < 1000
        return string(round(elapsed_ms, digits=3)) * " ms"
    else
        return string(round(elapsed_ms / 1000, digits=3)) * " s"
    end
end

function sanitize_filename(s::String)
    return replace(lowercase(strip(s)), r"[^a-z0-9]+" => "_")
end

function timestamp_tag()
    return replace(replace(string(Dates.now()), ":" => "-"), "." => "-")
end

function csv_escape(value::String)
    return "\"" * replace(value, "\"" => "\"\"") * "\""
end

function export_rows(app_name::String, title::String, rows::Vector{Pair{String, String}}, elapsed_ms::Float64)
    base_dir = joinpath(@__DIR__, "exports", app_name)
    mkpath(base_dir)

    stem = sanitize_filename(title) * "_" * timestamp_tag()
    txt_path = joinpath(base_dir, stem * ".txt")
    csv_path = joinpath(base_dir, stem * ".csv")

    open(txt_path, "w") do io
        println(io, "RESULT | " * title)
        println(io, repeat("-", 70))
        for row in rows
            println(io, row.first * "=" * row.second)
        end
        println(io, "compute_time=" * format_duration(elapsed_ms))
    end

    open(csv_path, "w") do io
        println(io, "key,value")
        for row in rows
            println(io, csv_escape(row.first) * "," * csv_escape(row.second))
        end
        println(io, csv_escape("compute_time") * "," * csv_escape(format_duration(elapsed_ms)))
    end

    println("Exported: " * txt_path)
    println("Exported: " * csv_path)
end

function compact_bigint_view(x::BigInt)
    s = string(x)
    if length(s) <= 220
        return s
    end
    return first(s, 110) * " ... " * last(s, 110)
end

function bigint_rows(label::String, x::BigInt)
    rows = Pair{String, String}[]
    push!(rows, label * "_digits" => string(length(string(x))))
    push!(rows, label * "_value" => compact_bigint_view(x))
    return rows
end

function print_result_panel(entry::TheoryEntry, rows::Vector{Pair{String, String}}, elapsed_ms::Float64)
    width = 84
    println("\n" * repeat("=", width))
    println("RESULT | " * entry.name)
    println(repeat("-", width))
    for row in rows
        k, v = row
        println(rpad(k, 24) * " : " * v)
    end
    println(repeat("-", width))
    println(rpad("compute_time", 24) * " : " * format_duration(elapsed_ms))
    println(repeat("=", width))
    export_rows("math_theory_lab", entry.name, rows, elapsed_ms)
end

function run_batch_mode_from_file()
    println("\nBatch mode format per line:")
    println("theory_key")
    println("Example:")
    println("fibonacci")
    println("mod_pow")
    println("lyapunov")
    println("Note: current batch mode uses built-in high-quality sample inputs per theory.")

    path = prompt_line("Batch file path: ")
    isfile(path) || error("File not found: " * path)

    lines = readlines(path)
    println("\n=== Batch Results (Math Theory Lab) ===")
    println(rpad("#", 4) * rpad("Theory", 45) * rpad("Time", 14) * "Status / Sample Output")
    println(repeat("-", 95))

    ok_count = 0
    for (idx, line) in enumerate(lines)
        raw = strip(line)
        if isempty(raw) || startswith(raw, "#")
            continue
        end

        key = lowercase(raw)
        entry = nothing
        for t in THEORIES
            if lowercase(t.key) == key
                entry = t
                break
            end
        end

        if entry === nothing
            println(rpad(string(idx), 4) * rpad(key, 45) * rpad("-", 14) * "ERR | Unknown theory key")
            continue
        end

        try
            elapsed_ms, summary = demo_compute(entry)
            println(rpad(string(idx), 4) * rpad(entry.name, 45) * rpad(format_duration(elapsed_ms), 14) * "OK | " * summary)
            rows = Pair{String, String}[
                "mode" => "batch_sample",
                "theory_key" => entry.key,
                "summary" => summary
            ]
            export_rows("math_theory_lab", entry.name * " batch", rows, elapsed_ms)
            ok_count += 1
        catch err
            println(rpad(string(idx), 4) * rpad(entry.name, 45) * rpad("-", 14) * "ERR | " * string(err))
        end
    end

    println(repeat("-", 95))
    println("Batch complete. Successful rows: $(ok_count)")
end

function run_theory(entry::TheoryEntry)
    println("\nSelected: $(entry.name)")
    println("Complexity: $(entry.complexity)")
    println("About: $(entry.description)")
    println("Input tip: Use plain numbers only, no spaces/units/symbols.")

    started = time_ns()
    rows = Pair{String, String}[]

    if entry.key == "mod_pow"
        base = read_bigint("Base"; format="integer", example="123456789123456789")
        exponent = read_bigint("Exponent"; format="integer >= 0", example="123456789", minv=BigInt(0))
        modulus = read_bigint("Modulus"; format="integer > 0", example="1000000007", minv=BigInt(1))
        started = time_ns()
        value = modpow_big(base, exponent, modulus)
        push!(rows, "equation" => "(base^exponent) mod modulus")
        append!(rows, bigint_rows("result", value))

    elseif entry.key == "fibonacci"
        n = read_bigint("n"; format="integer >= 0", example="50000", minv=BigInt(0))
        started = time_ns()
        value = fibonacci_fast(n)
        push!(rows, "equation" => "F(n)")
        push!(rows, "n" => string(n))
        append!(rows, bigint_rows("result", value))

    elseif entry.key == "binomial"
        n = read_bigint("n"; format="integer >= 0", example="2000", minv=BigInt(0))
        k = read_bigint("k"; format="integer >= 0", example="1000", minv=BigInt(0))
        started = time_ns()
        value = binomial_big(n, k)
        push!(rows, "equation" => "C(n, k)")
        push!(rows, "n" => string(n))
        push!(rows, "k" => string(k))
        append!(rows, bigint_rows("result", value))

    elseif entry.key == "catalan"
        n = read_bigint("n"; format="integer >= 0", example="300", minv=BigInt(0))
        started = time_ns()
        value = catalan_big(n)
        push!(rows, "equation" => "Cat(n)")
        push!(rows, "n" => string(n))
        append!(rows, bigint_rows("result", value))

    elseif entry.key == "partition"
        n = read_int("n"; format="integer 0..1000", example="400", minv=0, maxv=1000)
        started = time_ns()
        value = partition_number(n)
        push!(rows, "equation" => "p(n)")
        push!(rows, "n" => string(n))
        append!(rows, bigint_rows("result", value))

    elseif entry.key == "miller_rabin"
        n = read_bigint("n"; format="integer 2..18446744073709551615", example="18446744073709551557", minv=BigInt(2), maxv=BigInt(typemax(UInt64)))
        started = time_ns()
        probable = miller_rabin_64(n)
        push!(rows, "equation" => "deterministic Miller-Rabin")
        push!(rows, "n" => string(n))
        push!(rows, "probable_prime" => string(probable))

    elseif entry.key == "crt"
        remainders = read_bigint_list("Remainders"; example="2,3,2")
        moduli = read_bigint_list("Moduli"; example="3,5,7")
        length(remainders) == length(moduli) || error("Remainders and moduli length must match")
        started = time_ns()
        x, m = chinese_remainder(remainders, moduli)
        push!(rows, "equation" => "x = r_i (mod m_i)")
        push!(rows, "smallest_solution" => string(x))
        push!(rows, "modulo" => string(m))

    elseif entry.key == "black_scholes"
        S = read_float("Spot price S"; format="decimal > 0", example="120", minv=1e-12)
        K = read_float("Strike K"; format="decimal > 0", example="100", minv=1e-12)
        r = read_float("Risk-free rate r"; format="decimal", example="0.04")
        sigma = read_float("Volatility sigma"; format="decimal > 0", example="0.3", minv=1e-12)
        T = read_float("Maturity T (years)"; format="decimal > 0", example="1.5", minv=1e-12)
        started = time_ns()
        price = black_scholes_call(S, K, r, sigma, T)
        push!(rows, "equation" => "Black-Scholes call")
        push!(rows, "call_price" => string(round(price, sigdigits=16)))

    elseif entry.key == "zeta"
        s = read_float("s"; format="decimal > 1", example="2", minv=1.0000001)
        terms = read_int("terms"; format="integer 2..2000000", example="300000", minv=2, maxv=2_000_000)
        started = time_ns()
        value = zeta_eta(s, terms)
        push!(rows, "equation" => "zeta(s)")
        push!(rows, "s" => string(s))
        push!(rows, "terms" => string(terms))
        push!(rows, "zeta" => string(round(value, sigdigits=16)))

    elseif entry.key == "newton_root"
        c = read_float("c"; format="decimal", example="987654321")
        initial = read_float("Initial guess"; format="decimal", example="1000")
        iterations = read_int("Iterations"; format="integer 1..2000", example="40", minv=1, maxv=2000)
        started = time_ns()
        root = newton_cuberoot(c, initial, iterations)
        push!(rows, "equation" => "x^3 - c = 0")
        push!(rows, "iterations" => string(iterations))
        push!(rows, "root" => string(round(root, sigdigits=16)))

    elseif entry.key == "lyapunov"
        r = read_float("Growth r"; format="decimal", example="3.99")
        x0 = read_float("Initial x0"; format="decimal in (0,1)", example="0.2")
        steps = read_int("Steps"; format="integer 10..5000000", example="1500000", minv=10, maxv=5_000_000)
        discard = read_int("Discard"; format="integer 0..steps-1", example="5000", minv=0, maxv=steps - 1)
        started = time_ns()
        value, used = lyapunov_logistic(r, x0, steps, discard)
        push!(rows, "equation" => "Lyapunov exponent for logistic map")
        push!(rows, "lyapunov" => string(round(value, sigdigits=16)))
        push!(rows, "used_samples" => string(used))

    elseif entry.key == "totient"
        n = read_bigint("n"; format="integer >= 1", example="1234567891011", minv=BigInt(1))
        started = time_ns()
        value = euler_totient_big(n)
        push!(rows, "equation" => "phi(n)")
        push!(rows, "n" => string(n))
        append!(rows, bigint_rows("result", value))

    elseif entry.key == "lucas_lehmer"
        p = read_int("p"; format="prime exponent integer 2..127", example="61", minv=2, maxv=127)
        started = time_ns()
        is_prime, M = lucas_lehmer_test(p)
        push!(rows, "equation" => "M_p = 2^p - 1")
        push!(rows, "p" => string(p))
        push!(rows, "mersenne_number_digits" => string(length(string(M))))
        push!(rows, "mersenne_prime" => string(is_prime))

    elseif entry.key == "pell"
        D = read_int("D"; format="non-square integer 2..100000", example="61", minv=2, maxv=100_000)
        started = time_ns()
        x, y, iters = pell_fundamental_solution(D)
        push!(rows, "equation" => "x^2 - D*y^2 = 1")
        push!(rows, "D" => string(D))
        push!(rows, "iterations" => string(iters))
        push!(rows, "x_digits" => string(length(string(x))))
        push!(rows, "y_digits" => string(length(string(y))))
        push!(rows, "x" => compact_bigint_view(x))
        push!(rows, "y" => compact_bigint_view(y))

    elseif entry.key == "stirling"
        n = read_int("n"; format="integer >= 1", example="100000", minv=1)
        started = time_ns()
        exact, approx, err = stirling_ln_factorial_error(n)
        push!(rows, "equation" => "ln(n!) vs Stirling")
        push!(rows, "n" => string(n))
        push!(rows, "ln_factorial_exact" => string(round(exact, sigdigits=16)))
        push!(rows, "ln_factorial_stirling" => string(round(approx, sigdigits=16)))
        push!(rows, "absolute_error" => string(round(err, sigdigits=16)))

    else
        error("Unknown theory key")
    end

    elapsed_ms = (time_ns() - started) / 1_000_000
    print_result_panel(entry, rows, elapsed_ms)
end

function demo_compute(entry::TheoryEntry)
    started = time_ns()

    if entry.key == "mod_pow"
        value = modpow_big(parse(BigInt, "123456789123456789"), parse(BigInt, "123456789"), parse(BigInt, "1000000007"))
        summary = "digits=" * string(length(string(value)))

    elseif entry.key == "fibonacci"
        value = fibonacci_fast(BigInt(20000))
        summary = "digits=" * string(length(string(value)))

    elseif entry.key == "binomial"
        value = binomial_big(BigInt(1200), BigInt(600))
        summary = "digits=" * string(length(string(value)))

    elseif entry.key == "catalan"
        value = catalan_big(BigInt(300))
        summary = "digits=" * string(length(string(value)))

    elseif entry.key == "partition"
        value = partition_number(350)
        summary = "digits=" * string(length(string(value)))

    elseif entry.key == "miller_rabin"
        value = miller_rabin_64(parse(BigInt, "18446744073709551557"))
        summary = "prime=" * string(value)

    elseif entry.key == "crt"
        x, m = chinese_remainder(BigInt[2, 3, 2], BigInt[3, 5, 7])
        summary = "x=$(x) mod $(m)"

    elseif entry.key == "black_scholes"
        value = black_scholes_call(120.0, 100.0, 0.04, 0.3, 1.5)
        summary = "price=" * string(round(value, sigdigits=8))

    elseif entry.key == "zeta"
        value = zeta_eta(2.0, 80_000)
        summary = "zeta=" * string(round(value, sigdigits=10))

    elseif entry.key == "newton_root"
        value = newton_cuberoot(987654321.0, 1000.0, 40)
        summary = "root=" * string(round(value, sigdigits=10))

    elseif entry.key == "lyapunov"
        value, _ = lyapunov_logistic(3.99, 0.2, 200_000, 5_000)
        summary = "lyap=" * string(round(value, sigdigits=8))

    elseif entry.key == "totient"
        value = euler_totient_big(parse(BigInt, "1234567891011"))
        summary = "digits=" * string(length(string(value)))

    elseif entry.key == "lucas_lehmer"
        is_prime, M = lucas_lehmer_test(31)
        summary = "M_digits=$(length(string(M))) prime=$(is_prime)"

    elseif entry.key == "pell"
        x, y, iters = pell_fundamental_solution(61)
        summary = "iters=$(iters), x_digits=$(length(string(x))), y_digits=$(length(string(y)))"

    elseif entry.key == "stirling"
        _, _, err = stirling_ln_factorial_error(100_000)
        summary = "error=" * string(round(err, sigdigits=8))

    else
        error("Unknown theory key")
    end

    elapsed_ms = (time_ns() - started) / 1_000_000
    return elapsed_ms, summary
end

function run_demo_mode()
    println("\n=== Demo Mode: Auto Benchmark ===")
    println("Using built-in sample inputs for each theory.")
    println(rpad("#", 4) * rpad("Theory", 45) * rpad("Time", 14) * "Status / Sample Output")
    println(repeat("-", 95))

    for (i, t) in enumerate(THEORIES)
        try
            elapsed_ms, summary = demo_compute(t)
            println(rpad(string(i), 4) * rpad(t.name, 45) * rpad(format_duration(elapsed_ms), 14) * "OK | " * summary)
        catch err
            println(rpad(string(i), 4) * rpad(t.name, 45) * rpad("-", 14) * "ERR | " * string(err))
        end
    end

    println(repeat("-", 95))
    println("Demo mode complete.")
end

function print_menu()
    println("\n=== Math Theory Lab (Julia CLI) ===")
    println("Choose a theory to compute:")
    for (i, t) in enumerate(THEORIES)
        println("$(i). $(t.name) | $(t.complexity)")
        println("   -> $(t.description)")
    end
    println("$(length(THEORIES) + 1). Demo Mode (auto-run all sample calculations)")
    println("   -> Runs every theory once and prints a benchmark table")
    println("$(length(THEORIES) + 2). Batch Mode from file")
    println("   -> Execute many theory sample computations from a text file")
    println("0. Exit")
end

function main()
    println("Math Theory Lab initialized.")
    println("Designed for very hard calculations that are impractical in your head.")

    while true
        try
            print_menu()
            max_choice = length(THEORIES) + 2
            choice = read_int("Your choice"; format="menu number 0..$(max_choice)", example="1", minv=0, maxv=max_choice)
            if choice == 0
                println("Bye.")
                return
            end
            if choice == length(THEORIES) + 1
                run_demo_mode()
            elseif choice == length(THEORIES) + 2
                run_batch_mode_from_file()
            else
                run_theory(THEORIES[choice])
            end
        catch err
            println("\nError: $(err)")
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
