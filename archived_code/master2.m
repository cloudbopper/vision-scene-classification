% Master script for LLC scene classification

clear all;
close all;
clc;

% add folders to path
addpath('SpatialPyramid');
addpath('libsvm-3.20/matlab');
addpath('liblinear-1.96/matlab');

% Parameters
data_dir = 'data';
image_dir = fullfile(data_dir, 'scene_categories');
params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 200;
params.numTextonImagesPerClass = 10;
params.pyramidLevels = 3;
params.oldSift = false;
params.trainingSize = 100;
canSkip = 1;
saveSift = 1;
pfig = sp_progress_bar('Generating SIFT Features');

% hash from class to image filenames
all_images = get_images(image_dir);

classes = all_images.keys;
num_classes = numel(classes);


% Generate SIFT Features
disp('Generating SIFT Features...');
for i = 1:num_classes
    class = classes{i};
    imageBaseDir = fullfile(image_dir, class);
    dataBaseDir = imageBaseDir;
    imageFileList = all_images(class);
    if(saveSift)
        GenerateSiftDescriptors(imageFileList,imageBaseDir,dataBaseDir,params,canSkip,pfig);
    end
end
disp('Done.');

% Generate training/test sets
disp('Generating training/test sets...');
[training_data, test_data] = split_data(image_dir, data_dir, all_images, params, canSkip);
disp('Done.');

% Pool together training sets to build dictionary using k-means
disp('Building dictionary...');
calculate_dictionary_kmeans(image_dir, data_dir, training_data, '_sift.mat', params, canSkip, pfig);
disp('Done.');

% Build image pyramids

