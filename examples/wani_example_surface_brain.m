close all;
maskdir = '/Users/clinpsywoo/Documents/Workspace/Wagerlab_Single_Trial_Pain_Datasets/wani_results/v11_controlfor_temp_nps_scale_pattern_later/ttest_v11_4_wo_scebl';
cl = region(fullfile(maskdir, 'nonnoc_v11_4_137subjmap_fdr05_unc0025_wttest.nii'));

poscm = colormap_tor([0.96 0.41 0], [1 1 0]);  %slate to orange to yellow
negcm = colormap_tor([0.11 0.46 1], [.23 1 1]);  % light blue to dark blue

% h = add_surface(which('surf_BrainMesh_ICBM152.mat'));
% set(h, 'FaceColor', [.7 .7 .7], 'FaceAlpha', .1);

cluster_surf(cl ,which('surf_BrainMesh_ICBM152_smoothed.mat'), 2, 'heatmap', 'colormaps', poscm, negcm)
%cluster_surf(clusters1,'surf_parahippo_havardoxford_20_l.mat', 2, 'heatmap', 'colormaps', poscm, negcm)

h = get(gca, 'children');
set(h(2), 'FaceAlpha', .5);
set(h(2), 'AmbientStrength', .1)

axis vis3d;
