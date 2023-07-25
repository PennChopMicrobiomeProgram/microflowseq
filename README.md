
<!-- README.md is generated from README.Rmd. Please edit that file -->

# microflowseq

<!-- badges: start -->
<!-- badges: end -->

The goal of microflowseq is to assign probabilities to bacteria that are
sorted in mFLOW-Seq experiments.

## Installation

You can install the development version of microflowseq like so:

``` r
devtools::install_github("PennChopMicrobiomeProgram/microflowseq")
```

## Example: dual-seq

``` r
library(microflowseq)
```

``` r
library(tidyverse)
```

``` r
# Species in rows, channel in columns
dual_cts <- cbind(`IgA+` = c(sa = 5, sb = 7), `IgA-` = c(sa = 19, sb = 13))
```

The real answer

``` r
dual_cts %>%
  sweep(1, rowSums(dual_cts), `/`)
#>         IgA+      IgA-
#> sa 0.2083333 0.7916667
#> sb 0.3500000 0.6500000
```

The things we measure

``` r
dual_fracs <- renormalize(colSums(dual_cts))
# Species in rows, channels in columns
dual_props <- dual_cts %>%
  sweep(2, colSums(dual_cts), `/`)
```

Solve in matrix format

``` r
mflow_apply(dual_props, dual_fracs)
#>         IgA+      IgA-
#> sa 0.2083333 0.7916667
#> sb 0.3500000 0.6500000
```

Solve in long format. First prepare the data.

``` r
dual_props_df <- dual_props %>%
  as.data.frame() %>%
  rownames_to_column("asv") %>%
  pivot_longer(-asv, names_to = "fraction", values_to = "proportion") %>%
  # In real studies, we'll have more specimens
  # Add a specimen ID so we can demonstrate how it would work
  mutate(specimen_id = "Specimen1") %>%
  select(specimen_id, everything())
dual_fracs_df <- dual_fracs %>%
  enframe("fraction", "fraction_abundance") %>%
  mutate(specimen_id = "Specimen1") %>%
  select(specimen_id, everything())
```

Then, use the tidyverse to generate prbabilities.

``` r
dual_props_df %>%
  # Join the table of fraction abundances for each specimen
  left_join(dual_fracs_df, by = c("specimen_id", "fraction")) %>%
  # The function is valid for one ASV in one specimen
  group_by(specimen_id, asv) %>%
  # I'm tempted to name the column the same as the function :(
  mutate(mflow_prob = mflow_probability(proportion, fraction_abundance))
#> # A tibble: 4 × 6
#> # Groups:   specimen_id, asv [2]
#>   specimen_id asv   fraction proportion fraction_abundance mflow_prob
#>   <chr>       <chr> <chr>         <dbl>              <dbl>      <dbl>
#> 1 Specimen1   sa    IgA+          0.417              0.273      0.208
#> 2 Specimen1   sa    IgA-          0.594              0.727      0.792
#> 3 Specimen1   sb    IgA+          0.583              0.273      0.35 
#> 4 Specimen1   sb    IgA-          0.406              0.727      0.65
```

## Example: multi-seq

``` r
# Species in rows, channel in columns
multi_cts <- cbind(
  `IgA+IgG+` = c(sa = 5, sb = 7),
  `IgA+IgG-` = c(sa = 19, sb = 13),
  `IgA-IgG+` = c(sa = 2, sb = 11),
  `IgA-IgG-` = c(sa = 23, sb = 29))
```

The real answer

``` r
multi_cts %>%
  sweep(1, rowSums(multi_cts), `/`)
#>     IgA+IgG+  IgA+IgG-   IgA-IgG+  IgA-IgG-
#> sa 0.1020408 0.3877551 0.04081633 0.4693878
#> sb 0.1166667 0.2166667 0.18333333 0.4833333
```

The things we measure

``` r
multi_fracs <- renormalize(colSums(multi_cts))
# Species in rows, channels in columns
multi_props <- multi_cts %>%
  apply(2, renormalize)
```

Solve in matrix format

``` r
mflow_apply(multi_props, multi_fracs)
#>     IgA+IgG+  IgA+IgG-   IgA-IgG+  IgA-IgG-
#> sa 0.1020408 0.3877551 0.04081633 0.4693878
#> sb 0.1166667 0.2166667 0.18333333 0.4833333
```
