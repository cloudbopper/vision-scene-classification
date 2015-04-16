function [ ] = calculate_dictionary_kmeans( image_dir, data_dir, training_data, featureSuffix, params, canSkip, pfig )
% calculates dictionary using k-means over subset of training data
% assumes SIFT descriptors have been computed

% return if dictionary already exists
outFName = fullfile(data_dir, sprintf('dictionary_%d.mat', params.dictionarySize));
if(exist(outFName,'file')~=0 && canSkip)
    fprintf('Dictionary file %s already exists.\n', outFName);
    return;
end

working_dir = fullfile(data_dir, 'temp');
mkdir(working_dir);

classes = training_data.keys;
num_classes = numel(classes);
params.numTextonImages = num_classes * params.numTextonImagesPerClass;

% copy images/features to working directory
k = 1;
imageFileList = cell(params.numTextonImages, 1);
for i = 1:num_classes
    class = classes{i};
    filenames = training_data(class);
    subset_filenames = filenames(1:params.numTextonImagesPerClass);
    for j = 1:numel(subset_filenames)
        fname = subset_filenames{j};
        [~, base] = fileparts(fname);
        source_image_name = fullfile(fullfile(image_dir, class), fname);
        source_sift_name = sprintf('%s%s', fullfile(fullfile(image_dir, class), base), featureSuffix);
        dest_image_name = fullfile(working_dir, sprintf('%d.jpg', k));
        dest_sift_name = fullfile(working_dir, sprintf('%d%s', k, featureSuffix));
        copyfile(source_image_name, dest_image_name);
        copyfile(source_sift_name, dest_sift_name);
        imageFileList{k} = sprintf('%d.jpg', k);
        k = k + 1;
    end
end

% calculate dictionary
CalculateDictionary(imageFileList, working_dir, working_dir,'_sift.mat',params,canSkip,pfig);

% move to data dir
inFName = fullfile(working_dir, sprintf('dictionary_%d.mat', params.dictionarySize));
movefile(inFName, outFName);
rmdir(working_dir, 's');