#!/usr/bin/env julia

# Probability Studio - polished CLI for practical probability calculations.

function line(ch::String="=", n::Int=88)
    println(repeat(ch, n))
end

function title_block()
    line()
    println("PROBABILITY STUDIO")
    println("Compute polished probability answers for real-world event questions.")
    line()
end

function prompt_line(msg::String)
    print(msg)
    return strip(readline(stdin; keep=false))
end

function read_int(label::String; format::String="whole number", example::String="10", minv::Union{Nothing,Int}=nothing, maxv::Union{Nothing,Int}=nothing)
    while true
        s = prompt_line("$(label) [$(format)] e.g. $(example): ")
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
            println("Invalid whole number.")
        end
    end
end

function read_float(label::String; format::String="decimal", example::String="0.5", minv::Union{Nothing,Float64}=nothing, maxv::Union{Nothing,Float64}=nothing)
    while true
        s = prompt_line("$(label) [$(format)] e.g. $(example): ")
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
            println("Invalid decimal number.")
        end
    end
end

function percent(p::Float64)
    return string(round(p * 100.0, digits=6)) * "%"
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

function print_result(title::String, rows::Vector{Pair{String, String}}, elapsed_ms::Float64)
    line("-")
    println("RESULT | " * title)
    line("-")
    for row in rows
        k, v = row
        println(rpad(k, 30) * " : " * v)
    end
    line("-")
    println(rpad("compute_time", 30) * " : " * format_duration(elapsed_ms))
    line("=")
end

function log_factorial(n::Int)
    n < 0 && error("n must be >= 0")
    s = 0.0
    @inbounds for i in 2:n
        s += log(float(i))
    end
    return s
end

function log_choose(n::Int, k::Int)
    (k < 0 || k > n) && return -Inf
    return log_factorial(n) - log_factorial(k) - log_factorial(n - k)
end

function binomial_pmf(n::Int, k::Int, p::Float64)
    if k < 0 || k > n
        return 0.0
    end
    if p == 0.0
        return k == 0 ? 1.0 : 0.0
    end
    if p == 1.0
        return k == n ? 1.0 : 0.0
    end
    return exp(log_choose(n, k) + k * log(p) + (n - k) * log1p(-p))
end

function poisson_pmf(lambda::Float64, k::Int)
    lambda > 0 || error("lambda must be > 0")
    k >= 0 || error("k must be >= 0")
    return exp(-lambda + k * log(lambda) - log_factorial(k))
end

function menu()
    println("\nChoose probability model:")
    println("1. At least one success in n independent trials")
    println("   -> Example: chance of getting at least one heads in 20 coin flips")
    println("2. Binomial: exact k successes and cumulative P(X <= k)")
    println("   -> Example: exactly 12 opens out of 50 emails, or at most 12")
    println("3. Poisson: exact k events")
    println("   -> Example: exactly 7 calls in one hour when average is 4.2")
    println("4. Bayes theorem: P(A|B)")
    println("   -> Example: probability of disease given a positive test")
    println("5. Geometric: first success on trial k")
    println("   -> Example: first sale happens on the 6th customer")
    println("6. Exit")
end

function print_input_guide(title::String, lines::Vector{String})
    line("-")
    println("INPUT GUIDE | " * title)
    line("-")
    for item in lines
        println("- " * item)
    end
    line("-")
end

function run_at_least_one()
    println("\nModel: At least one success")
    println("Formula: P(at least one) = 1 - (1-p)^n")
    print_input_guide("At least one success", [
        "p = chance of success in one trial. Example: 0.2 means 20%.",
        "n = number of independent tries. Example: 20 coin flips.",
        "Use decimal probability between 0 and 1 for p."
    ])
    p = read_float("p (single-trial success chance)"; format="0..1", example="0.2", minv=0.0, maxv=1.0)
    n = read_int("n (number of independent trials)"; format=">= 1", example="20", minv=1)
    println("Input summary: p=$(p), n=$(n)")

    started = time_ns()
    q = 1.0 - p
    result = 1.0 - q^n
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "1 - (1-p)^n",
        "p" => string(p),
        "n" => string(n),
        "probability" => string(round(result, sigdigits=16)),
        "probability_percent" => percent(result)
    ]
    print_result("At least one success", rows, elapsed_ms)
end

