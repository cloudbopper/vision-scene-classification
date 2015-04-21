function [ ] = scene_classification( image_dir, data_dir, params, canSkip )
% scene classification

disp('Commencing scene classification with params:');
disp(params);

saveSift = 1;
pfig = sp_progress_bar(sprintf('Scene classification: %s', stringify_params(params)));

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

if (strcmp(params.dictionaryType, 'optimized'))
    % Build optimized dictionary
    disp('Building optimized dictionary...');
    calculate_dictionary_optimized(data_dir, training_data, '_sift.mat', params, canSkip, pfig);
    disp('Done.');
end

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
    pyramid_all = compile_pyramid_llc(imageFileList, data_dir, sprintf('_encoding_%d_%s.mat', params.dictionarySize, params.dictionaryType), params, canSkip, pfig);
    disp('Done.');
end

if (strcmp(params.kernel, 'histogram_kernel'))
    % compute histogram intersection kernel
    disp('Computing histogram intersection kernel...');
    K_fname = fullfile(data_dir, sprintf('histogram_intersection_kernel_%d.mat', params.pyramidLevels));
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
end

disp('Done.');

% SVM training
disp('Training SVM...');
if (strcmp(params.kernel, 'histogram_kernel'))
    model_svm = svmtrain(training_labels, training_set, '-t 4');
    % save(sprintf('svm_model_%s_%d_%d_%d.mat', params.kernel, ...
    %    params.dictionarySize, params.pyramidLevels, params.k), 'model_svm', 'params');
elseif (strcmp(params.kernel, 'linear_kernel'))
    model_libl = train(training_labels, sparse(training_set), '');
    model_svm = svmtrain(training_labels, training_set, '-t 0');
else
    error('Missing/invalid kernel specification params.kernel');
end
disp('Done.');

% SVM prediction
disp('Classifying using learned SVM...');
if (strcmp(params.kernel, 'histogram_kernel'))
    [predictions_svm, accuracy_svm, prob_estimates_svm] = svmpredict(test_labels, test_set, model_svm, '');
elseif (strcmp(params.kernel, 'linear_kernel'))
    disp('Using liblinear:');
    [predictions_libl, accuracy_libl, prob_estimates_libl] = predict(test_labels, sparse(test_set), model_libl, '');
    disp('Using libsvm:');
    [predictions_svm, accuracy_svm, prob_estimates_svm] = svmpredict(test_labels, test_set, model_svm, '');
else
    error('Missing/invalid kernel specification params.kernel');
end
disp('Done.');

% Plot confusion matrix
confusion = generate_confusion_matrix(test_labels, predictions_svm);

% save outputs
output_filename = fullfile(data_dir, sprintf('outputs_%s.mat', stringify_params(params)));
save(output_filename, 'test_labels', 'predictions_svm', 'confusion');



end