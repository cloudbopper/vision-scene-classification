function [ output_args ] = CodeBookOptimization( imageFileList, dataBaseDir, featureSuffix, params, lambda, sigma )
%On-line learning method for codebook optimization

%Load dictionary from K-means
inFName = fullfile(dataBaseDir, sprintf('dictionary_%d.mat', params.dictionarySize));
load(inFName,'dictionary');
fprintf('Loaded dictionary: %d codewords\n', params.dictionarySize);

%Initializing to K-means dictionary, a M X D matrix
Binit = dictionary;
M = size(Binit, 1);

B = Binit;
%Iterating over each image
for f = 1:length(imageFileList)
    % input SIFT features
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
    % load sift descriptors
    load(inFName, 'features');
    
    % N x D SIFT features matrix for current image
    Xi = features.data;
    N = size(features.data, 1);
    for i = 1:N
        %% Locality constraint parameter
        
        %Computing distance from all code words
        dist = sp_dist2(Xi(i, :), B);
        %Calculating dj's
        dist_sigma = dist./sigma;
        d_exp = exp(dist_sigma);
        % 1 x M dj matrix
        d = normr(d_exp);
        %Converting to M X 1 matrix
        d = transpose(d);
        
        %% Coding
        
        one = ones(M, 1);  
        Bi_1x = (B - one * Xi(i, :));
        % compute data covariance matrix
        Ci = Bi_1x * Bi_1x';
        ci_cap = (Ci + lambda * diag(d)) / one;
        ci = ci_cap \ one;
        ci = ci / sum(ci);
        
        %% Remove bias
        
        %% Update bias
        
        
        
    end

end

