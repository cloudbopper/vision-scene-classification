function [ ] = calculate_dictionary_optimized(data_dir, training_data, featureSuffix, params, canSkip, pfig )
% calculates optimized dictionary
% assumes k-means dictionary already exists (for initialization)

outFName = fullfile(data_dir, sprintf('dictionary_%d_llc.mat', params.dictionarySize));
if (exist(outFName,'file') && canSkip)
    fprintf('Optimized dictionary file %s already exists.\n', outFName);
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

% Obtaining new dictionary
CodeBookOptimization( imageFileList, data_dir, featureSuffix, params );

end
