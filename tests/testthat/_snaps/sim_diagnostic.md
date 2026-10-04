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
      ! The algorithm stopped after 403 iterations:
      * Number of potential evaluations: 514.
      * Duality gap: 2.988258e-08.
      * Return status: "stalled".

---

    Code
      sim_diagnostic(model)
    Output
      BLV model obtained with the "gradient" algorithm.
      i The algorithm converged after 284 iterations:
      * Number of potential evaluations: 363.
      * Duality gap: 1.938069e-06.
      * Return status: "converged".

---

    Code
      sim_diagnostic(model_noconv)
    Output
      BLV model obtained with the "gradient" algorithm.
      ! The algorithm stopped after 100 iterations:
      * Number of potential evaluations: 134.
      * Duality gap: 0.002428494.
      * Return status: "maximum iteration reached".

