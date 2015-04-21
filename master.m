% Master script for LLC scene classification

clear all;
close all;
clc;

% add folders to path
addpath('SpatialPyramid');
addpath('libsvm-3.20/matlab');
addpath('liblinear-1.96/matlab');

% Parameters
parent_dir = 'data';
data_dir = fullfile(parent_dir, 'data');
image_dir = fullfile(parent_dir, 'images');
params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
% params.dictionarySize = 200;
params.dictionarySize = 1024;
% params.dictionarySize = 2048;
params.numTextonImagesPerClass = 10;
params.k = 5; % number of nearest neighbors
params.pyramidLevels = 3;
params.oldSift = false;
params.trainingSizePerClass = 100;
% params.kernel = 'histogram_kernel';
params.kernel = 'linear_kernel';
% params.method = 'baseline';
params.method = 'llc';
params.dictionaryType = 'k-means';
% params.dictionaryType = 'optimized';
params.lambda = 1;
params.sigma = 1;

canSkip = 1;
gridSearch = 0;
if (gridSearch)
    grid_search(image_dir, data_dir, params);
else
    scene_classification(image_dir, data_dir, params, canSkip);
end