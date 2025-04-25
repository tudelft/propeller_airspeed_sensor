
input =struct();
input.a = load("FL_144_Omega_R_P.mat");
input.b = load("FL_145_Omega_R_P.mat");
input.c = load("FL_148_Omega_R_P.mat");
input.d = load("FL_254_Omega_R_P.mat");
input.e = load("FL_257_Omega_R_P.mat");
input.f = load("FL_418_Omega_R_P.mat");
input_index = ["a","b","c","d","e","f"];
%%
output = struct();
output.rpm = [];
output.airspeed =[];
output.rpmrate = [];
output.power = [];
output.timestamp = [];
output_index = ["rpm","airspeed","rpmrate","power","timestamp"];
i_list = zeros(10^7,5);
for i = 1:5
    o_pointer = output.(output_index(i));
    o_list = [];
    for j =1:6
        i_pointer = input.(input_index(j)).data.(output_index(i));
        for k = 1:length(i_pointer)
            o_list(end+1) = i_pointer(k);
        end        
    end
    output.(output_index(i)) = o_list;   
end
%%
flight_list = ["144","145","148","254","257","418"];
std_list = zeros(6,1);
coefs_list = zeros(6,5);

for i = 1:6
    data = input.(input_index(i)).data;
    input_data = [ones(size(data.airspeed)) (data.power).^2 data.power data.rpm data.rpmrate ];

    coefs = input_data \ data.airspeed;

    norm_data = data.airspeed - (input_data*coefs);
    std_c =sqrt(sum(norm_data.^2)/(length(data.airspeed)-3));
    %std_c = std(norm_data);
    std_list(i,1) = std_c;
    coefs_list(i,:) = (coefs);
    
    
    
    figure("Name","Flight #"+(flight_list(i)));
    plot(data.timestamp, data.airspeed,".r")
    hold on
    grid on
    plot(data.timestamp, input_data*coefs, ".b")
    xlabel("Time (s)")
    ylabel("Airspeed (m/s)")
    
    %zlabel("RPM")
end
%%

%Combine data in a very inefficent way ^^^^^^^^^ now onto the curve fitting
%vvvvvv

input_data = [transpose(ones(size(output.airspeed))) transpose(output.power) transpose(output.rpm) transpose(output.rpmrate) ];

coefs = input_data \ transpose(output.airspeed);


figure;
%scatter3(output.power, output.airspeed,output.rpm,"red")
%hold on
scatter3(output.power, transpose(input_data*coefs),output.rpm, "blue")