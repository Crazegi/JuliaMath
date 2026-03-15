#!/usr/bin/env julia

# Trigonometry Studio - detailed CLI for trigonometric and cosine-law calculations.

using Dates

function line(ch::String="=", n::Int=94)
    println(repeat(ch, n))
end

function title_block()
    line()
    println("TRIGONOMETRY STUDIO")
    println("Detailed sine/cosine/tangent/cotangent and Law of Cosines calculator.")
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

function print_result(title::String, rows::Vector{Pair{String, String}}, elapsed_ms::Float64)
    line("-")
    println("RESULT | " * title)
    line("-")
    for row in rows
        k, v = row
        println(rpad(k, 34) * " : " * v)
    end
    line("-")
    println(rpad("compute_time", 34) * " : " * format_duration(elapsed_ms))
    line("=")
    export_rows("trigonometry_studio", title, rows, elapsed_ms)
end

function parse_kv_blob(blob::AbstractString)
    parsed = Dict{String, String}()
    for part in split(blob, ';')
        t = strip(part)
        isempty(t) && continue
        kv = split(t, '='; limit=2)
        length(kv) == 2 || error("Invalid key=value segment: " * t)
        parsed[strip(kv[1])] = strip(kv[2])
    end
    return parsed
end

function parse_unit(value::AbstractString)
    v = lowercase(strip(value))
    if v == "deg" || v == "degrees"
        return :deg
    elseif v == "rad" || v == "radians"
        return :rad
    end
    error("unit must be deg or rad")
end

function run_batch_mode()
    println("\nBatch mode format per line:")
    println("mode|key=value;key=value")
    println("Examples:")
    println("basic|theta=35;unit=deg")
    println("inverse|v=0.5;t=1.2;unit=deg")
    println("law_side|a=7;b=9;gamma=42;unit=deg")
    println("law_angle|a=7;b=9;c=6;unit=deg")
    println("triangle|a=12;b=15;gamma=33;unit=deg")
    println("wave|A=2.5;B=1.8;C=30;D=-0.7;x=1.2;unit=deg")
    println("identity|theta=12345.678;unit=deg")

    path = prompt_line("Batch file path: ")
    isfile(path) || error("File not found: " * path)

    lines = readlines(path)
    ok_count = 0
    for (idx, line) in enumerate(lines)
        raw = strip(line)
        if isempty(raw) || startswith(raw, "#")
            continue
        end

        println("\n[Batch line $(idx)] " * raw)
        try
            chunks = split(raw, '|'; limit=2)
            length(chunks) == 2 || error("Expected mode|key=value;...")
            mode = lowercase(strip(chunks[1]))
            kv = parse_kv_blob(chunks[2])

            title = ""
            rows = Pair{String, String}[]
            started = time_ns()

            if mode == "basic"
                unit = parse_unit(kv["unit"])
                theta = to_radians(parse(Float64, kv["theta"]), unit)
                s = sin(theta)
                c = cos(theta)
                t = abs(c) < 1e-14 ? nothing : tan(theta)
                ct = abs(s) < 1e-14 ? nothing : safe_cot(theta)
                title = "Basic Trigonometry"
                rows = Pair{String, String}[
                    "sin(theta)" => string(round(s, sigdigits=16)),
                    "cos(theta)" => string(round(c, sigdigits=16)),
                    "tan(theta)" => t === nothing ? "undefined (cos ~ 0)" : string(round(t, sigdigits=16)),
                    "cot(theta)" => ct === nothing ? "undefined (sin ~ 0)" : string(round(ct, sigdigits=16))
                ]
            elseif mode == "inverse"
                unit = parse_unit(kv["unit"])
                v = parse(Float64, kv["v"])
                t = parse(Float64, kv["t"])
                title = "Inverse Trigonometry"
                rows = Pair{String, String}[
                    "asin(v)" => string(round(to_unit(asin(v), unit), sigdigits=16)),
                    "acos(v)" => string(round(to_unit(acos(v), unit), sigdigits=16)),
                    "atan(t)" => string(round(to_unit(atan(t), unit), sigdigits=16))
                ]
            elseif mode == "law_side"
                a = parse(Float64, kv["a"])
                b = parse(Float64, kv["b"])
                unit = parse_unit(kv["unit"])
                gamma = to_radians(parse(Float64, kv["gamma"]), unit)
                c = sqrt(a * a + b * b - 2.0 * a * b * cos(gamma))
                title = "Law of Cosines (side)"
                rows = Pair{String, String}["c" => string(round(c, sigdigits=16))]
            elseif mode == "law_angle"
                a = parse(Float64, kv["a"])
                b = parse(Float64, kv["b"])
                c = parse(Float64, kv["c"])
                unit = parse_unit(kv["unit"])
                cos_gamma = (a * a + b * b - c * c) / (2.0 * a * b)
                gamma = to_unit(acos(max(-1.0, min(1.0, cos_gamma))), unit)
                title = "Law of Cosines (angle)"
                rows = Pair{String, String}["gamma" => string(round(gamma, sigdigits=16))]
            elseif mode == "triangle"
                a = parse(Float64, kv["a"])
                b = parse(Float64, kv["b"])
                unit = parse_unit(kv["unit"])
                gamma = to_radians(parse(Float64, kv["gamma"]), unit)
                c = sqrt(a * a + b * b - 2.0 * a * b * cos(gamma))
                area = 0.5 * a * b * sin(gamma)
                title = "Triangle Summary"
                rows = Pair{String, String}[
                    "side_c" => string(round(c, sigdigits=16)),
                    "area" => string(round(area, sigdigits=16))
                ]
            elseif mode == "wave"
                A = parse(Float64, kv["A"])
                B = parse(Float64, kv["B"])
                unit = parse_unit(kv["unit"])
                C = to_radians(parse(Float64, kv["C"]), unit)
                D = parse(Float64, kv["D"])
                x = parse(Float64, kv["x"])
                y = A * sin(B * x + C) + D
                title = "Trig Wave Equation"
                rows = Pair{String, String}["y" => string(round(y, sigdigits=16))]
            elseif mode == "identity"
                unit = parse_unit(kv["unit"])
                theta = to_radians(parse(Float64, kv["theta"]), unit)
                lhs = sin(theta)^2 + cos(theta)^2
                title = "Trig Identity Check"
                rows = Pair{String, String}["lhs" => string(round(lhs, sigdigits=16)), "absolute_error" => string(abs(lhs - 1.0))]
            else
                error("Unknown mode: " * mode)
            end

            elapsed_ms = (time_ns() - started) / 1_000_000
            print_result(title, rows, elapsed_ms)
            ok_count += 1
        catch err
            println("Batch error on line $(idx): " * string(err))
        end
    end

    println("\nBatch complete. Successful rows: $(ok_count)")
