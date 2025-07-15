# Airspeed estimation for UAVs using only propeller feedback

This repository contains MATLAB scripts to derive and validate an airspeed model for fixed-wing Unmanned Aerial Vehicles (UAVs) using solely propeller power and rotational speed data.  

The model can be used to replace Pitot-tube-based airspeed sensors, or contribute to redundancy in airspeed estimation. It does not require knowledge of the vehicle’s dynamic 
model and is computationally lightweight. It leverages power and rotational speed feedback, which is readily available from modern Electronic Speed Controllers (ESCs), 
thereby enabling seamless integration with existing systems and off-the-shelf components.  

See more about the model and its mathematical formulation in the related article (final version in prep.; see pre-print [here](https://arxiv.org/abs/2507.03456)).  


## Requirements

This code has been developed and tested in Matlab R2024a.


## Installation

- No additional installation is needed for the MATLAB core.  
- (Optional) To run the Blade Element Momentum (BEM) simulations follow installation process of the BEM tool [CCBlade](https://github.com/WISDEM/CCBlade).  


## Structure

``` 
.
├── BEM                      
│   ├── bem.jl               
│   └── custom.dat           
├── LICENSES
│   ├── CC-BY-4.0.txt
│   └── GPL-3.0.txt
├── README.md
├── data
│   ├── Jcrit                
│   │   ├── BEM.mat
│   │   ├── flight.mat
│   │   └── wt.mat
│   ├── eff                  
│   │   └── flight.mat
│   └── input
│       ├── BEM.mat          
│       ├── test.mat         
│       ├── training.mat     
│       └── wt.mat           
├── pdf
│   ├── Cp-J.pdf
│   ├── Cp-J_eta.pdf
│   ├── bem_Va-P-wconst_fit.pdf
│   ├── flight_Va_predict.pdf
│   ├── flight_alpha_J.pdf
│   ├── wt_Va_fit.pdf
│   └── wt_rpm.pdf
├── figs
│   ├── Cp-J.fig
│   ├── Cp-J_eta.fig
│   ├── bem_Va-P-wconst_fit.fig
│   ├── flight_Va_predict.fig
│   ├── flight_aplha_J.fig
│   ├── wt_Va_fit.fig
│   └── wt_rpm.fig
├── models
│   ├── BEM.mat
│   ├── BEM_j.mat
│   ├── WT.mat
│   ├── WT_j.mat
│   ├── flight_AS.mat
│   ├── flight_AS_j.mat
│   ├── flight_GPS.mat
│   └── flight_GPS_j.mat
├── photos
│   ├── photo_cyclone2_fw.png
│   ├── photo_cyclone2_hover.png
│   └── photo_wt_setup.png
└── src
    ├── Jcrit_calc.m
    ├── airspeed_fit_AS.m
    ├── airspeed_fit_BEM.m
    ├── airspeed_fit_GPS.m
    ├── airspeed_fit_WT.m
    ├── airspeed_predict.m
    ├── calib_airspeed.m
    ├── dispModelInfo.m
    ├── efficiency_calc.m
    ├── model_structure_Cp.m
    └── model_structure_Pw.m
```

- `./BEM/` contains the simulation script (`bem.jl`) and the propeller aerodynamic parameters file (`custom.dat`).  
- `./data/eff/` and `./data/Jcrit/` store intermediate output files used by the codes.  
- `./data/input/` contains the following input datasets:
    - `BEM.mat`: BEM simulation data for the experimental setup described in the related article. The simulation input is the propeller parameters, the freestream velocity, which is varied from 0 to 30 $m/s$, and the propeller rotational speed, which is varied from 1000 to 10000 RPM. The simulation output is the propeller power.  
    - `wt.mat`: wind tunnel data from experiments run at the Open Jet Facility of TU Delft.   
    - `training.mat` and `test.mat`: flight training and test datasets respectively. The flight tests were done using a tailsitter UAV Cyclone (see `./photos/`), equipped with a Pitot tube to obtain airspeed measurements, and a GPS module that provides earth-frame velocity data.    
- `./pdf/`, `./figs/`, and `./photos/` contain figures presented in the related article.    
- `./models/` contains the identified intermediate model coefficients. These are created by the **core scripts** found in `./src/`. 
- `./src/` contains the **core scripts** and **helper functions**.
    - **Core scripts**:  
        - `Jcrit_calc.m` calculates the critical operating point.
        - `airspeed_fit_BEM.m` fits the model to the BEM data.
        - `airspeed_fit_AS.m` fits the model to the flight data with airspeed measurements.
        - `airspeed_fit_GPS.m` fits the model to the flight data with GPS velocity measurements.
        - `airspeed_fit_WT.m` fits the model to the wind tunnel data.
        - `airspeed_predict.m` tests all derived models against the unseen data of the test dataset.
        - `efficiency_calc.m` calculates the efficiency of the ESC-motor system.
    - **Helper functions**:  
        - `calib_airspeed.m` estimates constant wind velocity
        - `dispModelInfo.m` displays model coefficients features and error metrics
        - `model_structure_Cp.m` contains the features of the indirect model
        - `model_structure_Pw.m` contains the features of the direct model


## Usage

The **core scripts** found in `./src/`, when run with the default values they generate the plots that can be found in `./pdf/` and `./figs/` directories. Be aware when running the scripts the plots are visualized but not saved to files.  

The **core scripts** can also generate the `.mat` models found in `./models/` (instructions to generate them are in commented text).  

The **core scripts** can also be used independently to fit the model to other datasets following our methodology. The model we derived used the BEM simulation data for the experimental setup described in our article. To use a different propeller re-run the BEM tool [CCBlade](https://github.com/WISDEM/CCBlade) following the instructions from their repository.   

###  Instructions

Before running the scripts make sure to modify the paths accordingly (at the beginning of the scripts). Keep in mind all paths are specified in Unix form by default (e.g. `../data/input/BEM.mat`).  

### Default outputs

When running the scripts with the default values, the scripts generate the following output to the MATLAB command window:  

- `Jcrit_calc.m` (see also `./pdf/Cp-J.pdf`):      
    ```
    J_root1 = -1.23e+00
    J_root2 = 1.97e-01
    ```
- `airspeed_fit_BEM.m` (see also `./pdf/bem_Va-P-wconst_fit.pdf`):      
    ``` 
    ---------------------------------------
    RMSE:  0.72
    nRMSE: 0.024 (range = 29.3 m/s)
    Intercept: 0.00e+00
    w: 2.74e-02
    p^2*w^-5: -9.91e+11
    ---------------------------------------
    RMSE:  0.48
    nRMSE: 0.016 (range = 29.3 m/s)
    Intercept: 8.69e-01
    Cp: -3.60e+00
    Cp^4: -8.18e+03
    ```
- `airspeed_fit_AS.m`:   
    ```
    ---------------------------------------
    RMSE:  0.84
    nRMSE: 0.046 (range = 18.3 m/s)
    Intercept: 0.00e+00
    w: 2.55e-02
    p^2*w^-5: -7.11e+11
    ---------------------------------------
    RMSE:  0.84
    nRMSE: 0.046 (range = 18.3 m/s)
    Intercept: 8.50e-01
    Cp: -3.87e+00
    Cp^4: -4.68e+03
    ```
- `airspeed_fit_GPS`:  
    ```
    ---------------------------------------
    RMSE:  0.94
    nRMSE: 0.038 (range = 24.7 m/s)
    Intercept: 0.00e+00
    w: 2.55e-02
    p^2*w^-5: -6.85e+11
    ---------------------------------------
    RMSE:  1.39
    nRMSE: 0.056 (range = 24.7 m/s)
    Intercept: 1.18e+00
    Cp: -1.30e+01
    Cp^4: 1.03e+04
    ```
- `airspeed_fit_WT.m` (see also `./pdf/wt_Va_fit.pdf` and `./pdf/wt_rpm.pdf`):
    ```
    ---------------------------------------
    RMSE:  0.77
    nRMSE: 0.095 (range = 8.1 m/s)
    Intercept: 0.00e+00
    w: 2.63e-02
    p^2*w^-5: -7.82e+11
    ---------------------------------------
    RMSE:  0.78
    nRMSE: 0.097 (range = 8.1 m/s)
    Intercept: 9.40e-01
    Cp: -5.86e+00
    Cp^4: -2.79e+03
    ```
- `airspeed_predict.m` requires the `.mat` models found in `./models/`. The models can be generated by the previous scripts but instructions are in commented text (see also `./pdf/flight_Va_predict.pdf` and `./pdf/flight_alpha_J.pdf`):
    ```
    ****************** BEM metrics ******************
    ---------------------------------------
    RMSE:  0.88
    nRMSE: 0.085 (range = 10.4 m/s)
    Intercept: 0.00e+00
    w: 2.74e-02
    p^2*w^-5: -9.91e+11
    ---------------------------------------
    RMSE:  0.72
    nRMSE: 0.069 (range = 10.4 m/s)
    Intercept: 8.69e-01
    Cp: -3.60e+00
    Cp^4: -8.18e+03
    ****************** WT metrics ******************
    ---------------------------------------
    RMSE:  0.59
    nRMSE: 0.057 (range = 10.4 m/s)
    Intercept: 0.00e+00
    w: 2.63e-02
    p^2*w^-5: -7.82e+11
    ---------------------------------------
    RMSE:  0.58
    nRMSE: 0.056 (range = 10.4 m/s)
    Intercept: 9.40e-01
    Cp: -5.86e+00
    Cp^4: -2.79e+03
    ****************** AS metrics ******************
    ---------------------------------------
    RMSE:  0.53
    nRMSE: 0.051 (range = 10.4 m/s)
    Intercept: 0.00e+00
    w: 2.55e-02
    p^2*w^-5: -7.11e+11
    ---------------------------------------
    RMSE:  0.53
    nRMSE: 0.051 (range = 10.4 m/s)
    Intercept: 8.50e-01
    Cp: -3.87e+00
    Cp^4: -4.68e+03
    ****************** GPS metrics ******************
    ---------------------------------------
    RMSE:  0.53
    nRMSE: 0.051 (range = 10.4 m/s)
    Intercept: 0.00e+00
    w: 2.55e-02
    p^2*w^-5: -6.85e+11
    ---------------------------------------
    RMSE:  0.97
    nRMSE: 0.094 (range = 10.4 m/s)
    Intercept: 1.18e+00
    Cp: -1.30e+01
    Cp^4: 1.03e+04
    ```
- `efficiency_calc.m` visualizes the plot that can also be found in `Cp-J_eta.pdf`.


## Authors

This software was developed by:  
- *Evangelos Ntouros* ([@ntouev](https://github.com/ntouev), ![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png) [0009-0006-3918-4240](https://orcid.org/0009-0006-3918-4240), E.Ntouros@tudelft.nl, Technische Universiteit Delft   
- *Pavel Kelley* ([@pkelley101](https://github.com/pkelley101)), P.Kelley@student.tudelft.nl, Technische Universiteit Delft 
- *Ewoud Smeur* ([@EwoudSmeur](https://github.com/EwoudSmeur)), ![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/11/orcid_16x16.png) [0000-0002-0060-6526
](https://orcid.org/0000-0002-0060-6526), E.J.J.Smeur@tudelft.nl, Technische Universiteit Delft  


## License

All source code files available in this repository (`./src/`and `./BEM/bem.jl`) are licensed under a GPL-3.0 license (see `./LICENSES/GPL-3.0.txt`). All other files are licensed under a **CC-BY 4.0** license (see `./LICENSES/CC-BY-4.0.txt`).   

Copyright notice:

Technische Universiteit Delft hereby disclaims all copyright interest in the program "Airspeed estimation for UAVs using only propeller feedback" written by the Author(s). 
Henri Werij, Faculty of Aerospace Engineering, Technische Universiteit Delft.

© 2025, E. Ntouros, P. Kelley, E. Smeur


## References  

- [CCBlade](https://github.com/WISDEM/CCBlade)  
- Preprint: [Airspeed estimation for UAVs using only propeller feedback](https://arxiv.org/abs/2507.03456)  


## Cite this repository

**How to cite this repository:** E. Ntouros, P. Kelley, E. Smeur, 2025, Data and Code for Unmanned Aerial Vehicles airspeed estimation using propeller feedback. 4TU.ResearchData. Software. https://doi.org/10.4121/8bcecbac-5478-4595-b629-4378feac6dcb


## Would you like to contribute?

You are welcome to contribute! If you have any comments, feedback, or recommendations, feel free to reach out the authors.  

If you want to contribute directly, you are welcome to open an issue and fork this repository.
