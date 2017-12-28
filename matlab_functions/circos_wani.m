function out = circos_wani(A, varargin)

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
[row,col,v] = find(A);
norm_factor = max(abs(v)); % the simplest norm factor = maximum

laterality = false;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'laterality'}
                laterality = true;
                lat_index = varargin{i+1};
            case {'norm_factor'}
                norm_factor = varargin{i+1}; % you can use your customized normalizing factor
            case {'group_color'}
                gcols = varargin{i+1};
        end
    end
end


if laterality 
    t1 = linspace(-pi/2, pi/2,sum(lat_index>0)+2)'; % theta for each node
    t1([1 sum(lat_index>0)+2]) = [];
    t2 = linspace(pi/2, -pi/2,sum(lat_index<0)+2)'; % theta for each node
    t2([1 sum(lat_index<0)+2]) = [];
else
    t = linspace(-pi, pi,length(adjacencyMatrix) + 1)'; % theta for each node
end

for i = 1:length(adjacencyMatrix)
    scatter(cos(t(i)),sin(t(i)));
    hold on;
end

% Calculate line widths based on values of s (stored in v).
minLineWidth  = 0.5;
lineWidthCoef = 5;
lineWidth = v./norm_factor;

if sum(lineWidth) == numel(lineWidth) % all lines are the same width.
    lineWidth = repmat(minLineWidth,numel(lineWidth),1);
else % lines of variable width.
    lineWidth = lineWidthCoef*lineWidth + minLineWidth; % plus and minus
end

for i = 1:length(v)
    if row(i) ~= col(i)
        if abs(row(i) - col(i)) - length(adjacencyMatrix)/2 == 0
            % points are diametric, so draw a straight line
            u = [cos(t(row(i)));sin(t(row(i)))];
            v = [cos(t(col(i)));sin(t(col(i)))];
            %this.Node(row(i)).Connection(end+1) = 
            line(...
                [u(1);v(1)],...
                [u(2);v(2)],...
                'LineWidth', lineWidth(i),...
                'PickableParts','none');
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
            line(...
                r*cos(theta)+x0,...
                r*sin(theta)+y0,...
                'LineWidth', lineWidth(i),...
                'PickableParts','none');
        end
    end
end