end

function print_input_guide(title::String, items::Vector{String})
    line("-")
    println("INPUT GUIDE | " * title)
    line("-")
    for item in items
        println("- " * item)
    end
    line("-")
end

function choose_angle_unit()
    println("Angle unit:")
    println("1. Degrees")
    println("2. Radians")
    choice = read_int("Unit"; format="1..2", example="1", minv=1, maxv=2)
    return choice == 1 ? :deg : :rad
end

function to_radians(angle::Float64, unit::Symbol)
    return unit == :deg ? angle * (pi / 180.0) : angle
end

function to_unit(angle_rad::Float64, unit::Symbol)
    return unit == :deg ? angle_rad * (180.0 / pi) : angle_rad
end

function safe_cot(x::Float64)
    s = sin(x)
    abs(s) < 1e-14 && error("cot is undefined for this angle (sin is too close to zero)")
    return cos(x) / s
end

function menu()
    println("\nChoose trigonometry mode:")
    println("1. Basic trig of one angle: sin, cos, tan, cot")
    println("   -> Example: evaluate all trig values at 35 degrees")
    println("2. Inverse trig: arcsin, arccos, arctan")
    println("   -> Example: find angle from known ratio/value")
    println("3. Law of Cosines: find side c from a, b, gamma")
    println("   -> Example: side-side-included-angle triangle")
    println("4. Law of Cosines: find angle gamma from a, b, c")
    println("   -> Example: recover included angle from 3 sides")
    println("5. Triangle summary (a, b, gamma)")
    println("   -> Example: compute side c, area, and perimeter")
    println("6. Trig equation y = A*sin(Bx + C) + D")
    println("   -> Example: evaluate signal/wave value at x")
    println("7. Trig identity checker: sin^2 + cos^2")
    println("   -> Example: numerical precision check at large angle")
    println("8. Batch mode from file")
    println("   -> Execute many trigonometry tasks from a text file")
    println("9. Exit")
end

function run_basic_trig()
    println("\nMode: Basic trig of one angle")
    println("Formulas: sin(theta), cos(theta), tan(theta), cot(theta)")
    print_input_guide("Basic trig", [
        "theta = the angle to evaluate.",
        "Choose degree or radian unit first.",
        "tan or cot can be undefined near odd/even multiples of 90 degrees."
    ])

    unit = choose_angle_unit()
    angle = read_float("theta"; format=unit == :deg ? "degrees" : "radians", example=unit == :deg ? "35" : "0.61")
    theta = to_radians(angle, unit)
    println("Input summary: theta=$(angle) $(unit == :deg ? "deg" : "rad")")

    started = time_ns()
    s = sin(theta)
    c = cos(theta)
    t = abs(c) < 1e-14 ? nothing : tan(theta)
    ct = abs(s) < 1e-14 ? nothing : safe_cot(theta)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "angle_input" => string(angle) * " " * (unit == :deg ? "deg" : "rad"),
        "angle_radians" => string(round(theta, sigdigits=16)),
        "sin(theta)" => string(round(s, sigdigits=16)),
        "cos(theta)" => string(round(c, sigdigits=16)),
        "tan(theta)" => t === nothing ? "undefined (cos ~ 0)" : string(round(t, sigdigits=16)),
        "cot(theta)" => ct === nothing ? "undefined (sin ~ 0)" : string(round(ct, sigdigits=16))
    ]

    print_result("Basic Trigonometry", rows, elapsed_ms)
