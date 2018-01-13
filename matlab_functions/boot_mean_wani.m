function out = boot_mean_wani(vals, nboot, varargin)

% function out = boot_mean_wani(vals, nboot)
%
% boot for mean
%
% vals: values you want to bootstrap
% nboot: number of bootstraps (e.g., 10000)

% *optional input:
%
% 'noverbose'

doverbose = true;

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'noverbose'}
                doverbose = false;
        end
    end
end

boot_vals = bootstrp(nboot, @mean, vals);
out.bootmean = mean(boot_vals);
out.bootste = std(boot_vals);
out.bootZ = bootmean./bootste;
out.bootP = 2 * (1 - normcdf(abs(bootZ)));

if doverbose
    fprintf('\nTest results: mean = %1.4f, sem = %1.4f, z = %1.4f, p = %1.5f', mean(boot_vals), out.bootste, out.bootZ, out.bootP);
end

end
