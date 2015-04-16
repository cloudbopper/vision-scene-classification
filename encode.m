function [ ] = encode( imageFileList, dataBaseDir, featureSuffix, params, canSkip, pfig )
% find texton labels of patches

% load dictionary
inFName = fullfile(dataBaseDir, sprintf('dictionary_%d.mat', params.dictionarySize));
load(inFName,'dictionary');
fprintf('Loaded dictionary: %d codewords\n', params.dictionarySize);

% compute codes of features
for f = 1:length(imageFileList)

    % input SIFT features
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));

    % progress bar
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,3,4,f,length(imageFileList),'Building Histograms:');
    end

    % output encoding file
    outFName = fullfile(dataBaseDir, sprintf('%s_encoding_%d.mat', baseFName, params.dictionarySize));
    if(exist(outFName,'file')~=0 && canSkip)
        fprintf('Found %s, skipping\n', imageFName);
        continue;
    end
    
    % load sift descriptors
    load(inFName, 'features');
    ndata = size(features.data,1);
    sp_progress_bar(pfig,3,4,f,length(imageFileList),'Building Histograms:');
    fprintf('Loaded %s, %d descriptors\n', inFName, ndata);

    % compute encoding
    encoding.data = zeros(ndata, params.dictionarySize);
    encoding.x = features.x;
    encoding.y = features.y;
    encoding.wid = features.wid;
    encoding.hgt = features.hgt;

    % Compute pairwise distances for each codeword-feature pair
    dist_mat = sp_dist2(features.data, dictionary);
    % Sort the distances
    [sort_dist, sort_ind] = sort(dist_mat, 2);
    %Get K-Nearest neighbors of xi
    kNNs = sort_dist(:, 1:k);
    
    [min_dist, min_ind] = min(dist_mat, [], 2);
    encoding.data = min_ind;

    %% save texton indices and histograms
    sp_make_dir(outFName);
    save(outFName, 'encoding');
end

end