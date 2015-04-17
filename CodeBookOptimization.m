function [ output_args ] = CodeBookOptimization( imageFileList, dataBaseDir, featureSuffix, params )%, lambda, sigma )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


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
    
    Xi = features.data;
    N = size(features.data,1);
    for i = 1:N
        %Computing distance from all code words
        dist = sp_dist2(Xi(i, :), B);
        dist_sigma = dist./sigma;
        d_exp = exp(dist_sigma);
        d = normr(d_exp);
        size(dist)
%         for j = 1:M
%             dist = sqrt() 
%             %d(1, j) =  
%         end
    end

end

