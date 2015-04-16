function [training_data, test_data] = split_data(image_dir, data_dir, all_images, params, canSkip)

% splits data into training/test sets
% returns hashes training_data/test_data indexed by class
% random split determined by seed

s = RandStream('mt19937ar','Seed',0);

classes = all_images.keys;
num_classes = numel(classes);
training_size = params.trainingSizePerClass;
training_data = containers.Map();
test_data = containers.Map();

for i = 1:num_classes
    class = classes{i};
    filenames = all_images(class);
    num_files = numel(filenames);
    idx = randperm(s, num_files);
    permuted_filenames = filenames(idx);
    training = permuted_filenames(1:training_size);
    test = permuted_filenames(training_size+1:end);
    training_data(class) = training;
    test_data(class) = test;
end
