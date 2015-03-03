function bin2dplot(X, varargin)




subjn = numel(X);
nbins = 4;
dorefline = 1;

clear Xbins Ybins;

for i = 1:subjn
%i=1;

% get binidx
[~, sort_idx] = sort(X{i});
binidx = zeros(numel(X{i}),1);
if numel(unique(X{i})) == nbins
    u = unique(X{i});
    for j = 1:numel(u)
        binidx(X{i} == u(j)) = j;
    end
    
    for j = 1:nbins
        Xbins(i,j) = mean(X{i}(binidx==j));
        Ybins(i,j) = mean(Y{i}(binidx==j));
    end
    
else
    algo = {'ceil', 'floor'};
    for j = 1:(nbins-1)
        algon = double(rand>.5)+1;
        eval(['tri_n = ' algo{algon} '(numel(X{i})./nbins);']);
        binidx(find(binidx==0, 1, 'first'):(find(binidx==0, 1, 'first')+tri_n-1)) = ...
            repmat(j, tri_n, 1);
    end
    binidx(binidx==0) = nbins;
    for j = 1:nbins
        Xbins(i,j) = mean(X{i}(sort_idx(binidx==j)));
        Ybins(i,j) = mean(Y{i}(sort_idx(binidx==j)));
    end
end

end

x = mean(Xbins);
xe = ste(Xbins);

y = mean(Ybins);
ye = ste(Ybins);

create_figure('2d_plot');
    
% colors = [0    0.3333    0.6627]; 
% colors_ref = [0.3333    0.6588    1.0000];

colors = [0.8353    0.2431    0.3098];
colors_ref = [0.9569    0.4275    0.2627];

clear h;

scatter(x,y, 60, colors, 'filled');

if dorefline
    refh = refline;
    set(refh, 'Color', colors_ref, 'linewidth', 1, 'linestyle', '--');
end
% 
% if doindiv
%     for i = 1:subjn
%         scatter(Xbins(i,:), Ybins(i,:));
%     end
% end

xmin = min(x-xe) - range(x)*.05;
xmax = max(x+xe) + range(x)*.05;
ymin = min(y-ye) - range(y)*.05;
ymax = max(y+ye) + range(y)*.05;

xmin2 = min(x-xe) - range(x)*.1;
xmax2 = max(x+xe) + range(x)*.1;
ymin2 = min(y-ye) - range(y)*.1;
ymax2 = max(y+ye) + range(y)*.1;


for i = 1:numel(x)
    h{i} = ploterr(x(i),y(i),xe(i),ye(i));
    set(h{i}(1), 'marker', '.', 'color', colors, 'markersize', 1);
    set(h{i}(2), 'color', colors, 'linewidth', 2);
    set(h{i}(3), 'color', colors, 'linewidth', 2);
    xdata = get(h{i}(2), 'xData');
    xdata(4:5) = xdata(1:2); xdata(7:8) = xdata(1:2);
    set(h{i}(2), 'xdata', xdata);
    
    ydata = get(h{i}(3), 'yData');
    ydata(4:5) = ydata(1:2); ydata(7:8) = ydata(1:2);
    set(h{i}(3), 'ydata', ydata);
    hold on;
end

xdata = get(refh, 'xdata');
ydata = get(refh, 'ydata');
slope = (ydata(2)-ydata(1))./(xdata(2) - xdata(1));
intercept = ydata(2) - xdata(2).*slope;

set(refh, 'xdata', [xmin xmax], 'ydata', [xmin*slope+intercept xmax*slope+intercept])
set(gca, 'xlim', [xmin2 xmax2], 'ylim', [ymin2 ymax2], 'linewidth', 1.2, 'fontsize', 18);
