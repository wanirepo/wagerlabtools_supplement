function out = svm_rfe(dat, varargin)

% varargin, see predict

% default
n_removal = 1000;
n_finalfeat = 50000;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case 'n_removal'
                n_removal = varargin{i+1};
                varargin(i+1) = [];
            case 'n_finalfeat'
                n_finalfeat = varargin{i+1};
                varargin(i+1) = [];
        end
    end
end

[cverr, stats, optout] = predict(dat, varargin);

dat_loop = dat;
% sorting the weights and remove the features, while keeping the indices

i = 0;

while 1
    
    i = i + 1;
    
    out.n_features(i,1) = size(dat_loop.dat,1);
    
    w = optout{1};
    [~, out.acending_idx{i}] = sort(w);
    
    % removal
    remove_idx = out.acending_idx{i}(1:n_removal);
    
    dat_loop.dat(remove_idx, :) = [];
    
    
    out.whkeep_orginal_idx{i} = ...;
        
    % reduce the dimension
    
    % rerun predict
    
    out.cv_accuracy(i,1) = 1-stats.cverr;
    
    
    
    if out.n_features(i) <= n_finalfeat, break, end
    
end

[max_acc, max_idx] = max(out.cv_accuracy);

out.best_n_features = out.n_features(max_idx);
out.best_accuracy = max_acc;

dat.dat = dat.dat(out.whkeep_orginal_idx{max_idx},:);
dat.removed_voxel ... = dat.dat(out.whkeep_orginal_idx{max_idx},:);

[cverr, out.stats, optout] = predict(dat, varargin);

end



