function h = vis_corr(r, varargin)

% Draw a nice correlation figure
%
% Usage:
% -------------------------------------------------------------------------
% function h = vis_corr(r, varargin)
%
% Inputs:
% -------------------------------------------------------------------------
% r     square matrix (doesn't need to be a correlation)
%
% Optional inputs: Enter keyword followed by variable with values
% 'colormap'      colormap (default uses a colormap from colorbrewer2)
% 'clim'          two numbers [CLOW CHIGH] for color scaling of imagesc 
%                 (see >> help imagesc)
% 'colorbar'      show colorbar
%
% Outputs:
% -------------------------------------------------------------------------
% h              graphic handles 
%
% Examples: 
% -------------------------------------------------------------------------
% % data
% r = rand(30,30);
% h = vis_corr(r, 'clim', [0 1])
%
% savename = 'example_corr.png';
% 
% try
%     pagesetup(gcf);
%     saveas(gcf, savename);
% catch
%     pagesetup(gcf);
%     saveas(gcf, savename);   
% end
%
% -------------------------------------------------------------------------
% Copyright (C) 2015  Wani Woo

% Programmers' notes:

col_map = [0.3686    0.3098    0.6353
    0.1961    0.5333    0.7412
    0.4000    0.7608    0.6471
    0.6706    0.8667    0.6431
    0.9020    0.9608    0.5961
    1.0000    1.0000    0.7490
    0.9961    0.8784    0.5451
    0.9922    0.6824    0.3804
    0.9569    0.4275    0.2627
    0.8353    0.2431    0.3098
    0.6196    0.0039    0.2588];

m = max(max(max(r)), abs(min(min(r))));
clim = [-m m];
docolorbar = 0;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'colormap', 'colors'}
                col_map = varargin{i+1};
            case {'clim'}
                clim = varargin{i+1};
            case {'colorbar'}
                docolorbar = 1;
        end
    end
end

if size(r,1) == size(r,2)
    size_r = size(r,1);
else
    error('r should be a square matrix.');
end
size_max = size_r+.5;

% close all;
h = figure;

% global max
imagesc(r, [clim(1) clim(2)]);
if docolorbar
    colorbar;
    set(gcf, 'color', 'w', 'position', [360   283   527   415]);
else
    set(gcf, 'color', 'w', 'position', [360   283   451   415]);
end
axis off;
colormap(col_map);

% imagesc

set(gca, 'xlim', [-.5 size_r+1.5], 'ylim', [-.5 size_r+1.5])
hold on; 

for i = 1.5:1:(size_r-.5)
    lw = .5; 
    cols = [.6 .6 .6];
    % cols = [0 0 0];
    line([i i], [.5 size_max], 'color', cols, 'linewidth', lw);
    line([.5 size_max], [i i], 'color', cols, 'linewidth', lw);
end

for i = .5:5:(size_r+.5)
    lw = .5; 
    cols = [.6 .6 .6];
    %cols = [0 0 0];
    line([i i], [.5 size_max], 'color', cols, 'linewidth', lw);
    line([.5 size_max], [i i], 'color', cols, 'linewidth', lw);
end

for i = [.5 size_r+.5]
    lw = 1; 
    %cols = [.4 .4 .4];
    cols = [0 0 0];
    line([i i], [.5 size_max], 'color', cols, 'linewidth', lw);
    line([.5 size_max], [i i], 'color', cols, 'linewidth', lw);
end
    
end






