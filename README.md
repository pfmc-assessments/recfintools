# recfintools
**NOTE: this package is in active development and not yet intended for production use**

Working with recreational data for the US West Coast from
Recreational Fisheries Information Network
([RecFIN][]).

We support the efforts of the
Pacific States Marine Fisheries Commission ([PSMFC][])
to provide a clearing house for recreational sampling data collected over the
years along the US West Coast.
This package is meant to work with this data.

## Glossary

* MRFSS: Marine Recreational Fisheries Statistics Survey
* [PSMFC][]: Pacific States Marine Fisheries Commission
* [RecFIN][]: Recreational Fisheries Information Network

## State Sampling Programs
Each state collects data from their recreational fisheries which is then transmitted to RecFIN:

* [CRFS](https://wildlife.ca.gov/Conservation/Marine/CRFS): California Recreational Fisheries Survey
  * [CRFS Sampling Protocol Manual](https://nrm.dfg.ca.gov/FileHandler.ashx?DocumentID=62348&inline)
  * [CRFS General Information](http://wiki.recfin.org/index.php/California_Recreational_Fisheries_Survey)
* ORBS: Oregon Ocean Recreational Boats Survey
  * [ORBS Sampling Design](https://www.dfw.state.or.us/mrp/salmon/docs/ORBS_Design.pdf)

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

## Usage

Reading in recreational fisheries data can be done with the
`RecFIN::read_*()` functions.
The `read_*` functions automatically clean the data and work towards
providing consistent column names such as Year instead of YEAR.
Consistency is key because there are so many providers of data when
it comes to recreational fisheries. Users can also clean their data
themselves using the `RecFIN::clean_*()` functions.

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

RecFIN was developed by US federal government employees as part of their official duties.
As such, it is not subject to copyright protection and is considered public domain (see 17 USC Section 105).
Public domain software can be used by anyone for any purpose, and cannot be released under a copyright license.

[PSMFC]: https://www.psmfc.org/
[RecFIN]: https://www.recfin.org/
