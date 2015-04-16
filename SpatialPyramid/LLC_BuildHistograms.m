function [ H_all ] = LLC_BuildHistograms( imageFileList,imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig, k )
%function [ H_all ] = LLC_BuildHistograms( imageFileList,imageBaseDir, dataBaseDir, featureSuffix, params, canSkip, pfig, k )
%
% k - number of nearest neighbors to pick for LLC coding process
%
%find texton labels of patches and compute texton histograms of all images
%   
% For each image the set of sift descriptors is loaded and then each
%  descriptor is labeled with its texton label. Then the global histogram
%  is calculated for the image. If you wish to just use the Bag of Features
%  image descriptor you can stop at this step, H_all is the histogram or
%  Bag of Features descriptor for all input images.
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image file
% featureSuffix: this is the suffix appended to the image file name to
%  denote the data file that contains the feature textons and coordinates. 
%  Its default value is '_sift.mat'.
% dictionarySize: size of descriptor dictionary (200 has been found to be
%  a good size)
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Histograms\n\n');

%% parameters

if(~exist('params','var'))
    params.maxImageSize = 1000;
    params.gridSpacing = 8;
    params.patchSize = 16;
    params.dictionarySize = 2048;
    params.numTextonImages = 50;
    params.pyramidLevels = 3;
end
if(~isfield(params,'maxImageSize'))
    params.maxImageSize = 1000;
end
if(~isfield(params,'gridSpacing'))
    params.gridSpacing = 8;
end
if(~isfield(params,'patchSize'))
    params.patchSize = 16;
end
if(~isfield(params,'dictionarySize'))
    params.dictionarySize = 2048;
end
if(~isfield(params,'numTextonImages'))
    params.numTextonImages = 50;
end
if(~isfield(params,'pyramidLevels'))
    params.pyramidLevels = 3;
end
if(~exist('canSkip','var'))
    canSkip = 1;
end
%% load texton dictionary (all texton centers)

inFName = fullfile(dataBaseDir, sprintf('dictionary_%d.mat', params.dictionarySize));
load(inFName,'dictionary');
fprintf('Loaded texton dictionary: %d textons\n', params.dictionarySize);

%% compute texton labels of patches and whole-image histograms
H_all = [];
if(exist('pfig','var'))
    %tic;
end
for f = 1:length(imageFileList)

    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
    
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,3,4,f,length(imageFileList),'Building Histograms:');
    end
    outFName = fullfile(dataBaseDir, sprintf('%s_texton_ind_%d.mat', baseFName, params.dictionarySize));
    outFName2 = fullfile(dataBaseDir, sprintf('%s_hist_%d.mat', baseFName, params.dictionarySize));
    if(exist(outFName,'file')~=0 && exist(outFName2,'file')~=0 && canSkip)
        %fprintf('Skipping %s\n', imageFName);
        if(nargout>1)
            load(outFName2, 'H');
            
            H_all = [H_all; H];
        end
        continue;
    end
    
    %% load sift descriptors
    if(exist(inFName,'file'))
        load(inFName, 'features');
    else
        features = sp_gen_sift(fullfile(imageBaseDir, imageFName),params);
    end
    ndata = size(features.data,1);
    sp_progress_bar(pfig,3,4,f,length(imageFileList),'Building Histograms:');
    %fprintf('Loaded %s, %d descriptors\n', inFName, ndata);

    %% find texton indices and compute histogram 
    texton_ind.data = zeros(ndata,1);
    texton_ind.x = features.x;
    texton_ind.y = features.y;
    texton_ind.wid = features.wid;
    texton_ind.hgt = features.hgt;
    %run in batches to keep the memory foot print small
    batchSize = 100000;
    if ndata <= batchSize
        dist_mat = sp_dist2(features.data, dictionary);
        %LLC code changes
        %Sort the distances in row dimension
        [sort_dist, sort_ind] = sort(dist_mat, 2);
        %Get K-Nearest neighbors of xi
        kNNs = sort_dist(:, 1:k);
        %Performing row normalization
        kNNs = normr(kNNs);
        %Squaring 2-norm
        kNNs = kNNs.^2;
        numFeatures = size(dist_mat,1);
        ci = zeros(params.dictionarySize, 1);
        for row = 1:numFeatures
            for col = 1:k
                cStar = kNNs(row, col);
                %Index value before sorting to determine the correct
                %cluster
                clusterNum = sort_ind(row, col);
                ci(clusterNum, 1) = ci(clusterNum, 1) + cStar;
            end
        end
        %Constructing histogram bins by using count of individual clusters
        ci = ceil(ci);
        numBins = sum(ci(:));
        histMatrix = zeros(numBins, 1);
        clusterNum = 1;
        for i = 1:size(ci, 1)
            ciCount = ci(i, 1);
            for j = 1:ciCount
               histMatrix(clusterNum, 1) = i;
               clusterNum = clusterNum + 1; 
            end
        end
        texton_ind.data = histMatrix;
    else
        for j = 1:batchSize:ndata
            lo = j;
            hi = min(j+batchSize-1,ndata);
            dist_mat = sp_dist2(features.data(lo:hi,:), dictionary);
            %Sort the distances in row dimension
            [sort_dist, sort_ind] = sort(dist_mat, 2);
            %Get K-Nearest neighbors of xi
            kNNs = sort_dist(:, 1:k);
            %Performing row normalization
            kNNs = normr(kNNs);
            %Squaring 2-norm
            kNNs = kNNs.^2;
            numFeatures = size(dist_mat,1);
            ci = zeros(params.dictionarySize, 1);
            for row = 1:numFeatures
                for col = 1:k
                    cStar = kNNs(row,col);
                    clusterNum = sort_ind(row, col);
                    ci(clusterNum, 1) = ci(clusterNum, 1) + cStar;
                end
            end
            %Constructing histogram bins by using count of individual clusters
            ci = ceil(ci);
            numBins = sum(ci(:));
            histMatrix = zeros(numBins, 1);
            clusterNum = 1;
            for i = 1:size(ci, 1)
                ciCount = ci(i, 1);
                for l = 1:ciCount
                    histMatrix(clusterNum, 1) = i;
                    clusterNum = clusterNum + 1;
                end
            end
            texton_ind.data(lo:hi,:) = histMatrix;
        end
    end
    
    H = hist(texton_ind.data, 1:params.dictionarySize);
    %H = H ./ sum(H);
    %H_all = [H_all; H];

    %% save texton indices and histograms
    sp_make_dir(outFName);
    save(outFName, 'texton_ind');
    save(outFName2, 'H');
end

%% save histograms of all images in this directory in a single file
outFName = fullfile(dataBaseDir, sprintf('histograms_%d.mat', params.dictionarySize));
%save(outFName, 'H_all', '-ascii');


end

