function [h_line, h_patch] = wani_plot_shading(xaxis, mean, error, varargin)

% usage: [h_line, h_patch] = wani_plot_shading(xaxis, mean, error, varargin)
%
% input: xaxis, mean, error
%
% optional_inputs: 'color', 'color_shade', 'alpha'

color = [0.3333, 0.6588, 1.0000]; % default color

use_color_shade = false;
do_alpha = false;
alpha = 1;
for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'color', 'color_line'} 
                color = varargin{i+1};
            case {'color_shade'} 
                use_color_shade = true;
                color2 = varargin{i+1};
            case {'alpha'} 
                do_alpha = true;
                alpha = varargin{i+1}; % degree-corrected SBM
        end
    end
end

upperline = mean + error;
lowerline = mean - error;
xdata = [xaxis fliplr(xaxis) xaxis(1)];
ydata = [upperline fliplr(lowerline) upperline(1)];

if ~use_color_shade && ~do_alpha
    color2 = color +.3;
    color2(color2 > 1) = 1;
elseif ~use_color_shade && do_alpha
    color2 = color;
end

h_patch = patch(xdata,ydata,'y','linestyle', 'none', 'FaceColor', color2, 'faceAlpha', alpha);

hold on;

% h_line = plot(xaxis, mean, 'o-', 'linewidth', 2, 'color', color, 'MarkerSize', 7, 'MarkerFaceColor', color);
h_line = plot(xaxis, mean, '-', 'linewidth', 2, 'color', color);

end