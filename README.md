
<!-- README.md is generated from README.Rmd. Please edit that file -->

# microflowseq

<!-- badges: start -->

[![R-CMD-check](https://github.com/PennChopMicrobiomeProgram/microflowseq/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/PennChopMicrobiomeProgram/microflowseq/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/PennChopMicrobiomeProgram/microflowseq/branch/main/graph/badge.svg)](https://app.codecov.io/gh/PennChopMicrobiomeProgram/microflowseq?branch=main)
<!-- badges: end -->

The goal of microflowseq is to assign probabilities to bacteria that are
sorted in mFLOW-Seq experiments.

## Installation

You can install the development version of microflowseq like so:

``` r
devtools::install_github("PennChopMicrobiomeProgram/microflowseq")
```

## Example: mFLOW-Seq with two fractions

``` r
library(microflowseq)
```

Imagine an experiment where we have a specimen containing organisms from
two species, *Escherichia coli* and *Streptococcus mitis*. The organisms
are sorted into two fractions, IgA+ and IgA-. Let’s create a matrix
giving the actual number of organisms. Here, the species are represented
in the rows of the matrix and the fractions are represented in columns.

``` r
dual_cts <- matrix(
  c(5, 7, 19, 13), nrow = 2,
  dimnames = list(c("e.coli", "s.mitis"), c("IgA+", "IgA-")))
dual_cts
#>         IgA+ IgA-
#> e.coli     5   19
#> s.mitis    7   13
```

For each species, we are interested in the probability of finding an
organism in the IgA+ or IgA- fraction. This is straightforward to
calculate if we know the absolute number of organisms: we simply
calculate a probability across each row.[^1] The `microflowseq` package
provides a function, `normalize_sum()` to perform the common task of
converting to probability or relative abundance.

``` r
t(apply(dual_cts, 1, normalize_sum))
#>              IgA+      IgA-
#> e.coli  0.2083333 0.7916667
#> s.mitis 0.3500000 0.6500000
```

However, we don’t measure the absolute number of organisms directly in a
real experiment, so we can’t use the method above to calculate the
probabilities. In an mFLOW-Seq experiment, we measure two things: the
abundance of each fraction, and, within each fraction, the relative
abundance of the bacteria.

First, we compute the abundance of each fraction by summing down the
columns. To show that our approach does not depend on the scale of the
fraction abundance, we multiply the absolute fraction abundances by a
large number.

``` r
dual_fracs <- 35 * colSums(dual_cts)
dual_fracs
#> IgA+ IgA- 
#>  420 1120
```

Next, we compute the relative abundance of each species within each
fraction.

``` r
dual_props <- apply(dual_cts, 2, normalize_sum)
dual_props
#>              IgA+    IgA-
#> e.coli  0.4166667 0.59375
#> s.mitis 0.5833333 0.40625
```

We now have our example data set: a vector of fraction abundances
(`dual_fracs`) and a matrix of bacteria relative abundances within each
fraction (`dual_props`). As before, each row corresponds to a bacterial
species and each column corresponds to a fraction.

We can use `mflow_apply()` to solve for the probabilities. The answer
here matches what we computed when we knew the exact number of organisms
in each fraction. Success!

``` r
mflow_apply(dual_props, dual_fracs)
#>              IgA+      IgA-
#> e.coli  0.2083333 0.7916667
#> s.mitis 0.3500000 0.6500000
```

## Example: mFLOW-Seq with multiple fractions

Let’s imagine that the bacteria were sorted into four fractions,
according to whether they were tagged by IgA, IgG, both, or neither.

``` r
multi_cts <- matrix(
  c(5, 7, 19, 13, 2, 11, 23, 29), nrow=2,
  dimnames = list(
    c("e.coli", "s.mitis"),
    c("IgA+IgG+", "IgA+IgG-", "IgA-IgG+", "IgA-IgG-")))
multi_cts
#>         IgA+IgG+ IgA+IgG- IgA-IgG+ IgA-IgG-
#> e.coli         5       19        2       23
#> s.mitis        7       13       11       29
```

As before, we want to work one species at a time and calculate how
organisms of the species are distributed among the fractions. Both
organisms are found in the double negative fraction about half the time.
*E. coli* is almost never found in the IgA-IgG+ fraction, whereas that
fraction accounts for about 18% of the *S. mitis* organisms.

``` r
t(apply(multi_cts, 1, normalize_sum))
#>          IgA+IgG+  IgA+IgG-   IgA-IgG+  IgA-IgG-
#> e.coli  0.1020408 0.3877551 0.04081633 0.4693878
#> s.mitis 0.1166667 0.2166667 0.18333333 0.4833333
```

Here is what we measure in the experiment. As before, I multiply the
fraction abundances by some number to show that the absolute scale
doesn’t matter.

``` r
multi_fracs <- 0.2 * colSums(multi_cts)
multi_fracs
#> IgA+IgG+ IgA+IgG- IgA-IgG+ IgA-IgG- 
#>      2.4      6.4      2.6     10.4
multi_props <- apply(multi_cts, 2, normalize_sum)
multi_props
#>          IgA+IgG+ IgA+IgG-  IgA-IgG+  IgA-IgG-
#> e.coli  0.4166667  0.59375 0.1538462 0.4423077
#> s.mitis 0.5833333  0.40625 0.8461538 0.5576923
```

With the data in hand, `mflow_apply()` works just the same as it did for
the previous example. Here’s the answer we wanted.

``` r
mflow_apply(multi_props, multi_fracs)
#>          IgA+IgG+  IgA+IgG-   IgA-IgG+  IgA-IgG-
#> e.coli  0.1020408 0.3877551 0.04081633 0.4693878
#> s.mitis 0.1166667 0.2166667 0.18333333 0.4833333
```

## Example: long format

With the advent of the tidyverse, it’s no longer common to work in
matrix format in the R programming language. This is probably a good
thing overall; it encourages people to work in a long format, where each
data point is represented in one row of a table.

Let’s go back to our first example and convert the data to long format,
so we can show how to use the `microflowseq` library in that context.
First, we’ll load the collection of packages in the tidyverse.

``` r
library(tidyverse)
```

It’s actually a bit of a pain to convert our data from the matrix
format. We won’t explain the process line-by-line, but we’ll show the
answer so you can check that it matches the example above.

Here are the fraction abundances. We add a column to indicate the
specimen from which the bacteria were sorted. In a typical sequencing
experiment, you’d have many specimens.

``` r
dual_fracs_df <- dual_fracs |>
  enframe("fraction", "fraction_abundance") |>
  mutate(specimen_id = "Specimen1") |>
  select(specimen_id, everything())
dual_fracs_df
#> # A tibble: 2 x 3
#>   specimen_id fraction fraction_abundance
#>   <chr>       <chr>                 <dbl>
#> 1 Specimen1   IgA+                    420
#> 2 Specimen1   IgA-                   1120
```

Here are the bacteria relative abundances. Again, we add a specimen ID
because this is important to the demonstration of data in long format.
Each fraction derived from a specimen would appear as a different sample
in the sequencing data. To keep track of which samples were derived from
each specimen, you would use a separate column for the specimen ID, just
as we’ve done here.

Also, we’re going to name the species column “asv”, for amplicon
sequence variant. In a real sequencing experiment, we often measure
sequence variants rather than the actual species *per se*. Hopefully,
this makes our data table look more similar to what you’d see in a real
study.

``` r
dual_props_df <- dual_props |>
  as.data.frame() |>
  rownames_to_column("asv") |>
  pivot_longer(-asv, names_to = "fraction", values_to = "asv_abundance") |>
  mutate(specimen_id = "Specimen1") |>
  select(specimen_id, fraction, everything())
dual_props_df
#> # A tibble: 4 x 4
#>   specimen_id fraction asv     asv_abundance
#>   <chr>       <chr>    <chr>           <dbl>
#> 1 Specimen1   IgA+     e.coli          0.417
#> 2 Specimen1   IgA-     e.coli          0.594
#> 3 Specimen1   IgA+     s.mitis         0.583
#> 4 Specimen1   IgA-     s.mitis         0.406
```

Using data in long format, we compute the probabilities in three steps:

1.  Join the fraction abundance table to the bacteria relative abundance
    table.
2.  Group by specimen ID and species (ASV).
3.  Use `mflow_probability()` to compute the probabilities.

The `mflow_probability()` function works on one species/ASV at a time.
Under the hood, this function is used by `mflow_apply()` when we work in
matrix format. Here, we no longer have to think about rows and columns,
and our result is ready to feed into `ggplot2` for visualization.

``` r
dual_props_df |>
  left_join(dual_fracs_df, by = c("specimen_id", "fraction")) |>
  group_by(specimen_id, asv) |>
  mutate(fraction_prob = mflow_probability(asv_abundance, fraction_abundance))
#> # A tibble: 4 x 6
#> # Groups:   specimen_id, asv [2]
#>   specimen_id fraction asv     asv_abundance fraction_abundance fraction_prob
#>   <chr>       <chr>    <chr>           <dbl>              <dbl>         <dbl>
#> 1 Specimen1   IgA+     e.coli          0.417                420         0.208
#> 2 Specimen1   IgA-     e.coli          0.594               1120         0.792
#> 3 Specimen1   IgA+     s.mitis         0.583                420         0.35 
#> 4 Specimen1   IgA-     s.mitis         0.406               1120         0.65
```

[^1]: Unfortunately, I have to transpose the result after I apply a
    function across the rows of a matrix. It makes the code messier, but
    it’s necessary because R will flip the rows and columns otherwise.