end

function run_inverse_trig()
    println("\nMode: Inverse trig")
    println("Formulas: theta = asin(v), acos(v), atan(v)")
    print_input_guide("Inverse trig", [
        "v for asin/acos must be in range [-1, 1].",
        "atan accepts any real value.",
        "Choose output angle unit (degrees/radians)."
    ])

    unit = choose_angle_unit()
    v = read_float("v for asin/acos"; format="-1..1", example="0.5", minv=-1.0, maxv=1.0)
    t = read_float("t for atan"; format="any real", example="1.2")
    println("Input summary: v=$(v), t=$(t), output=$(unit == :deg ? "deg" : "rad")")

    started = time_ns()
    asin_v = to_unit(asin(v), unit)
    acos_v = to_unit(acos(v), unit)
    atan_t = to_unit(atan(t), unit)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "asin(v)" => string(round(asin_v, sigdigits=16)) * " " * (unit == :deg ? "deg" : "rad"),
        "acos(v)" => string(round(acos_v, sigdigits=16)) * " " * (unit == :deg ? "deg" : "rad"),
        "atan(t)" => string(round(atan_t, sigdigits=16)) * " " * (unit == :deg ? "deg" : "rad")
    ]

    print_result("Inverse Trigonometry", rows, elapsed_ms)
end

function run_law_cos_side()
    println("\nMode: Law of Cosines (find side c)")
    println("Equation: c^2 = a^2 + b^2 - 2ab*cos(gamma)")
    print_input_guide("Find side c", [
        "a and b are known positive side lengths.",
        "gamma is the included angle between sides a and b.",
        "Output c is opposite gamma."
    ])

    a = read_float("a (side length)"; format="> 0", example="7", minv=1e-12)
    b = read_float("b (side length)"; format="> 0", example="9", minv=1e-12)
    unit = choose_angle_unit()
    gamma_in = read_float("gamma"; format=unit == :deg ? "degrees" : "radians", example=unit == :deg ? "42" : "0.73")
    gamma = to_radians(gamma_in, unit)
    println("Input summary: a=$(a), b=$(b), gamma=$(gamma_in) $(unit == :deg ? "deg" : "rad")")

    started = time_ns()
    c2 = a * a + b * b - 2.0 * a * b * cos(gamma)
    c2 < 0 && error("Invalid geometry values produced negative c^2")
    c = sqrt(c2)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "c^2 = a^2 + b^2 - 2ab*cos(gamma)",
        "c" => string(round(c, sigdigits=16)),
        "c^2" => string(round(c2, sigdigits=16))
    ]
    print_result("Law of Cosines (side)", rows, elapsed_ms)
end

function run_law_cos_angle()
    println("\nMode: Law of Cosines (find included angle gamma)")
    println("Equation: cos(gamma) = (a^2 + b^2 - c^2) / (2ab)")
    print_input_guide("Find angle gamma", [
        "a, b, c are known side lengths of a triangle.",
        "Triangle inequality must hold: each side < sum of other two.",
        "gamma is the angle between sides a and b."
    ])

    a = read_float("a"; format="> 0", example="7", minv=1e-12)
    b = read_float("b"; format="> 0", example="9", minv=1e-12)
    c = read_float("c"; format="> 0", example="6", minv=1e-12)
    unit = choose_angle_unit()
    println("Input summary: a=$(a), b=$(b), c=$(c), output=$(unit == :deg ? "deg" : "rad")")

    started = time_ns()
    (a + b > c && a + c > b && b + c > a) || error("Triangle inequality violated")
    cos_gamma = (a * a + b * b - c * c) / (2.0 * a * b)
    cos_gamma < -1.0 - 1e-12 && error("Invalid geometry: cos(gamma) < -1")
    cos_gamma > 1.0 + 1e-12 && error("Invalid geometry: cos(gamma) > 1")
    cos_clamped = max(-1.0, min(1.0, cos_gamma))
    gamma_rad = acos(cos_clamped)
    gamma_out = to_unit(gamma_rad, unit)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "cos(gamma) = (a^2+b^2-c^2)/(2ab)",
        "cos(gamma)" => string(round(cos_gamma, sigdigits=16)),
        "gamma" => string(round(gamma_out, sigdigits=16)) * " " * (unit == :deg ? "deg" : "rad")
    ]
    print_result("Law of Cosines (angle)", rows, elapsed_ms)
