# sim_diagnostic objects prints as expected

    Code
      sim_diagnostic(model)
    Output
      Static spatial interaction model

---

    Code
      sim_diagnostic(model)
    Output
      BLV model obtained with the "linear" algorithm.
      i The algorithm converged after 2200 iterations.

---

    Code
      sim_diagnostic(model_noconv)
    Output
      BLV model obtained with the "linear" algorithm.
      ! The algorithm did not converged after 1000 iterations.

---

    Code
      sim_diagnostic(model)
    Output
      BLV model obtained with the "gradient" algorithm.
      ! The algorithm stopped after 415 iterations:
      * Number of potential evaluations: 529.
      * Duality gap: 1.214813e-06.
      * Return status: "stalled".

---

    Code
      sim_diagnostic(model)
    Output
      BLV model obtained with the "gradient" algorithm.
      i The algorithm converged after 305 iterations:
      * Number of potential evaluations: 390.
      * Duality gap: 4.071842e-05.
      * Return status: "converged".

---

    Code
      sim_diagnostic(model_noconv)
    Output
      BLV model obtained with the "gradient" algorithm.
      ! The algorithm stopped after 100 iterations:
      * Number of potential evaluations: 134.
      * Duality gap: 0.09929525.
      * Return status: "maximum iteration reached".

