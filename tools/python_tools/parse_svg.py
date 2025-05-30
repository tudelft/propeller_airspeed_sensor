from svgdigitizer.svg import SVG
from svgdigitizer.svgplot import SVGPlot
from svgdigitizer.svgfigure import SVGFigure
from svgdigitizer.electrochemistry.cv import CV


svg_airfoil = SVG(open('tools/python_tools/Prop_airfoil A.1_(2).svg', 'rb'))
#svg_airfoil.df
plot = SVGPlot(svg_airfoil)
plot.df.to_dict('airfoil.csv',index=False)
#svg_airfoil.cv()
pass