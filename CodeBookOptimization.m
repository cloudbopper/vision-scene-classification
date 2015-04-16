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

%Iterating over each image
for f = 1:length(imageFileList)
    % input SIFT features
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
    % load sift descriptors
    load(inFName, 'features');
    
    X = features.data;
    N = size(features.data,1);
%     for i = 1:N
%         d = zeros(1, M);
%         for j = 1:M
%             d(1, j) =  
%         end
%     end

end

