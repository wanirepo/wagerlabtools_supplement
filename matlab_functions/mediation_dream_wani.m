function mediation_dream_wani(med_vars, models, jobn, mask, code_filename, study_scriptdir)

% mediation_dream_wani(med_vars, models, jobn, mask, code_filename, study_scriptdir)
%
% med_vars: x, y, m or m1, m2, imgs, covs.. these will be used in models.fns{i}
% models: models.fns{i}, models.savepaths{i} = [1,2,5]; models.name{i} = 'APP_dist_brain_rating_cov_placebo_nps'
% jobn: the number of distribution jobs
% mask: ...
% code_filename: '../APP_062214_mediation_dream_parallel.m'
% study_scriptdir: '/dreamio3/wagerlab/labdata/current/APP-fMRI/wani_script'

%% BASIC SETTING
% ===== path definition =====
path_def;
addpath(study_scriptdir);

% ===== saving mediation_SETUP files =====
[basedir, scriptname] = fileparts(code_filename);
if iscell(med_vars.imgs)
    data = fmri_data(med_vars.imgs{1}(1,:), mask);
elseif ischar(med_vars.imgs) % for the single level
    data = fmri_data(med_vars.imgs(1,:), mask);
end
data.dat = data.dat(:,1); % for 4-d images
    
chunk = 1000;  % can be adjusted
iter = ceil(length(data.dat)/chunk);
j = vec2mat(1:iter,ceil(iter/jobn));

modeln = numel(models.fns);

for i = 1:modeln
    col_num = numel(models.savepaths{i});
    eval(['model' num2str(i) '.p = NaN(size(data.dat,1),' num2str(col_num) ');']);
    eval(['model' num2str(i) '.beta = NaN(size(data.dat,1),' num2str(col_num) ');']);
    eval(['model' num2str(i) '.ste = NaN(size(data.dat,1),' num2str(col_num) ');']);
    
    if strfind(models.fns{i}, 'L2M')
        eval(['model' num2str(i) '.L2M.p = NaN(size(data.dat,1),' num2str(col_num) ');']);
        eval(['model' num2str(i) '.L2M.beta = NaN(size(data.dat,1),' num2str(col_num) ');']);
        eval(['model' num2str(i) '.L2M.ste = NaN(size(data.dat,1),' num2str(col_num) ');']);
    end
end

clear data col_num i;

if ~exist(basedir), mkdir(basedir); end
save(fullfile(basedir, ['mediation_SETUP_' scriptname '.mat']));

%% SAVE SCRIPTS AND RUNNING

% write scripts

prev_script = fullfile(basedir, [scriptname '_*.m']);
delete(prev_script);

