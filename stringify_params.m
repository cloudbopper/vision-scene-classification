function [ out ] = stringify_params( params )
% returns values of different parameters in params stringed together
% for unique identification

arr = cell();
arr{1} = str(params.dictionarySize);
arr{2} = str(params.pyramidLevels);
arr{3} = str(params.k);
arr{4} = params.dictionaryType;
arr{5} = params.kernel;
arr{6} = params.method;
out = strjoin(arr, '_');

end

