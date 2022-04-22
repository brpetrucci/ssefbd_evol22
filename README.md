# Testing SSE models with FBD

This repository contains simulation and analysis scripts for a simulation study intending to test the power and error rates of State Speciation and Extinction (SSE) models with the inclusion of fossil data using a Fossilized Birth-Death (FBD) model.

## Proof of concept: EEOB 565

The first stage of this project will be a simpler proof of concept style simulation study to assess the performance of BiSSE estimates of extinction rates using an FBD tree. This will serve as my final project for [EEOB565](https://eeob-macroevolution.github.io/).

For this abridged version of the project, I will replicate the analysis in Maddison et al 2007, the initial tests of BiSSE, for data simulated under BiSSE with the inclusion of fossil sampling. As such, we can gain insight on how the addition of fossil tips and sampled ancestors can improve estimates, in particular with regards to extinction rate.


I will simulate under four different parameter combinations. First, speciation (lambda), extinction (mu), and state transition (q01, q10) rates will all be independent of state (i.e. the equivalent of a normal FBD model). Each other parameter combination will see change in one of the rates for one of the states. Namely, lambda will be double for state 1, mu double for state 0, and q01 double q10, respectively. Rate values will mirror those of Maddison et al 2007, and fossil sampling rate rho (serial sampling rate psi in the RevBayes analyses) will be reasonably low, such that we expect around 25% of extinct species to be sampled.

For each of these parameter combinations, I will simulate 100 trees with 500 species each. Simulation of phylogenetic trees and fossil records using the birth-death process are implemented in my package [paleobuddy](https://github.com/brpetrucci/paleobuddy), though trait dependent simulations are currently in development (see [dev_traits branch](https://github.com/brpetrucci/paleobuddy/tree/dev_traits)), and not reflected on CRAN. For each replicate, I will simulate a birth-death process, a fossil record, and both ultrametric trees and trees containing sampled ancestors and fossil tips (henceforth, FBD trees), plus trait data for both extant species and fossil samples (simulated jointly under BiSSE). 

I will then use [RevBayes](https://github.com/revbayes/revbayes) to estimate the six parameters of interest in BiSSE: lambda0, lambda1, mu0, mu1, q01, and q10. I will roughly follow the [BiSSE RevBayes tutorial](https://revbayes.github.io/tutorials/sse/bisse.html), with the addition of serial sampling for FBD trees--though I will set the serial sampling rate to its true valueso as not to confuse performance in estimation of serial sampling and extinction rates. I will then evaluate the convergence of parameters of interest using the [coda R package](https://cran.r-project.org/web/packages/coda/index.html), and compare the rate estimates from trees generated under state-independent rates with the other three parameter combinations.
