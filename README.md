# recfintools
**NOTE: This package is in active development. While it is ready for production
use for the 2027 assessment cycle, its contents will be updated and 
improved, and therefore scripts using it may need to be updated**

## Introduction
Recreational data for stock assessments along the US West Coast have 
historically been obtained from a mixture of centralized and decentralized 
sources, using online tools or requests from individuals via email. This process
required extensive coordination, and repeated back and forth between data 
providers and stock assessment teams to understand data fields, processing 
steps, and decision points, and were often repeated across species within
an assessment cycle, and then again for each assessment cycle.

Efforts to standardize recreational data likely started early, but were documented
and shared via github by staff at the Northwest Fisheries Science Center ([NWFSC][]) 
beginning with the 2021 assessment cycle. Early versions of a package to process 
recreational data occurred shortly thereafter, but were not formalized into a working package 
until the 2027 assessment cycle. 

We support the efforts of the
Pacific States Marine Fisheries Commission ([PSMFC][])
to provide a clearing house for recreational sampling data collected over the
years along the US West Coast called the Recreational Fisheries Information Network
([RecFIN][]).
This package is meant to work with this data, and was developed closely with 
[PSMFC][], along with input from Washington, Oregon, and California data providers.
The intended use of this package is specifically for stock assessments conducted 
by the [NWFSC][] and Southwest Fisheries
Science Center ([SWFSC][]) in support of the Pacific Fishery Management Council 
([PFMC][]) process.

## State Sampling Programs
Each state collects data from their recreational fisheries which is then transmitted to RecFIN:

* [CRFS](https://wildlife.ca.gov/Conservation/Marine/CRFS): California Recreational Fisheries Survey
  * [CRFS Sampling Protocol Manual](https://nrm.dfg.ca.gov/FileHandler.ashx?DocumentID=62348&inline)
  * [CRFS General Information](http://wiki.recfin.org/index.php/California_Recreational_Fisheries_Survey)
* ORBS: Oregon Ocean Recreational Boats Survey
  * [ORBS Sampling Design](https://www.dfw.state.or.us/mrp/salmon/docs/ORBS_Design.pdf)
* OSP: Ocean Sampling Program

From 1980-2003, data collection was handled federally by the following program, with
data housed in RecFIN from a legacy instance of the data.

* MRFSS: Marine Recreational Fisheries Statistics Survey (historical)

## Installation

Installing RecFIN requires the use of
[devtools](https://github.com/r-lib/devtools) or
[remotes](https://github.com/r-lib/remotes).
The latter is a dependency of the former so you can just install
[devtools](https://cran.r-project.org/package=devtools)
from [CRAN](https://cran.r-project.org/).

Install the most recent, stable version of the package from
github using

```
remotes::install_github("pfmc-assessments/recfintools")
```

Instructions below assume that the recfintools library has been loaded using

```
library(recfintools)
```

and thus function calls are not preceeded by `recfintools::`.

## Usage

This package can be used to 
* Pull datasets from the RecFIN website and saves them locally
* Reads saved datasets into R for processing
* Filters the raw datasets and provides standardized field names

The data can then be processed and summarized for catch time series, biological
relationships, and compositions for use in assessments, however the current
pacakge does not include functions that automate these processes.

## Data

Reading in recreational fisheries data can be done with the
`pullData()` and `readData()` functions. 

```
pullData(path = file.path("Ling"), species = "LINGCOD")
readData(path = file.path("Ling"), species = "LINGCOD")
```

Generally, not all users will have access to all data reports on RecFIN 
so `pullData()` should be called by the package maintainer or recreational
point of contact. To request data from this package obtained from `pullData()`, 
please create a new "Data request" issue within the github repository. 
Once data are provided, `readData()` can be used to read them into R for
processing. 

### Data provided

The current list of data reports within RecFIN that are provided by
`pullData()` and read by `readData()` include the following
* Recent years of catch data - CTE501 as dataframe `catch_recent`
  * For Washington, this includes years: 
  * For Oregon, this includes years:
  * For California, this includes years:
* MRFSS years of catch data - CTE008 as dataframe `catch_mrfss`
  * Currently, Washington does not use this data
  * For Oregon, this includes years:
  * For California, this includes year: 
* Historical catch reconstructions - as list `catch_hist`
  * For Washington, this is CTE503 and includes years:
  * For Oregon, this is CTE507 and includes years:
  * For California, this is CTE508 and includes years:
* Recent years of length bio data - SD501 as dataframe `bds_recent_len`
  * For Washington, this includes years:
  * For Oregon, this includes years:
  * For California, this includes years:
* Recent years of age bio data - SD506 as dataframe `bds_recent_age`
  * For Washington, this includes years:
  * For Oregon, this includes years:
* MRFSS years of bio data - SD517 (type 3) as dataframe `bds_mrfss`
  * Currently, Washington does not use this data
  * Currently, Oregon does not use this data
  * For California, this includes years:

## Cleaning data

The `clean_catch()` and `clean_bds()` functions automatically clean the 
data and work towards providing consistent column names such as year 
instead of YEAR or YR. These functions need to be called for each data set, and
automatically determine the necessary fields to filter on.
Consistency is key because there are so many providers of data when
it comes to recreational fisheries and all use a variety of column names.

```
#For cleaning catch data for all datasets
clean_catch()

#For cleaning biological data for each dataset
```

### State `getState()`

### Year `getYear()`

### Mode `getMode()`

### Area `getState()`

### Lengths `getLengths()`

### Ages `getAges()`

### Columns `cleanColumns()`


## Processing data

There are many decision points for processing recreational data. The package
currently includes only a few functions that provide default choices for 
processing data. It is expected that as development proceeds, the number of 
processing functions will expand. 

### Historical weights `getWeightHist()`


## Disclaimer

"The United States Department of Commerce (DOC) GitHub project code is
provided on an 'as is' basis and the user assumes responsibility for its
use. DOC has relinquished control of the information and no longer has
responsibility to protect the integrity, confidentiality, or
availability of the information. Any claims against the Department of
Commerce stemming from the use of its GitHub project will be governed by
all applicable Federal law. Any reference to specific commercial
products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by the Department of Commerce.
The Department of Commerce seal and logo, or the seal and logo of a DOC
bureau, shall not be used in any manner to imply endorsement of any
commercial product or activity by DOC or the United States Government."

`recfintools` was developed by US federal government employees as part of their 
official duties. As such, it is not subject to copyright protection and is 
considered public domain (see 17 USC Section 105). Public domain software can 
be used by anyone for any purpose, and cannot be released under a copyright license.

[PSMFC]: https://www.psmfc.org/
[RecFIN]: https://www.recfin.org/
[OSP]: https://www.noaa.gov/information-technology/washington-department-of-fish-and-wildlife-ocean-sampling-program-documentation-id343
[ORBS]: https://www.dfw.state.or.us/mrp/salmon/docs/ORBS_Design.pdf
[CRFS]: https://wildlife.ca.gov/Conservation/Marine/CRFS
[NWFSC]: https://www.fisheries.noaa.gov/about/northwest-fisheries-science-center
[SWFSC]: https://www.fisheries.noaa.gov/about/southwest-fisheries-science-center
[PFMC]: https://www.pcouncil.org/