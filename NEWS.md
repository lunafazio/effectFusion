# effectFusion 1.1.4

* Package returns to CRAN after being archived on 2022-05-25.
* New maintainer: Luna Fazio.
* Fixed compilation with current R: `src/MatrixFrame.h` now includes
  `R_ext/Print.h` instead of the removed `R_ext/PrtUtil.h`.
* Fixed `-Wint-in-bool-context` compiler warning in `Logit::data_conforms()`.
* Fixed Rd check problem in `effectFusion()` documentation: `\describe`
  items no longer have empty labels.
