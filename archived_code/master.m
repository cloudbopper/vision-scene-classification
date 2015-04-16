% Master script for LLC for scene classification

% add folders to path
addpath('SpatialPyramid');
addpath('libsvm-3.20/matlab');
addpath('liblinear-1.96/matlab');

% configuration hash
config = {};

% config.image_dir = 'SpatialPyramid/images';
config.image_dir = 'data/scene_categories/';
config.data_dir = 'SpatialPyramid/data';
config.kernel = 'linear_kernel';

fnames = dir(fullfile(config.image_dir, '*.jpg'));
num_files = size(fnames,1);
filenames = cell(num_files,1);

for f = 1:num_files
	filenames{f} = fnames(f).name;
end

% return pyramid descriptors for all files in filenames
pyramid_all = BuildPyramid(filenames,config.image_dir,config.data_dir);

% compute histogram intersection kernel
K = hist_isect(pyramid_all, pyramid_all); 

% for faster performance, compile and use hist_isect_c:
% K = hist_isect_c(pyramid_all, pyramid_all);

% temporary code to test libsvm
training_size = 3;
training_labels = [1;0;0];
% training_data = pyramid_all(1:training_size,:);
% test_data = pyramid_all(4:5,:);

% linear kernel
% K = linear_kernel(pyramid_all);

% kernel SVM
training_data = [(1:training_size)' K(1:training_size,1:training_size)];
test_data = [(4:5)' K(4:5,1:3)];

disp('Training...');
model = svmtrain(training_labels, training_data, '-t 4');

disp('Testing...');
predictions = svmpredict([0;1], test_data, model, '');