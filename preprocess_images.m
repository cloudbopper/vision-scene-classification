% preprocess images into format digestible by SpatialPyramid code

disp('Preprocessing images...');

source_dir = 'data/scene_categories/';
image_dir = 'data/images';
data_dir = 'data/data';

% hash from class to image filenames
all_images = get_images(source_dir);

mkdir(image_dir);
mkdir(data_dir);

classes = all_images.keys;
num_classes = numel(classes);

for i = 1:num_classes
    class = classes{i};
    source_image_dir = fullfile(source_dir, class);
    filenames = all_images(class);
    for j = 1:numel(filenames);
        fname = filenames{j};
        source_image_file = fullfile(source_image_dir, fname);
        dest_image_file = fullfile(image_dir, sprintf('%s_%s', class, fname));
        copyfile(source_image_file, dest_image_file);
    end
end

disp('Done.');
