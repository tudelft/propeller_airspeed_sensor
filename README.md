# Airspeed estimation for UAVs using only propeller feedback

This is the code used in the paper [Airspeed estimation for UAVs using only propeller feedback](https://arxiv.org/abs/2507.03456) to derive and validate an airspeed model for UAVs from propeller power and rotational speed data.

## Requirements
This code has been developed and tested in Matlab R2024a.

## Installation
- No additional installation is needed for the core MATLAB core.
- (Optional) To run the BEM simulations follow installation process of the BEM tool [CCBlade](https://github.com/WISDEM/CCBlade).


## Structure
``` shell
├── BEM
├── data
├── eps
├── figs
├── LICENSE
├── models
├── photos
├── README.md
└── src
```

- `BEM/` contains the simulation script and the propeller aerodynamic parameters file.
- `data/` contains the BEM, wind tunnel, and flight datasets (training and test) and subdirectories `data/eff` and `data/Jcrit` store intermediate output files used by the code.
- `eps/`, `figs/`, and `photos/` contain figures used in the paper.
- `models/` stores the identified intermediate model coefficients.
- `src/` contains the core scripts and helper functions.


## Usage

### BEM
File `data/BEM.mat` already contains the BEM simulation data for the experimental setup described in our paper. To use different propeller rerun the BEM tool following the instructions from the original repository.

### src
- `airspeed_fit_BEM.m` fits the model to the BEM data.
- `airspeed_fit_WT.m` fits the model to the wind tunnel data.
- `airspeed_fit_AS.m` fits the model to the flight data with airspeed measurements.
- `airspeed_fit_GPS.m` fits the model to the flight data with GPS velocity measurements.
- `airspeed_predict.m` tests all derived models against the unseen data of the test dataset.
- `efficiency_calc.m` calculates the efficiency of the ESC-motor system.
- `Jcrit_calc.m` calculates the critical operating point.

## Authors
This software was developed by:
- *Evangelos Ntouros* ![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png) [0009-0006-3918-4240](https://orcid.org/0009-0006-3918-4240),
- *Pavel Kelley*, and
- *Ewoud Smeur* ![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png) [0000-0002-0060-6526
](https://orcid.org/0000-0002-0060-6526),

in Technische Universiteit Delft.

## References
- [CCBlade](https://github.com/WISDEM/CCBlade).

## Cite this repository
