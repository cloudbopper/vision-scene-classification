function [] = grid_search(image_dir, data_dir, params)

% grid search
% possibilities:
% - codebook size
% - grid spacing
% - patch size
% - pyramid levels
% - kernel
% - codebook type (k-means vs optimized)
% - method (LLC vs baseline)
% - number of images per class used to generate dictionary
% - number of nearest neighbors

codebook_sizes = [1024,2048];
% codebook_sizes = [1024];
num_training_images = [10,30,50,100];
pyramid_levels = [1,2,3];
% grid_spacings = [4,8];
% nearest_neighbors = [2,5];
% patch_sizes = [16,32];

% codebook_types = ['k-means'];
% kernels = ['linear_kernel'];
% methods = ['llc'];

canSkip = 1;
for i1 = 1:length(codebook_sizes)
    params.dictionarySize = codebook_sizes(i1);
    for i2 = 1:length(num_training_images)
        params.trainingSizePerClass = num_training_images(i2);
        for i3 = 1:length(pyramid_levels)
            params.pyramidLevels = i3;
            scene_classification(image_dir, data_dir, params, canSkip);
        end
    end
end

end