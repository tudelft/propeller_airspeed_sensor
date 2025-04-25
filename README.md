**airspeed_model_fit.m**
- First load a flight log using paparazzi_log_parsing repo.
- Run script. 
This script fits an airspeed model into the data of ONE flight alone. Different data portions can be defined by the user in the tranges matrix.

**bem.jl**
- Script that uses CCBlade.jl tool to generate (rpm,power,airspeed) datapoints from BEM simulation. 
- Stores the result in a mat file to be used by matlab scripts later.
- NOT well-written! It was used to get some first results.
