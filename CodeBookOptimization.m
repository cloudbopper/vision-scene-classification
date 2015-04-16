function [ output_args ] = CodeBookOptimization( imageFileList, dataBaseDir, lambda, sigma )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%Load dictionary from K-means
inFName = fullfile(dataBaseDir, sprintf('Binit_%d.mat', params.BinitSize));
load(inFName,'Binit');
fprintf('Loaded Binit: %d codewords\n', params.BinitSize);

%Initializing to K-means dictionary
%Binit = transpose(Binit);
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
    
    N = size(features.data,1);
%     for i = 1:N
%         d = zeros(1, M);
%         for j = 1:M
%             d(1, j) =  
%         end
%     end

end

