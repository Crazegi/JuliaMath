#!/usr/bin/env julia

# Math Visual Studio
# Window-based dynamic graphing app for logarithms and trigonometric functions.

using Pkg

function ensure_package(pkg::String)
    if Base.find_package(pkg) === nothing
        println("Installing package: " * pkg)
        Pkg.add(pkg)
    end
end

ensure_package("GLMakie")

using GLMakie

GLMakie.activate!()

function slider_with_label(parent, row::Int, title::String, range; startvalue)
    Label(parent[row, 1], title, tellwidth=false)
    s = Slider(parent[row, 2], range=range, startvalue=startvalue)
    v = Label(parent[row, 3], @lift(string(round($s.value, sigdigits=6))), tellwidth=false)
    return s, v
end

function main()
    fig = Figure(size=(1400, 900), fontsize=16)

    title = Label(
        fig[1, 1:2],
        "Math Visual Studio - Dynamic Logarithm & Trigonometric Graphs",
        fontsize=24,
        font=:bold,
        tellwidth=false
    )

    subtitle = Label(
        fig[2, 1:2],
        "Move sliders to change equations in real time. Left: logarithm model. Right: trigonometric wave model.",
        fontsize=13,
        tellwidth=false
    )

    ax_log = Axis(fig[3, 1], title="Logarithm Model", xlabel="x", ylabel="y")
    ax_trig = Axis(fig[3, 2], title="Trigonometric Model", xlabel="x", ylabel="y")

    controls_log = GridLayout()
    controls_trig = GridLayout()
    fig[4, 1] = controls_log
    fig[4, 2] = controls_trig

    # Log equation: y = a * log(b*x + shift) + c
    # shift is constrained to keep domain positive for x >= x_min.
    x_min = 0.001
    x_max = 20.0
    xs = range(x_min, x_max; length=1200)

    log_a, _ = slider_with_label(controls_log, 1, "a (vertical scale)", -5.0:0.01:5.0; startvalue=1.0)
    log_b, _ = slider_with_label(controls_log, 2, "b (x scale)", 0.05:0.01:5.0; startvalue=1.0)
    log_shift, _ = slider_with_label(controls_log, 3, "shift (domain offset)", 0.001:0.01:10.0; startvalue=1.0)
    log_c, _ = slider_with_label(controls_log, 4, "c (vertical shift)", -10.0:0.01:10.0; startvalue=0.0)

    ys_log = @lift($log_a.value .* log.($log_b.value .* xs .+ $log_shift.value) .+ $log_c.value)
    lines!(ax_log, xs, ys_log, color=:tomato, linewidth=3)

    log_eq_label = Label(
        controls_log[5, 1:3],
        @lift("y = " * string(round($log_a.value, sigdigits=5)) *
              " * log(" * string(round($log_b.value, sigdigits=5)) * "*x + " *
              string(round($log_shift.value, sigdigits=5)) * ") + " *
              string(round($log_c.value, sigdigits=5))),
        tellwidth=false
    )

    # Trig equation: y = A*sin(B*x + C) + D
    trig_A, _ = slider_with_label(controls_trig, 1, "A (amplitude)", -5.0:0.01:5.0; startvalue=2.0)
    trig_B, _ = slider_with_label(controls_trig, 2, "B (frequency)", 0.05:0.01:10.0; startvalue=1.5)
    trig_C, _ = slider_with_label(controls_trig, 3, "C (phase, rad)", -2pi:0.01:2pi; startvalue=0.0)
    trig_D, _ = slider_with_label(controls_trig, 4, "D (vertical shift)", -5.0:0.01:5.0; startvalue=0.0)

    ys_trig = @lift($trig_A.value .* sin.($trig_B.value .* xs .+ $trig_C.value) .+ $trig_D.value)
    lines!(ax_trig, xs, ys_trig, color=:deepskyblue3, linewidth=3)

    trig_eq_label = Label(
        controls_trig[5, 1:3],
        @lift("y = " * string(round($trig_A.value, sigdigits=5)) *
              " * sin(" * string(round($trig_B.value, sigdigits=5)) * "*x + " *
              string(round($trig_C.value, sigdigits=5)) * ") + " *
              string(round($trig_D.value, sigdigits=5))),
        tellwidth=false
    )

    display(title)
    display(subtitle)
    display(log_eq_label)
    display(trig_eq_label)

    screen = display(fig)
    wait(screen)
end

main()
