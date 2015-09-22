function boxplot_wani(x, varargin)

% boxplot_wani(x, varargin)
%
% 'color', matrix 3 x n
% 'dorefline', ref (one number, y = ref)
% 'linewidth', line_etc
% 'boxlinewidth', line_box
% 'reflinewidth', line_ref
% 'axislinewidth', line_axis
% 'fontsize', font_size

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
    l = refline([ref ref]);
    set(l, 'color', [.5 .5 .5], 'linestyle', '--', 'linewidth', line_ref);
end

end

