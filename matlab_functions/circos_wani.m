    function circos_wani(A, varargin)

% This function draws circos plot.
%
% :Usage:
% ::
%
%    out = circos_wani(a, varargin)
%
% :Features:
%
%  - can draw ...
%
% :Inputs:
%
%   **a:**
%        adjacency matrix (weighted or not)
%

% Find non-zero values of s and their indices

laterality = false;
pos_edge_color = [215,25,28]./255;
neg_edge_color = [43,131,186]./255;
weighted_node_size = false;
do_node_alpha = false;
draw_node_top  = false;
draw_circle = false;
draw_node_edge = false;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'laterality'}
                laterality = true;
                lat_index = varargin{i+1};
            case {'group'}
                group = varargin{i+1};
                g_order = 1:numel(group); % default
            case {'group_color'}
                gcols = varargin{i+1};
                gcols_edge = gcols - .2;
                gcols_edge(gcols_edge<0) = 0;
            case {'weighted_node_size'}
                weighted_node_size = true;
            case {'node_alpha'}
                do_node_alpha = true;
                node_alpha = varargin{i+1};
            case {'draw_node_top'}
                draw_node_top = true;
            case {'draw_circle'}
                draw_circle = true;
            case {'draw_node_edge'}
                draw_node_edge = true;
        end
    end
end

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'group_order'}
                g_order = varargin{i+1};
        end
    end
end

if laterality
    [lat_val, lat_sort] = sort(lat_index, 'descend');
    
    group = group(lat_sort);
    A = A(lat_sort, lat_sort);
    lat_index = lat_index(lat_sort);
    
    g_idx_total = [];
    for k = [1 -1]
        temp = group .* double(lat_val==k);
        for i = 1:numel(g_order)
            g_idx = find(temp==g_order(i));
            g_idx_total = [g_idx_total; g_idx];
        end
    end
else
     g_idx_total = [];
    for i = 1:numel(g_order)
        temp = group;
        g_idx = find(temp==g_order(i));
        g_idx_total = [g_idx_total; g_idx];
    end
end

group = group(g_idx_total);
A = A(g_idx_total, g_idx_total);
if laterality, lat_index = lat_index(g_idx_total); end

[row,col,w] = find(A);
sumA = sum(A);
norm_factor = max(abs(w)); % the simplest norm factor = maximum
% norm_factor2 = min(abs(sumA(sumA~=0)));

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'norm_factor'}
                norm_factor = varargin{i+1}; % you can use your customized normalizing factor
        end
    end
end

if laterality 
    t1 = linspace(-pi/2, pi/2, sum(lat_index>0)+4)'; % theta for each node
    t1([1 2 sum(lat_index>0)+3 sum(lat_index>0)+4]) = [];
    t2 = linspace(-pi/2, pi/2, sum(lat_index<0)+4)'+pi; % theta for each node
    t2([1 2 sum(lat_index<0)+3 sum(lat_index<0)+4]) = [];
    t = [flipud(t1); t2];
else
    t = linspace(-pi, pi,length(A) + 1)'; % theta for each node
end

if draw_circle
    tt = linspace(-pi, pi,1000)'; % theta for each node
    plot(cos(tt), sin(tt), 'color', [.8 .8 .8], 'linewidth', 8); 
    hold on;
end

for i = 1:length(A) %find(sumA == 0) 
    % scatter(cos(t(i)),sin(t(i)), 50, gcols(group(i),:),  'filled', 'MarkerFaceAlpha', .5);
    scatter(cos(t(i)),sin(t(i)), 150, gcols(group(i),:),  'filled');
    hold on;
end

for i = find(sumA ~= 0)
    % norm_factor3 = (abs(sumA(i))-norm_factor2)./(90*(norm_factor-norm_factor2))+1;
    
    if weighted_node_size
        % scatter(cos(t(i)).*norm_factor3,sin(t(i)).*norm_factor3, 150*abs(sumA(i))./norm_factor, gcols(group(i),:), 'filled');
        if draw_node_edge
            scatter(cos(t(i)), sin(t(i)), 150*abs(sumA(i))./norm_factor, gcols(group(i),:), 'filled', 'MarkerEdgeColor', gcols_edge(group(i),:), 'LineWidth', 3);
        else
            scatter(cos(t(i)), sin(t(i)), 150*abs(sumA(i))./norm_factor, gcols(group(i),:), 'filled');
        end
    else
        if draw_node_edge
            scatter(cos(t(i)), sin(t(i)), 150, gcols(group(i),:), 'filled', 'MarkerEdgeColor', gcols_edge(group(i),:), 'LineWidth', 3 );
        else
            scatter(cos(t(i)), sin(t(i)), 150, gcols(group(i),:), 'filled');
        end
    end
    
    if do_node_alpha
        scatter(cos(t(i)),sin(t(i)), 300, 'w', ...gcols(group(i),:), ...
            'filled', 'MarkerFaceAlpha', node_alpha);
    end
    hold on;
