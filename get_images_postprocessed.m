function [ all_images ] = get_images_postprocessed( image_dir )
% reads relabeled images (processed by preprocess_images.m) from input
% directory
%
% returns hashmap from image class to list of images belonging to that
% class

fnames = dir(fullfile(image_dir, '*.jpg'));
all_images = containers.Map();

for i = 1:numel(fnames)
    fname = fnames(i).name;
    [idx_start, idx_end] = regexp(fname, '^[a-zA-Z]+_');
    class = fname(idx_start:idx_end-1);
    if isKey(all_images, class)
        ll = all_images(class);
        ll{end + 1} = fname;
        all_images(class) = ll;
    else
        all_images(class) = {fname};
    end
end