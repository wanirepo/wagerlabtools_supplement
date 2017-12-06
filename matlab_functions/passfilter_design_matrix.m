function X = passfilter_design_matrix(X, TR, idx_cols, varargin)

% This function applies pass filters on a design matrix. 
%
% :Usage:
% ::
%
%    X = passfilter_design_matrix(X, TR, varargin)
%
%
% :Inputs:
%
%   **X:**
%        design matrix
%
%   **TR:**
%        repetition time
%
%   **idx_cols:**
%        column indices for the filtering
%
%
% :Optional Inputs:
%
%   **'hpf', 'lpf', or 'bpf':**
%
%        This option will do temporal filtering.
%        - 'hpf': high pass filter. This option should be followed by
%                 the lower bound of the frequency (e.g., .01 Hz [= 100 sec])
%        - 'lpf': low pass filter. This option should be followed by
%                 the upper bound of the frequency (e.g., .25 Hz [= 4 sec])
%        - 'bpf': bandpass filter. This should be followed by lower
%                 and upper bounds of the frequency (e.g., [.01 .25])
%
%        - *Example:* 'hpf', .01
%                     'lpf', .1
%                     'bpf', [.01 .25]
%
% ..
%     Author and copyright information:
%
%     Copyright (C) Nov 2017  Choong-Wan Woo
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ..

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            
            case {'hpf', 'lpf', 'bpf'}
                if any(strcmp(varargin, 'hpf')), filter(1) = varargin{i+1}; filter(2)= Inf; end
                if any(strcmp(varargin, 'lpf')), filter(1) = 0; filter(2) = varargin{i+1}; end
                if any(strcmp(varargin, 'bpf')), filter = varargin{i+1}; end
                
        end
    end
end

X_interest = X(:,idx_cols);

fprintf('::: temporal filtering on design matrix... \n');

X_interest_hpf = conn_filter(TR, filter, X_interest, 'full') ...
       + repmat(mean(X_interest), size(X_interest,1), 1); % conn_filter does mean-center by default.
                                                          % So need mean back in
X(:,idx_cols) = X_interest_hpf;

end

function [y,fy]=conn_filter(rt, filter, x, option)

% from conn toolbox
% http://www.nitrc.org/projects/conn/

if nargin < 4, option='full'; end

fy=fft(x,[],1);
f=(0:size(x,1)-1);
f=min(f,size(x,1)-f);

switch(lower(option))
    case 'full'
        
        idx=find(f<filter(1)*(rt*size(x,1))|f>=filter(2)*(rt*size(x,1)));
        %idx=idx(idx>1);
        fy(idx,:)=0;
        y=real(ifft(fy,[],1))*2*size(x,1)*(min(.5,filter(2)*rt)-max(0,filter(1)*rt))/max(1,size(x,1)-numel(idx));
        
    case 'partial'
        
        idx=find(f>=filter(1)*(rt*size(x,1))&f<filter(2)*(rt*size(x,1)));
        %if ~any(idx==1), idx=[1,idx]; end
        y=fy(idx,:);
        
end

end