for distjob = 1:size(j,1)
    
    distrib_script = fullfile(basedir, [scriptname '_' num2str(distjob) '.m']);
    FID = fopen(distrib_script, 'w');
    
    % description
    fprintf(FID, ['%% ' distrib_script '\n']);
    fprintf(FID, '\n');
    
    % load variables
    fprintf(FID, '%% load variables \n');
    fprintf(FID, ['load(''' basedir '/mediation_SETUP_' scriptname '.mat'');\n']);
    
    fprintf(FID, '\n');
    fprintf(FID, '%% path definition \n');
    fprintf(FID, 'reposdir = ''/home/chwo9116/codes_ineed/MATLAB/canlabrepo'';\n');
    fprintf(FID, 'addpath(genpath(reposdir));\n');
    fprintf(FID, 'spmdir = ''/usr/local/spm/spm8/'';\n');
    fprintf(FID, 'addpath(genpath(spmdir));\n');
    fprintf(FID, 'codeineed = ''/home/chwo9116/codes_ineed/MATLAB/wagerlabtools_supplement'';\n');
    fprintf(FID, 'addpath(genpath(codeineed));\n');
    fprintf(FID, ['study_scriptdir = ''' study_scriptdir ''';\n']);
    fprintf(FID, 'addpath(study_scriptdir);\n');
    fprintf(FID, '\n');
    
    % mediation
    
    fprintf(FID, '%% running mediation \n');
    fprintf(FID, '\n');
    
    fprintf(FID, ['for ii = j(' num2str(distjob) ',:)\n']);
    fprintf(FID, '\tif ii ~= 0\n');
    fprintf(FID, '\n');
    
    % data chunking
    fprintf(FID, '\t\t%% data chunking\n');
    
    fprintf(FID, '\t\tif iscell(med_vars.imgs)\n');
    fprintf(FID, '\t\t\tsubjn = numel(med_vars.imgs);\n');
    fprintf(FID, '\t\t\tfor i = 1:numel(med_vars.imgs)\n');
    fprintf(FID, '\t\t\t\tdat{i} = fmri_data(med_vars.imgs{i}, mask);\n');
    fprintf(FID, '\t\t\t\tif ii ~= iter\n');
    fprintf(FID, '\t\t\t\t\tdat{i}.dat = dat{i}.dat((chunk*ii-chunk+1):chunk*ii,:);\n');
    fprintf(FID, '\t\t\t\telseif ii == iter\n');
    fprintf(FID, '\t\t\t\t\tdat{i}.dat = dat{i}.dat((chunk*ii-chunk+1):end,:);\n');
    fprintf(FID, '\t\t\t\tend\n');
    fprintf(FID, '\t\t\tend\n');
    fprintf(FID, '\t\telseif ischar(med_vars.imgs) %% single level\n');
    fprintf(FID, '\t\t\tdat = fmri_data(med_vars.imgs, mask);\n');
    fprintf(FID, '\t\t\tif ii ~= iter\n');
    fprintf(FID, '\t\t\t\tdat.dat = dat.dat((chunk*ii-chunk+1):chunk*ii,:);\n');
    fprintf(FID, '\t\t\telseif ii == iter\n');
    fprintf(FID, '\t\t\t\tdat.dat = dat.dat((chunk*ii-chunk+1):end,:);\n');
    fprintf(FID, '\t\t\tend\n');
    fprintf(FID, '\t\tend\n');
    fprintf(FID, '\n');
    
    % running mediation functions
    fprintf(FID, '\t\t%% running mediation\n');
    
    fprintf(FID, '\t\tif iscell(dat)\n');
    fprintf(FID, '\t\t\tlen = length(dat{i}.dat);\n');
    fprintf(FID, '\t\telse\n');
    fprintf(FID, '\t\t\tlen = length(dat.dat);\n');
    fprintf(FID, '\t\tend\n');
    
    fprintf(FID, '\t\tfor i = 1:len\n');
    fprintf(FID, '\t\t\tif iscell(med_vars.imgs)\n');
    fprintf(FID, '\t\t\t\tfor jj = 1:numel(med_vars.imgs)\n');
    fprintf(FID, '\t\t\t\t\tM{jj} = double(dat{jj}.dat(i,:)'');\n');
    fprintf(FID, '\t\t\t\tend\n');
    fprintf(FID, '\t\t\telseif ischar(med_vars.imgs) %% single level\n');
    fprintf(FID, '\t\t\t\tM = double(dat.dat(i,:)'');\n');
    fprintf(FID, '\t\t\tend\n');
    
    fprintf(FID, '\n');
    fprintf(FID, '\t\t\tfor kk = 1:modeln\n');
    fprintf(FID, '\t\t\t\teval([''[dummy, stats] = '' models.fns{kk} '';'']);\n');
    fprintf(FID, '\t\t\t\teval([''model'' num2str(kk) ''.p((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk})) = stats.p(1,['' num2str(models.savepaths{kk}) '']);'']);\n');
    fprintf(FID, '\t\t\t\teval([''model'' num2str(kk) ''.beta((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk})) = stats.mean(1,['' num2str(models.savepaths{kk}) '']);'']);\n');
    fprintf(FID, '\t\t\t\teval([''model'' num2str(kk) ''.ste((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk})) = stats.ste(1,['' num2str(models.savepaths{kk}) '']);'']);\n');
    fprintf(FID, '\t\t\t\teval([''model'' num2str(kk) ''.firstlevelpaths((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk}), 1:subjn) = stats.paths(:,['' num2str(models.savepaths{kk}) ''])'''';'']);\n');
    
    fprintf(FID, '\t\t\t\tif strfind(models.fns{kk}, ''L2M'')\n');
    fprintf(FID, '\t\t\t\t\teval([''model'' num2str(kk) ''.L2M.p((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk})) = stats.p(2,['' num2str(models.savepaths{kk}) '']);'']);\n');
    fprintf(FID, '\t\t\t\t\teval([''model'' num2str(kk) ''.L2M.beta((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk})) = stats.mean_L2M(2,['' num2str(models.savepaths{kk}) '']);'']);\n');
    fprintf(FID, '\t\t\t\t\teval([''model'' num2str(kk) ''.L2M.ste((chunk*ii-chunk+1)+i-1,1:numel(models.savepaths{kk})) = stats.ste(2,['' num2str(models.savepaths{kk}) '']);'']);\n');
    fprintf(FID, '\t\t\t\tend\n');
    
    fprintf(FID, '\t\t\tend\n');
    fprintf(FID, '\t\tend\n');
    fprintf(FID, '\n');
    % fprintf(FID, '\t\tfor kk = 1:modeln\n');
    % fprintf(FID, '\t\t\teval([''model'' num2str(kk) ''.func = {'' models.fns(kk) ''};'']);\n');
    % fprintf(FID, '\t\t\teval([''model'' num2str(kk) ''.paths = {'' models.savepaths(kk) ''};'']);\n');
    % fprintf(FID, '\t\tend\n');
    fprintf(FID, '\tend\n');
    fprintf(FID, 'end\n');
    
    fprintf(FID, ['first_idx = (chunk*j(' num2str(distjob) ',1)-chunk+1);\n']);
    fprintf(FID, ['last_idx = (chunk*j(' num2str(distjob) ',end)-chunk+1)+chunk-1;\n']);
    
    fprintf(FID, ['savename = ''' basedir '/res_' scriptname '_' num2str(distjob) '.mat'';\n']);
    fprintf(FID, 'save(savename, ''model*'', ''*_idx'', ''-v7.3'');\n');
    
    fprintf(FID, ['content = ''' scriptname '_' num2str(distjob) ''';\n']);
    fprintf(FID, 'sendmail_wani(''clinpsywoo@gmail.com'', ''mediation_job_done'', content);\n');
    fclose(FID);
    
end

end

function path_def

% path definition
reposdir = '/dreamio3/wagerlab/Repository';
addpath(genpath(reposdir));

spmdir = '/usr/local/spm/spm8/';
addpath(genpath(spmdir));
%
codeineed = '/dreamio/home/chwo9116/codes_ineed/MATLAB/mycodes';
addpath(genpath(codeineed));

end

