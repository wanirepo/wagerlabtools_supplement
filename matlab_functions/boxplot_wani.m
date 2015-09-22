function boxplot_wani(x, varargin)

% Draw a box plot with some additional useful features. (work in the
% matlab version up to 2014a). 
%
% Usage:
% -------------------------------------------------------------------------
% boxplot_wani(x, varargin)
%
% Inputs:
% -------------------------------------------------------------------------
% x    A data matrix. If there are multiple groups, you can insert a column
%      of NaNs between two groups. Also if you have multiple columns that
%      have different number of data points (e.g., one has 50, and the 
%      other has 38), you can just fill in NaNs (e.g., 12 NaNs). 
% 
% -------------------------------------------------------------------------
% Optional inputs: Enter keyword followed by variable with values
%
% ['color', 'colors', cols]     cols: matrix of 3 x n (n columns)
% ['boxlinewidth', line_box]    scalar, linewidth for the box
% ['linewidth', line_etc]       scalar, linewidth for all the lines other 
%                               than box
% ['axislinewidth', line_axis]  scalar, linewidth for the axis
% ['fontsize', font_size]       scalar, font size for the axis
% ['dorefline', ref]            scalar, draw a reference line at y = ref
% ['reflinewidth', line_ref]    scalar, linewidth for the refline
%
% example:
% 
% x = rand(100,5);
% col =  [0.3765    0.2902    0.4824
%     0.2157    0.3765    0.5725
%     0.4667    0.5765    0.2353
%     0.8941    0.4235    0.0392
%     0.5843    0.2157    0.2078];
% 
% boxplot_wani(x, 'color', col, 'refline', 0.5);
%
% savename = 'example_box.pdf';
% 
% try
%     pagesetup(gcf);
%     saveas(gcf, savename);
% catch
%     pagesetup(gcf);
%     saveas(gcf, savename);
% end

coln = size(x,2);
colud = repmat([0 0 0], coln, 1); % default color = black
colud2 = repmat([.9 .9 .9], coln, 1); % default back color = black

dorefline = 0;
line_etc = 3;
line_box = 4;
line_ref = 1.5;
line_axis = 2;
font_size = 25;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'color', 'colors'}
                colud = flipud(varargin{i+1}); 
                colud2 = colud + .25; 
                colud2(colud2>1)=1;
            case {'refline'}
                dorefline = 1;
                ref = varargin{i+1};
            case {'linewidth'}
                line_etc = varargin{i+1};
            case {'boxlinewidth'}
                line_box  = varargin{i+1};
            case {'reflinewidth'}
                line_ref  = varargin{i+1};
            case {'axislinewidth'}
                line_axis  = varargin{i+1};
            case {'fontsize'}
                font_size = varargin{i+1};
        end
    end
end

% put NaNs between groups if there are many groups of data

create_figure('box_plot');
boxplot(x); % using boxplot default
set(gca, 'fontSize', font_size, 'lineWidth', line_axis, 'tickLength', [0.01 0.01]);
set(gcf, 'position', [50   159   105*coln   291]);

h = get(get(gca, 'children'), 'children');

k=0;
for i = (3*coln+1):length(h)
    set(h(i), 'lineWidth', line_etc)
    if isequal(get(h(i), 'color'), [0 0 1])
        k = k+1;
        patch(get(h(i), 'xdata'), get(h(i), 'ydata'), colud2(k,:), 'EdgeColor', colud(k,:));
        set(h(i), 'color', colud(k,:), 'linewidth', line_box, 'linestyle', '-');
    end
end

for i = 1:(3*coln)
    set(h(i), 'lineWidth', line_etc)
    if i > coln && i <= (coln*2)
        set(h(i), 'marker', '.', 'markerSize', 15); % marker: circle
    end
    
    if isequal(get(h(i), 'color'), [1 0 0])
        set(h(i), 'color', [0.7608 0.3020 0], 'linewidth', line_etc, 'linestyle', '-'); % median line
    end
end

hold on;
boxplot(x); % because of the patch, do this again
set(gca, 'fontSize', font_size, 'lineWidth', line_axis, 'tickLength', [0.01 0.01]);
h = get(get(gca, 'children'), 'children');
h = h{1};
k=0;
for i = (3*coln+1):length(h)
    set(h(i), 'lineWidth', line_etc)
    if isequal(get(h(i), 'color'), [0 0 1])
        k = k+1;
        set(h(i), 'color', colud(k,:), 'linewidth', line_box, 'linestyle', '-');
    end
end

for i = 1:(3*coln)
    set(h(i), 'lineWidth', line_etc)
    if i > coln && i <= (coln*2)
        set(h(i), 'marker', '.', 'markerSize', 15)
    end
    
    if isequal(get(h(i), 'color'), [1 0 0])
        set(h(i), 'color', [0.7608    0.3020         0], 'linewidth', line_etc, 'linestyle', '-');
    end
end

if dorefline
    l = refline([0 ref]);
    set(l, 'color', [.5 .5 .5], 'linestyle', '--', 'linewidth', line_ref);
end

end

