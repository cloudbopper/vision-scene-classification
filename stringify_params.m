function [ out ] = stringify_params( params )
% returns values of different parameters in params stringed together
% for unique identification

arr = cell(1);
arr{1} = num2str(params.dictionarySize);
arr{end+1} = num2str(params.pyramidLevels);
arr{end+1} = num2str(params.k);
arr{end+1} = num2str(params.trainingSizePerClass);
arr{end+1} = num2str(params.numTextonImagesPerClass);
arr{end+1} = num2str(params.gridSpacing);
arr{end+1} = num2str(params.patchSize);
arr{end+1} = params.dictionaryType;
arr{end+1} = params.kernel;
arr{end+1} = params.method;
out = strjoin(arr, '_');

end