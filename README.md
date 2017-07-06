
<!-- README.md is generated from README.Rmd. Please edit that file -->
easyphreeqc
===========

The goal of easyphreeqc is to provide a more useful interface to the existing phreeqc package.

Installation
------------

You can install easyphreeqc from github with:

``` r
# install.packages("devtools")
devtools::install_github("paleolimbot/easyphreeqc")
```

Example
-------

Running PHREEQC is accomplished using the `phreeqc()` function, which calls the program and generates the output. The function accepts character vectors of input, which can be generated using intput helper functions such as `solution()`, `selected_output()`, `equilibrium_phases()`, and `reaction_temperature()` (or roll your own input using `phreeqc_input()`). To get the raw output of PHREEQC, you will have to pass `quiet = FALSE`.

``` r
library(easyphreeqc)
phreeqc(
  solution(pH = 7, temp = 25),
  quiet = FALSE
)
#> ------------------------------------
#> Reading input data for simulation 1.
#> ------------------------------------
#> 
#>  SOLUTION 1
#>      pH    7
#>      temp    25
#> -------------------------------------------
#> Beginning of initial solution calculations.
#> -------------------------------------------
#> 
#> Initial solution 1.  
#> 
#> -----------------------------Solution composition------------------------------
#> 
#>  Elements           Molality       Moles
#> 
#>  Pure water     
#> 
#> ----------------------------Description of solution----------------------------
#> 
#>                                        pH  =   7.000    
#>                                        pe  =   4.000    
#>       Specific Conductance (uS/cm,  25oC)  = 0
#>                           Density (g/cm3)  =   0.99704
#>                                Volume (L)  =   1.00297
#>                         Activity of water  =   1.000
#>                  Ionic strength (mol/kgw)  =   1.007e-07
#>                        Mass of water (kg)  =   1.000e+00
#>                  Total alkalinity (eq/kg)  =   1.217e-09
#>                     Total carbon (mol/kg)  =   0.000e+00
#>                        Total CO2 (mol/kg)  =   0.000e+00
#>                          Temperature (oC)  =  25.00
#>                   Electrical balance (eq)  =  -1.217e-09
#>  Percent error, 100*(Cat-|An|)/(Cat+|An|)  =  -0.60
#>                                Iterations  =   0
#>                                   Total H  = 1.110124e+02
#>                                   Total O  = 5.550622e+01
#> 
#> ----------------------------Distribution of species----------------------------
#> 
#>                                                Log       Log       Log    mole V
#>    Species          Molality    Activity  Molality  Activity     Gamma   cm3/mol
#> 
#>    OH-             1.013e-07   1.012e-07    -6.995    -6.995    -0.000     -4.14
#>    H+              1.001e-07   1.000e-07    -7.000    -7.000    -0.000      0.00
#>    H2O             5.551e+01   1.000e+00     1.744     0.000     0.000     18.07
#> H(0)          1.416e-25
#>    H2              7.079e-26   7.079e-26   -25.150   -25.150     0.000     28.61
#> O(0)          0.000e+00
#>    O2              0.000e+00   0.000e+00   -42.080   -42.080     0.000     30.40
#> 
#> ------------------------------Saturation indices-------------------------------
#> 
#>   Phase               SI** log IAP   log K(298 K,   1 atm)
#> 
#>   H2(g)           -22.05    -25.15   -3.10  H2
#>   H2O(g)           -1.50      0.00    1.50  H2O
#>   O2(g)           -39.19    -42.08   -2.89  O2
#> 
#> **For a gas, SI = log10(fugacity). Fugacity = pressure * phi / 1 atm.
#>   For ideal gases, phi = 1.
#> 
#> ------------------
#> End of simulation.
#> ------------------
#> 
#> ------------------------------------
#> Reading input data for simulation 2.
#> ------------------------------------
#> 
#> ----------------------------------
#> End of Run after 0.551305 Seconds.
#> ----------------------------------
#> Specify at least one selected_output() to retreive results as a data.frame
#> NULL
```

To get the results as a data frame, we need to supply a `selected_output()` to the input file.

