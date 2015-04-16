function [ ] = calculate_dictionary_kmeans( image_dir, data_dir, training_data, featureSuffix, params, canSkip, pfig )
% calculates dictionary using k-means over subset of training data
% assumes SIFT descriptors have been computed

% return if dictionary already exists
outFName = fullfile(data_dir, sprintf('dictionary_%d.mat', params.dictionarySize));
if(exist(outFName,'file')~=0 && canSkip)
    fprintf('Dictionary file %s already exists.\n', outFName);
    return;
end

classes = training_data.keys;
num_classes = numel(classes);
params.numTextonImages = num_classes * params.numTextonImagesPerClass;

k = 1;
imageFileList = cell(params.numTextonImages, 1);
for i = 1:num_classes
    class = classes{i};
    filenames = training_data(class);
    subset_filenames = filenames(1:params.numTextonImagesPerClass);
    for j = 1:numel(subset_filenames)
        imageFileList{k} = subset_filenames{j};
        k = k + 1;
    end
end

% calculate dictionary
CalculateDictionary(imageFileList, image_dir, data_dir, featureSuffix, params, canSkip, pfig);