function run_binomial()
    println("\nModel: Binomial")
    println("Formula: P(X=k) = C(n,k) * p^k * (1-p)^(n-k)")
    print_input_guide("Binomial", [
        "n = total number of trials. Example: 50 email sends.",
        "k = number of successes you care about. Example: exactly 12 opens.",
        "p = success chance per trial, from 0 to 1. Example: 0.3 for 30%."
    ])
    n = read_int("n (total trials)"; format=">= 0", example="50", minv=0)
    k = read_int("k (target successes)"; format="0..n", example="12", minv=0, maxv=n)
    p = read_float("p (success chance each trial)"; format="0..1", example="0.3", minv=0.0, maxv=1.0)
    println("Input summary: n=$(n), k=$(k), p=$(p)")

    started = time_ns()
    exact = binomial_pmf(n, k, p)
    cumulative = 0.0
    @inbounds for i in 0:k
        cumulative += binomial_pmf(n, i, p)
    end
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "Binomial PMF/CDF",
        "n" => string(n),
        "k" => string(k),
        "p" => string(p),
        "P(X = k)" => string(round(exact, sigdigits=16)),
        "P(X <= k)" => string(round(cumulative, sigdigits=16)),
        "P(X = k) percent" => percent(exact),
        "P(X <= k) percent" => percent(cumulative)
    ]
    print_result("Binomial", rows, elapsed_ms)
end

function run_poisson()
    println("\nModel: Poisson")
    println("Formula: P(X=k) = exp(-lambda) * lambda^k / k!")
    print_input_guide("Poisson", [
        "lambda = average number of events in an interval. Example: 4.2 calls/hour.",
        "k = exact number of events to evaluate. Example: 7 calls.",
        "Use Poisson when events are independent and happen at average rate lambda."
    ])
    lambda = read_float("lambda (average events per interval)"; format="> 0", example="4.2", minv=1e-12)
    k = read_int("k (exact event count)"; format=">= 0", example="7", minv=0)
    println("Input summary: lambda=$(lambda), k=$(k)")

    started = time_ns()
    p = poisson_pmf(lambda, k)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "Poisson PMF",
        "lambda" => string(lambda),
        "k" => string(k),
        "P(X = k)" => string(round(p, sigdigits=16)),
        "P(X = k) percent" => percent(p)
    ]
    print_result("Poisson", rows, elapsed_ms)
end

function run_bayes()
    println("\nModel: Bayes theorem")
    println("Formula: P(A|B) = P(B|A)*P(A) / P(B)")
    print_input_guide("Bayes", [
        "A = underlying condition/event you want after seeing evidence.",
        "B = observed evidence/signal.",
        "P(B|A) = evidence true when A is true. Example: test sensitivity.",
        "P(A) = prior chance of A before seeing evidence.",
        "P(B) = overall chance of seeing evidence B in population."
    ])
    p_b_given_a = read_float("P(B|A) (evidence if A is true)"; format="0..1", example="0.95", minv=0.0, maxv=1.0)
    p_a = read_float("P(A) (prior chance of A)"; format="0..1", example="0.01", minv=0.0, maxv=1.0)
    p_b = read_float("P(B) (overall chance of evidence)"; format="> 0 and <= 1", example="0.05", minv=1e-15, maxv=1.0)
    println("Input summary: P(B|A)=$(p_b_given_a), P(A)=$(p_a), P(B)=$(p_b)")

    started = time_ns()
    posterior = (p_b_given_a * p_a) / p_b
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "P(A|B) = P(B|A)P(A)/P(B)",
        "P(B|A)" => string(p_b_given_a),
        "P(A)" => string(p_a),
        "P(B)" => string(p_b),
        "P(A|B)" => string(round(posterior, sigdigits=16)),
        "P(A|B) percent" => percent(posterior),
        "consistency_note" => posterior > 1 ? "Inputs are inconsistent (posterior > 1). Re-check P(B)." : "Inputs are self-consistent."
    ]
    print_result("Bayes", rows, elapsed_ms)
end

function run_geometric()
    println("\nModel: Geometric first success")
    println("Formula: P(first success on k) = (1-p)^(k-1) * p")
    print_input_guide("Geometric", [
        "p = success chance per trial. Example: 0.25.",
        "k = trial number when first success happens. Example: 6 means first success on 6th try.",
        "Assumes independent trials with same p each time."
    ])
    p = read_float("p (success chance each trial)"; format="0..1", example="0.25", minv=0.0, maxv=1.0)
    k = read_int("k (trial index for first success)"; format=">= 1", example="6", minv=1)
    println("Input summary: p=$(p), k=$(k)")

    started = time_ns()
    prob = (1.0 - p)^(k - 1) * p
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "(1-p)^(k-1) * p",
        "p" => string(p),
        "k" => string(k),
        "probability" => string(round(prob, sigdigits=16)),
        "probability_percent" => percent(prob)
    ]
    print_result("Geometric", rows, elapsed_ms)
end

function main()
    title_block()
    while true
        try
            menu()
            choice = read_int("Your choice"; format="1..6", example="2", minv=1, maxv=6)
            if choice == 1
                run_at_least_one()
            elseif choice == 2
                run_binomial()
            elseif choice == 3
                run_poisson()
            elseif choice == 4
                run_bayes()
            elseif choice == 5
                run_geometric()
            else
                println("\nGoodbye from Probability Studio.")
                return
            end
        catch err
            println("\nError: $(err)")
        end
    end
end

main()
