% grid search
% possibilities:
% - codebook size
% - pyramid levels
% - kernel
% - codebook type (k-means vs optimized)
% - method (LLC vs baseline)
% - number of images per class used to generate dictionary
% - number of nearest neighbors

codebook_sizes = [1024, 2048];
nearest_neighbors = [5];
pyramid_levels = [3];
codebook_types = ['k-means'];
kernels = ['linear_kernel'];
methods = ['llc'];