end

% Calculate line widths based on values of s (stored in v).
minLineWidth  = 0.5;
lineWidthCoef = 5;
lineWidth = w./norm_factor;

if sum(lineWidth) == numel(lineWidth) % all lines are the same width.
    lineWidth = repmat(minLineWidth,numel(lineWidth),1);
else % lines of variable width.
    lineWidth = lineWidthCoef*lineWidth + minLineWidth; % plus and minus
end

for i = 1:length(w)
    if row(i) ~= col(i)
        if abs(row(i) - col(i)) - length(A)/2 == 0
            % points are diametric, so draw a straight line
            u = [cos(t(row(i)));sin(t(row(i)))];
            v = [cos(t(col(i)));sin(t(col(i)))];
            %this.Node(row(i)).Connection(end+1) = 
            if lineWidth(i) > 0
                line(...
                    [u(1);v(1)],...
                    [u(2);v(2)],...
                    'LineWidth', lineWidth(i),...
                    'PickableParts','none', 'color', [pos_edge_color .5]);
            else
                line(...
                    [u(1);v(1)],...
                    [u(2);v(2)],...
                    'LineWidth', -lineWidth(i),...
                    'PickableParts','none', 'color', [neg_edge_color .5]);
            end
        else % points are not diametric, so draw an arc
            u  = [cos(t(row(i)));sin(t(row(i)))];
            v  = [cos(t(col(i)));sin(t(col(i)))];
            x0 = -(u(2)-v(2))/(u(1)*v(2)-u(2)*v(1));
            y0 =  (u(1)-v(1))/(u(1)*v(2)-u(2)*v(1));
            r  = sqrt(x0^2 + y0^2 - 1);
            thetaLim(1) = atan2(u(2)-y0,u(1)-x0);
            thetaLim(2) = atan2(v(2)-y0,v(1)-x0);
            
            if u(1) >= 0 && v(1) >= 0
                % ensure the arc is within the unit disk
                theta = [linspace(max(thetaLim),pi,50),...
                    linspace(-pi,min(thetaLim),50)].';
            else
                theta = linspace(thetaLim(1),thetaLim(2)).';
            end
            
            %this.Node(row(i)).Connection(end+1) = 
            if lineWidth(i) > 0
                line(...
                    r*cos(theta)+x0,...
                    r*sin(theta)+y0,...
                    'LineWidth', lineWidth(i),...
                    'PickableParts','none', 'color', [pos_edge_color .5]);
            else
                line(...
                    r*cos(theta)+x0,...
                    r*sin(theta)+y0,...
                    'LineWidth', -lineWidth(i),...
                    'PickableParts','none', 'color', [neg_edge_color .5]);
            end
        end
    end
end

if draw_node_top
    
    for i = find(sumA ~= 0)
        % norm_factor3 = (abs(sumA(i))-norm_factor2)./(90*(norm_factor-norm_factor2))+1;
        
        if weighted_node_size
            % scatter(cos(t(i)).*norm_factor3,sin(t(i)).*norm_factor3, 150*abs(sumA(i))./norm_factor, gcols(group(i),:), 'filled');
            if draw_node_edge
                scatter(cos(t(i)), sin(t(i)), 150*abs(sumA(i))./norm_factor, gcols(group(i),:), 'filled', 'MarkerEdgeColor', gcols_edge(group(i),:), 'LineWidth', 3);
            else
                scatter(cos(t(i)), sin(t(i)), 150*abs(sumA(i))./norm_factor, gcols(group(i),:), 'filled');
            end
        else
            if draw_node_edge
                scatter(cos(t(i)), sin(t(i)), 150, gcols(group(i),:), 'filled', 'MarkerEdgeColor', gcols_edge(group(i),:), 'LineWidth', 3);
            else
                scatter(cos(t(i)), sin(t(i)), 150, gcols(group(i),:), 'filled');
            end
        end
        
        if do_node_alpha
            scatter(cos(t(i)),sin(t(i)), 300, 'w', ...gcols(group(i),:), ...
                'filled', 'MarkerFaceAlpha', node_alpha);
        end
        hold on;
    end
    
    
end

set(gcf, 'color', 'w', 'position', [1   444   562   511]);
axis off

end