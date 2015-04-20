function [ ] = encode_llc( imageFileList, dataBaseDir, featureSuffix, params, canSkip, pfig )
% find texton labels of patches

% load dictionary
if (strcmp(params.dictionaryType, 'optimized'))
    inFName = fullfile(dataBaseDir, sprintf('dictionary_%d_llc.mat', params.dictionarySize));
    load(inFName,'dictionary');
    fprintf('Loaded optimized dictionary: %d codewords\n', params.dictionarySize);
else
    inFName = fullfile(dataBaseDir, sprintf('dictionary_%d.mat', params.dictionarySize));
    load(inFName,'dictionary');
    fprintf('Loaded dictionary: %d codewords\n', params.dictionarySize);
end

% compute codes of features
for f = 1:length(imageFileList)

    % load image
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);

    % progress bar
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,3,4,f,length(imageFileList),'LLC Encoding:');
    end

    % output encoding file
    outFName = fullfile(dataBaseDir, sprintf('%s_encoding_%d_%s.mat', baseFName, params.dictionarySize, params.dictionaryType));
    if(exist(outFName,'file')~=0 && canSkip)
        % fprintf('Found %s, skipping\n', imageFName);
        continue;
    end

    % input SIFT features
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
    load(inFName, 'features');
    ndata = size(features.data,1);
    % fprintf('Loaded %s, %d descriptors\n', inFName, ndata);

    % compute encoding
    encoding.data = zeros(ndata, params.dictionarySize);
    encoding.idx = zeros(ndata, params.k);
    encoding.x = features.x;
    encoding.y = features.y;
    encoding.wid = features.wid;
    encoding.hgt = features.hgt;

    X = features.data;
    B = dictionary;

    % Compute pairwise distances for each codeword-feature pair
    dist_mat = sp_dist2(X, B);
    % Sort the distances along each row
    [~, sort_idx] = sort(dist_mat, 2);
    % Get k nearest neighbors of each feature
    one = ones(params.k, 1);
    for i = 1:ndata
        idx = sort_idx(i,1:params.k);
        xi = X(i,:);
        Bi = B(idx, :);

        % compute data covariance matrix
        Bi_1x = (Bi - one * xi);
        Ci = Bi_1x * Bi_1x';

        % reconstruct LLC code
        ci_hat = Ci \ one;
        ci = ci_hat /sum(ci_hat);

        % plug into encoding matrix
        encoding.data(i,idx) = ci';
        encoding.idx(i,:) = idx;
    end

    % save encoding
    sp_make_dir(outFName);
    save(outFName, 'encoding');
end

end