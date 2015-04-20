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
%params.dictionarySize = 200;
params.dictionarySize = 1048;
params.numTextonImagesPerClass = 10;
params.k = 5; % number of nearest neighbors
params.pyramidLevels = 3;
params.oldSift = false;
params.trainingSizePerClass = 100;
% params.kernel = 'histogram_kernel';
params.kernel = 'linear_kernel';
% params.method = 'baseline';
params.method = 'llc';
params.dictOpt = 'yes';
canSkip = 1;
saveSift = 1;
pfig = sp_progress_bar('Generating SIFT Features');

if (~exist(image_dir, 'dir'))
    preprocess_images();
end

% hash from class to image filenames
disp('Retrieving image mapping...');
all_images = get_images_postprocessed(image_dir);

classes = all_images.keys;
num_classes = numel(classes);

imageFileList = {};
for i = 1:num_classes
    class = classes{i};
    fnames = all_images(class);
    for j = 1:numel(fnames)
        fname = fnames{j};
        imageFileList{end+1} = fname;
    end
end

disp('Done.');

% Generate SIFT Features
disp('Generating SIFT Features...');
if(saveSift)
    GenerateSiftDescriptors(imageFileList, image_dir, data_dir, params, canSkip, pfig);
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

if (strcmp(params.method, 'baseline'))
    % Build histogram
    disp('Building histogram...');
    BuildHistograms(imageFileList,image_dir, data_dir, '_sift.mat', params, canSkip, pfig);
    disp('Done.');

    % Compile pyramids
    disp('Compiling pyramid...');
    pyramid_all = CompilePyramid(imageFileList, data_dir, sprintf('_texton_ind_%d.mat', params.dictionarySize), params, canSkip, pfig);
    disp('Done.');
elseif (strcmp(params.method, 'llc'))
    % Compute LLC encoding
    disp('Computing LLC encoding...');
    encode_llc(imageFileList, data_dir, '_sift.mat', params, canSkip, pfig);
    disp('Done.');

    % Compile pyramids
    disp('Compiling LLC pyramid...');
    pyramid_all = compile_pyramid_llc(imageFileList, data_dir, sprintf('_encoding_%d.mat', params.dictionarySize), params, canSkip, pfig);
    disp('Done.');
end

if (strcmp(params.method, 'histogram_kernel'))
    % compute histogram intersection kernel
    disp('Computing histogram intersection kernel...');
    K_fname = fullfile(data_dir, 'histogram_intersection_kernel.mat');
    if (size(dir(K_fname),1) ~= 0 && canSkip)
        fprintf('Found %s, skipping recomputation\n', K_fname);
        load(K_fname);
    else
        K = hist_isect(pyramid_all, pyramid_all);
        save(K_fname, 'K');
    end

    % for faster performance, compile and use hist_isect_c:
    % K = hist_isect_c(pyramid_all, pyramid_all);
    disp('Done.');
end

% Organize training/test data
disp('Organizing training/test data...');

% map classes to integers
labels = containers.Map();
for i = 1:num_classes
    labels(classes{i}) = i;
end

% map filenames to row indices
filename_indices = containers.Map();
for i = 1:numel(imageFileList)
    filename_indices(imageFileList{i}) = i;
end

training_size = num_classes * params.trainingSizePerClass;
training_labels = zeros(training_size, 1);
training_idx = zeros(training_size, 1);

test_size = numel(imageFileList) - training_size;
test_labels = zeros(test_size, 1);
test_idx = zeros(test_size, 1);

k = 1;
l = 1;
for i = 1:num_classes
    class = classes{i};
    fnames = training_data(class);
    for j = 1:numel(fnames)
        fname = fnames{j};
        training_idx(k) = filename_indices(fname);
        training_labels(k) = labels(class);
        k = k + 1;
    end
    fnames = test_data(class);
    for j = 1:numel(fnames)
        fname = fnames{j};
        test_idx(l) = filename_indices(fname);
        test_labels(l) = labels(class);
        l = l + 1;
    end
end

training_set = pyramid_all(training_idx, :);
test_set = pyramid_all(test_idx, :);

if (strcmp(params.kernel, 'histogram_kernel'))
    training_set = [(1:training_size)' K(training_idx, training_idx)];
    test_set = [(1:test_size)' K(test_idx, training_idx)];
elseif (strcmp(params.kernel, 'linear_kernel'))
    training_set = sparse(training_set);
    test_set = sparse(test_set);
else
    error('Missing/invalid kernel specification params.kernel');
end

disp('Done.');

% SVM training
disp('Training SVM...');
svm_options = '';
if (strcmp(params.kernel, 'histogram_kernel'))
    svm_options = '-t 4';
    model = svmtrain(training_labels, training_set, svm_options);
elseif (strcmp(params.kernel, 'linear_kernel'))
    model = train(training_labels, training_set, svm_options);
else
    error('Missing/invalid kernel specification params.kernel');
end
disp('Done.');

% SVM prediction
disp('Classifying using learned SVM...');
if (strcmp(params.kernel, 'histogram_kernel'))
    predictions = svmpredict(test_labels, test_set, model, '');
elseif (strcmp(params.kernel, 'linear_kernel'))
    predictions = predict(test_labels, test_set, model, '');
else
    error('Missing/invalid kernel specification params.kernel');
end
disp('Done.');