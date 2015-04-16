function [all_images] = get_images(image_dir)

% given parent image dir as input
% returns hash map with classes as keys and image filenames as values

% image_dir = 'data/scene_categories';
classes = strsplit(strtrim(ls(image_dir)));

num_classes = numel(classes);
all_images = containers.Map();

for i = 1:num_classes
    class = classes{i};
    fnames = dir(fullfile(fullfile(image_dir, class), '*.jpg'));
    num_files = size(fnames,1);
    filenames = cell(num_files,1);

    for f = 1:num_files
        filenames{f} = fnames(f).name;
    end
    all_images(class) = filenames;
end