end

function run_triangle_summary()
    println("\nMode: Triangle summary from a, b, gamma")
    println("Uses Law of Cosines and area formula 0.5*a*b*sin(gamma)")
    print_input_guide("Triangle summary", [
        "Given two sides and the included angle, this mode computes side c.",
        "Also computes perimeter and area.",
        "Useful for engineering/layout geometry problems."
    ])

    a = read_float("a"; format="> 0", example="12", minv=1e-12)
    b = read_float("b"; format="> 0", example="15", minv=1e-12)
    unit = choose_angle_unit()
    gamma_in = read_float("gamma"; format=unit == :deg ? "degrees" : "radians", example=unit == :deg ? "33" : "0.575")
    gamma = to_radians(gamma_in, unit)
    println("Input summary: a=$(a), b=$(b), gamma=$(gamma_in) $(unit == :deg ? "deg" : "rad")")

    started = time_ns()
    c = sqrt(a * a + b * b - 2.0 * a * b * cos(gamma))
    perimeter = a + b + c
    area = 0.5 * a * b * sin(gamma)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "side_c" => string(round(c, sigdigits=16)),
        "perimeter" => string(round(perimeter, sigdigits=16)),
        "area" => string(round(area, sigdigits=16))
    ]
    print_result("Triangle Summary", rows, elapsed_ms)
end

function run_trig_equation_wave()
    println("\nMode: Trig equation y = A*sin(Bx + C) + D")
    println("Equation: y(x) = A*sin(Bx + C) + D")
    print_input_guide("Wave equation", [
        "A = amplitude (vertical stretch).",
        "B = frequency scale (horizontal compression/stretch).",
        "C = phase shift angle, entered in chosen angle unit.",
        "D = vertical shift.",
        "x = input variable value."
    ])

    A = read_float("A (amplitude)"; format="real", example="2.5")
    B = read_float("B (frequency scale)"; format="real", example="1.8")
    unit = choose_angle_unit()
    C_in = read_float("C (phase shift)"; format=unit == :deg ? "degrees" : "radians", example=unit == :deg ? "30" : "0.52")
    D = read_float("D (vertical shift)"; format="real", example="-0.7")
    x = read_float("x (input variable)"; format="real", example="1.2")

    C = to_radians(C_in, unit)
    println("Input summary: A=$(A), B=$(B), C=$(C_in) $(unit == :deg ? "deg" : "rad"), D=$(D), x=$(x)")

    started = time_ns()
    arg = B * x + C
    y = A * sin(arg) + D
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "equation" => "y = A*sin(Bx + C) + D",
        "argument(Bx + C)" => string(round(arg, sigdigits=16)) * " rad",
        "y" => string(round(y, sigdigits=16))
    ]
    print_result("Trig Wave Equation", rows, elapsed_ms)
end

function run_identity_checker()
    println("\nMode: Identity checker")
    println("Identity: sin(theta)^2 + cos(theta)^2 = 1")
    print_input_guide("Identity checker", [
        "Provides numeric check of the core trig identity.",
        "Useful for understanding floating-point precision behavior."
    ])

    unit = choose_angle_unit()
    theta_in = read_float("theta"; format=unit == :deg ? "degrees" : "radians", example=unit == :deg ? "12345.678" : "350.12")
    theta = to_radians(theta_in, unit)
    println("Input summary: theta=$(theta_in) $(unit == :deg ? "deg" : "rad")")

    started = time_ns()
    lhs = sin(theta)^2 + cos(theta)^2
    error_abs = abs(lhs - 1.0)
    elapsed_ms = (time_ns() - started) / 1_000_000

    rows = Pair{String, String}[
        "lhs" => string(round(lhs, sigdigits=16)),
        "target" => "1",
        "absolute_error" => string(round(error_abs, sigdigits=16))
    ]
    print_result("Trig Identity Check", rows, elapsed_ms)
end

function main()
    title_block()
    while true
        try
            menu()
            choice = read_int("Your choice"; format="1..9", example="1", minv=1, maxv=9)
            if choice == 1
                run_basic_trig()
            elseif choice == 2
                run_inverse_trig()
            elseif choice == 3
                run_law_cos_side()
            elseif choice == 4
                run_law_cos_angle()
            elseif choice == 5
                run_triangle_summary()
            elseif choice == 6
                run_trig_equation_wave()
            elseif choice == 7
                run_identity_checker()
            elseif choice == 8
                run_batch_mode()
            else
                println("\nGoodbye from Trigonometry Studio.")
                return
            end
        catch err
            println("\nError: $(err)")
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
