**airspeed_model_fit.m**
- First load a flight log using paparazzi_log_parsing repo.
- Run script. 
This script fits an airspeed model into the data of ONE flight alone. Different data portions can be defined by the user in the tranges matrix.

# ToDos:
- Add the slicer (consider a better name eg select data or similar) code into the model fitting script so that the user can define other constraints as well (eg Vair > 6m/s)
- Reduce and merge the flight logs into one dataset. (Use and extend (perhaps fix the name also) of flightlog2mat.m)
- (If needed) develop a script that it going to implement a proper Liner Regression pipeline to the big dataset (ie split and shuffle dataset, cross-validation, ...)
