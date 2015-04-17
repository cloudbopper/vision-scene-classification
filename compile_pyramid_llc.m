function [ pyramid_all ] = compile_pyramid_llc( imageFileList, dataBaseDir, textonSuffix, params, canSkip, pfig )
% Generate the pyramid from the encoded representation

fprintf('Building Spatial Pyramid\n\n');

% parameters

binsHigh = 2^(params.pyramidLevels-1);

pyramid_all = zeros(length(imageFileList),params.dictionarySize*sum((2.^(0:(params.pyramidLevels-1))).^2));
for f = 1:length(imageFileList)

    % load image
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    
    % progress bar
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,4,4,f,length(imageFileList),'Compiling Pyramid:');
    end

    % output pyramid
    outFName = fullfile(dataBaseDir, sprintf('%s_pyramid_llc_%d_%d.mat', baseFName, params.dictionarySize, params.pyramidLevels));
    if(size(dir(outFName),1)~=0 && canSkip)
        % fprintf('Found %s, skipping\n', imageFName);
        load(outFName, 'pyramid');
        pyramid_all(f,:) = pyramid;
        continue;
    end

    % load encoding
    in_fname = fullfile(dataBaseDir, sprintf('%s%s', baseFName, textonSuffix));
    load(in_fname, 'encoding');

    % get width and height of input image
    wid = encoding.wid;
    hgt = encoding.hgt;
    
    % compute histogram at the finest level
    pyramid_cell = cell(params.pyramidLevels,1);
    pyramid_cell{1} = zeros(binsHigh, binsHigh, params.dictionarySize);

    for i=1:binsHigh
        for j=1:binsHigh

            % find the coordinates of the current bin
            x_lo = floor(wid/binsHigh * (i-1));
            x_hi = floor(wid/binsHigh * i);
            y_lo = floor(hgt/binsHigh * (j-1));
            y_hi = floor(hgt/binsHigh * j);
            
            texton_patch = encoding.data( (encoding.x > x_lo) & (encoding.x <= x_hi) & ...
                                            (encoding.y > y_lo) & (encoding.y <= y_hi), :);
            
            % max pooling in bin
            max_pooled = max(texton_patch);
            pyramid_cell{1}(i,j,:) = max_pooled/norm(max_pooled);
        end
    end

    % compute histograms at the coarser levels
    num_bins = binsHigh/2;
    for l = 2:params.pyramidLevels
        pyramid_cell{l} = zeros(num_bins, num_bins, params.dictionarySize);
        for i=1:num_bins
            for j=1:num_bins
                pyramid_cell{l}(i,j,:) = max( ...
                [pyramid_cell{l-1}(2*i-1,2*j-1,:) ; pyramid_cell{l-1}(2*i,2*j-1,:) ; ...
                pyramid_cell{l-1}(2*i-1,2*j,:) ; pyramid_cell{l-1}(2*i,2*j,:)]);
            end
        end
        num_bins = num_bins/2;
    end

    % stack all the histograms with appropriate weights
    pyramid = [];
    for l = 1:params.pyramidLevels-1
        pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
    end
    pyramid = [pyramid pyramid_cell{params.pyramidLevels}(:)' .* 2^(1-params.pyramidLevels)];

    % save pyramid
    sp_make_dir(outFName);
    save(outFName, 'pyramid');

    pyramid_all(f,:) = pyramid;

end

outFName = fullfile(dataBaseDir, sprintf('pyramids_all_%d_%d.mat', params.dictionarySize, params.pyramidLevels));
%save(outFName, 'pyramid_all');


end
