# summary.blvim_logs prints a text summary

    Code
      summary(logs)
    Output
      
      -- Summary of 6 runs of blvim --
      
      * 5 of 6 runs converged.
      * Status: converged (5) and max_iterations (1).
      * Iterations: median 22.5, range [10, 100].
      * Evaluations: median 27.5, range [12, 150].
      * Largest duality gap of the converged runs: 5e-07.
      
      -- Final configurations 
      4 distinct configurations. The best one (potential -1, 4 active destinations)
      was reached by 3 of 6 runs.
      The second best potential is -1.5 (difference 0.5).
       configuration potential n_active runs share converged
                   1      -1.0        4    3 0.500         3
                   2      -1.5        3    1 0.167         1
                   3      -2.0        3    1 0.167         1
                   4      -3.0        2    1 0.167         0

---

    Code
      summary(single_best)
    Output
      
      -- Summary of 6 runs of blvim --
      
      * 4 of 6 runs converged.
      * Status: converged (4) and max_iterations (2).
      * Iterations: median 22.5, range [10, 100].
      * Evaluations: median 27.5, range [12, 150].
      * Largest duality gap of the converged runs: 5e-07.
      
      -- Final configurations 
      5 distinct configurations. The best one (potential -1, 4 active destinations)
      was reached by 1 of 6 runs.
      The second best potential is -1.1 (difference 0.1).
       configuration potential n_active runs share converged
                   1      -1.0        4    1 0.167         0
                   2      -1.1        4    2 0.333         2
                   3      -1.5        3    1 0.167         1
                   4      -2.0        3    1 0.167         1
                   5      -3.0        2    1 0.167         0
      ! The best configuration was reached by a single run: more starting
      points might find a better one.
      ! The selected run did not converge.

# summary.blvim_logs shows only the five best configurations

    Code
      summary(logs)
    Output
      
      -- Summary of 8 runs of blvim --
      
      * 8 of 8 runs converged.
      * Status: converged (8).
      * Iterations: median 10, range [10, 10].
      * Evaluations: median 12, range [12, 12].
      * Largest duality gap of the converged runs: 1e-07.
      
      -- Final configurations 
      8 distinct configurations. The best one (potential -1, 3 active destinations)
      was reached by 1 of 8 runs.
      The second best potential is -2 (difference 1).
       configuration potential n_active runs share converged
                   1        -1        3    1 0.125         1
                   2        -2        3    1 0.125         1
                   3        -3        3    1 0.125         1
                   4        -4        3    1 0.125         1
                   5        -5        3    1 0.125         1
      ... and 3 more.
      ! The best configuration was reached by a single run: more starting
      points might find a better one.

