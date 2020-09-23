# Package "helptabel"

<!-- badges: start -->
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/KeesVanImmerzeel/helptabel?branch=master&svg=true)](https://ci.appveyor.com/project/KeesVanImmerzeel/helptabel)
[![Travis Build Status](https://travis-ci.org/KeesVanImmerzeel/helptabel.svg?branch=master)](https://travis-ci.org/KeesVanImmerzeel/helptabel)
<!-- badges: end -->

The package "helptabel" can be used to estimate the reduction in crop production caused by waterlogging and drought. The groundwater regime is characterized by the mean (average) lowest and highest groundwaterlevel ("GHG and "GLG"). 
70 different soil types are distinguished and two types of land use (grassland and arable land).

![](https://user-images.githubusercontent.com/16401251/90639879-9c30b700-e22f-11ea-9dbc-8f11e6a3e82a.png)

The following approximate analytical formulas are used to calculate the reduction in crop production.

![](https://user-images.githubusercontent.com/16401251/93208128-5991ca00-f75c-11ea-96c5-563465881334.JPG)

For the calculation of the reduction in crop production caused by waterlogging ("Natschade"), the blue parameters A-D are optimized against the tabulated values in the "HELP-tabel (1987, see below"). In this relation the parameter E equals the smallest tabulated reduction caused by waterlogging (for every soil/crop combination).

For the calculation of the reduction in crop production caused by drought ("Droogteschade"), the red parameters A-E are optimized against the tabulated values in the "HELP-tabel (1987).

The "data-raw" folder contains the "original" HELP tables, as well as the optimization code.

Differences between the values calculated with the above formulas and the tabulated values are typically small. The frequency distributions of the root-mean-square error values illustrate this, as well as the comparison between tabulated and calculated reduction values for the soil HELP=15 (landuse = grassland).

![](https://user-images.githubusercontent.com/16401251/93210669-4aad1680-f760-11ea-8331-38521dec6d35.png)

![](https://user-images.githubusercontent.com/16401251/93211202-30c00380-f761-11ea-9fa9-7ad69d0bf780.png)

![](https://user-images.githubusercontent.com/16401251/93357392-88816c00-f840-11ea-935d-cdd3e431fcc8.png)


## Installation

You can install the released version of menyanthes from with:

`install_github("KeesVanImmerzeel/helptabel")`

Then load the package with:

`library("helptabel")` 

## Functions in this package
- `ht_reduction()`: Calculate reduction in crop production caused by waterlogging and drought.
- `ht_soilnr_to_HELPnr()`: Get HELP number by specifying a soil number (1010, ..., 22020).
- `ht_bofek_to_HELPnr()`: Get HELP number by specifying a bofek number.
- `ht_soil_unit_to_HELPnr()`: Get HELP number by specifying a soil unit ("soil_unit").
- `ht_soil_units()`: Valid soil units.
- `ht_bofek_numbers()`: Valid bofek numbers.
- `ht_HELPnr_to_HELPcode`: Get HELP (soil) code by specifying HELP number.
- `ht_tab_calc_values()`: Tabulated and calculated reductions in crop production.
- `ht_tab_calc_values()`: Plot of tabulated and calculated reductions in crop production.

## Get help

To get help on the functions in this package type a question mark before the function name, like `?ht_reduction()`

## Remarks

In the HELP-table (1987) the HELP numbers 71 and 72 where not included. Therefore, calculation of the reduction in crop production is not possible for the following bofek numbers: 301, 305, 306, 314, 315 and 319 (soil units Hd21, Hn21g, Hn21t, pZg23t, Hn23x, cHn23x).

# References

*"De invloed van de waterhuishouding op de landbouwkundige produktie".
Rapport van de werkgroep HELP-tabel, Mededelingen Landinrichtingsdienst 176 (1987).*

