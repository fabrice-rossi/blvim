# summary.blvim_history describes the face changes

    Code
      summary(dying)
    Output
      
      -- Iteration history of a gradient ascent --
      
      * 30 iterations, potential from -2 to -1.
      * Final duality gap: 1.863e-09.
      * Convergence rate of the duality gap: 0.5 per iteration.
      * Line search: 30 step reductions, smallest accepted step 0.1.
      * 5 active destinations, no face change.
      ! The smallest rescaled attractiveness decreased to
      1e-04: a destination may be slowly vanishing.

---

    Code
      summary(synthetic_history(n_active = active, min_U = 0))
    Output
      
      -- Iteration history of a gradient ascent --
      
      * 30 iterations, potential from -2 to -1.
      * Final duality gap: 1.863e-09.
      * Convergence rate of the duality gap: 0.5 per iteration.
      * Line search: 30 step reductions, smallest accepted step 0.1.
      * Active destinations: from 5 to 3, 4 face changes, the last one at iteration
      5.
      * The final configuration is on a face of the simplex.

# summary.blvim_history prints a text summary

    Code
      summary(synthetic_history(rate = 0.3))
    Output
      
      -- Iteration history of a gradient ascent --
      
      * 30 iterations, potential from -2 to -1.
      * Final duality gap: 6.863e-16.
      * Convergence rate of the duality gap: 0.3 per iteration.
      * Line search: 30 step reductions, smallest accepted step 0.1.
      * 5 active destinations, no face change.

---

    Code
      summary(synthetic_history(min_U = 0))
    Output
      
      -- Iteration history of a gradient ascent --
      
      * 30 iterations, potential from -2 to -1.
      * Final duality gap: 1.863e-09.
      * Convergence rate of the duality gap: 0.5 per iteration.
      * Line search: 30 step reductions, smallest accepted step 0.1.
      * 5 active destinations, no face change.
      * The final configuration is on a face of the simplex.

---

    Code
      summary(blvim:::new_blvim_history(history))
    Output
      
      -- Iteration histories of 2 gradient ascents --
      
      * Iterations: median 20, range [10, 30].
      * Largest final duality gap: 0.001953.
      * Convergence rate of the duality gap: median 0.5, range [0.5, 0.5].
      * Face changes: median 0, range [0, 0].
      * 1 of 2 final configurations on a face of the simplex.
       sim iterations final_potential final_gap rate final_active face_changes
         1         30          -1.000 1.863e-09  0.5            5            0
         2         10          -1.002 1.953e-03  0.5            5            0
       last_change
                NA
                NA

# summary.blvim_history prints a summary of many runs

    Code
      summary(history)
    Output
      
      -- Iteration histories of 22 gradient ascents --
      
      * Iterations: median 10, range [10, 10].
      * Largest final duality gap: 0.001953.
      * Convergence rate of the duality gap: median 0.5, range [0.5, 0.5].
      * Face changes: median 0, range [0, 0].
      * 0 of 22 final configurations on a face of the simplex.
      ! In 1 run, a destination may be slowly
      vanishing.
       sim iterations final_potential final_gap rate final_active face_changes
         1         10          -1.002  0.001953  0.5            5            0
         2         10          -1.002  0.001953  0.5            5            0
         3         10          -1.002  0.001953  0.5            5            0
         4         10          -1.002  0.001953  0.5            5            0
         5         10          -1.002  0.001953  0.5            5            0
         6         10          -1.002  0.001953  0.5            5            0
         7         10          -1.002  0.001953  0.5            5            0
         8         10          -1.002  0.001953  0.5            5            0
         9         10          -1.002  0.001953  0.5            5            0
        10         10          -1.002  0.001953  0.5            5            0
        11         10          -1.002  0.001953  0.5            5            0
        12         10          -1.002  0.001953  0.5            5            0
        13         10          -1.002  0.001953  0.5            5            0
        14         10          -1.002  0.001953  0.5            5            0
        15         10          -1.002  0.001953  0.5            5            0
        16         10          -1.002  0.001953  0.5            5            0
        17         10          -1.002  0.001953  0.5            5            0
        18         10          -1.002  0.001953  0.5            5            0
        19         10          -1.002  0.001953  0.5            5            0
        20         10          -1.002  0.001953  0.5            5            0
       last_change
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
                NA
      ... and 2 more.