``` r
phreeqc(
  solution(pH = 7, temp = 25),
  selected_output(pH = TRUE, temp = TRUE, activities = c("OH-", "H+", "O2"))
)
#> # A tibble: 1 × 12
#>     sim  state  soln dist_x  time  step    pH    pe temp.C.    la_OH.
#> * <int>  <chr> <int>  <dbl> <dbl> <int> <dbl> <dbl>   <dbl>     <dbl>
#> 1     1 i_soln     1     NA    NA    NA     7     4      25 -6.994685
#> # ... with 2 more variables: la_H. <dbl>, la_O2 <dbl>
```

To find the distribution of a few solutions, you can add solutions to the input (you will have to number them).

``` r
phreeqc(
  solution(1, pH = 6, temp = 25),
  solution(2, pH = 7, temp = 25),
  solution(3, pH = 8, temp = 25),
  selected_output(pH = TRUE, temp = TRUE, activities = c("OH-", "H+", "O2"))
)
#> # A tibble: 3 × 12
#>     sim  state  soln dist_x  time  step    pH    pe temp.C.    la_OH.
#> * <int>  <chr> <int>  <dbl> <dbl> <int> <dbl> <dbl>   <dbl>     <dbl>
#> 1     1 i_soln     1     NA    NA    NA     6     4      25 -7.994752
#> 2     1 i_soln     2     NA    NA    NA     7     4      25 -6.994685
#> 3     1 i_soln     3     NA    NA    NA     8     4      25 -5.994752
#> # ... with 2 more variables: la_H. <dbl>, la_O2 <dbl>
```

Databases
---------

Some elements (for example, mercury) aren't included in the base database. There are a number of databases included in the PHREEQC package, that you can choose by specifying the `db` argument of `phreeqc()`. One that includes mercury is the "minteq" database.

``` r
phreeqc(
  solution(1, pH = 7, temp = 25, Hg = 0.1),
  solution(2, pH = 7, temp = 25, Hg = 0.2),
  solution(3, pH = 7, temp = 25, Hg = 0.3),
  selected_output(activities = c("Hg", "Hg2+2", "Hg(OH)2", "Hg(OH)2",
                                 "HgOH+", "Hg(OH)3-")),
  db = "minteq"
)
#> # A tibble: 3 × 13
#>     sim  state  soln dist_x  time  step    pH    pe     la_Hg  la_Hg2.2
#> * <int>  <chr> <int>  <dbl> <dbl> <int> <dbl> <dbl>     <dbl>     <dbl>
#> 1     1 i_soln     1     NA    NA    NA     7     4 -4.000000 -13.86320
#> 2     1 i_soln     2     NA    NA    NA     7     4 -3.698970 -13.26114
#> 3     1 i_soln     3     NA    NA    NA     7     4 -3.522879 -12.90896
#> # ... with 3 more variables: la_Hg.OH.2 <dbl>, la_HgOH. <dbl>,
#> #   la_Hg.OH.3. <dbl>
```

(Note that I called `phreeqc()` with `quiet = FALSE` to first find the species included in `selected_output()`)

Multiple solutions
------------------

The input for `phreeqc()` can accept `list()` objects, so you can use something like `plyr::mlply()` to create a `list` of solutions like the one above to pass to `phreeqc()`. You could use `expand.grid()` to generate a large number of solutions in this way.

``` r
# create data.frame with arguments to solution()
solution_info <- data.frame(
  .number = 1:3,
  pH = 7,
  temp = 25,
  Hg = c(0.1, 0.2, 0.3)
)

# use mlply to turn this into a list()
solution_list <- plyr::mlply(solution_info, solution)

# pass to phreeqc()
phreeqc(
  solution_list,
  selected_output(activities = c("Hg", "Hg2+2", "Hg(OH)2", "Hg(OH)2",
                                 "HgOH+", "Hg(OH)3-")),
  db = "minteq"
)
#> # A tibble: 3 × 13
#>     sim  state  soln dist_x  time  step    pH    pe     la_Hg  la_Hg2.2
#> * <int>  <chr> <int>  <dbl> <dbl> <int> <dbl> <dbl>     <dbl>     <dbl>
#> 1     1 i_soln     1     NA    NA    NA     7     4 -4.000000 -13.86320
#> 2     1 i_soln     2     NA    NA    NA     7     4 -3.698970 -13.26114
#> 3     1 i_soln     3     NA    NA    NA     7     4 -3.522879 -12.90896
#> # ... with 3 more variables: la_Hg.OH.2 <dbl>, la_HgOH. <dbl>,
#> #   la_Hg.OH.3. <dbl>
```
