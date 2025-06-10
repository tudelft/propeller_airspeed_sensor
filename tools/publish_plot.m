function publish_plot(name)
    set(gcf, 'Renderer', 'painters');  
    filename = ['/home/ntouev/MATLAB/propeller_airspeed_sensor/figures/eps/', name, '.eps'];
    print('-depsc', filename);
end