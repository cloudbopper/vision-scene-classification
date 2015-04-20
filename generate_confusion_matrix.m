function [ confMatrix ] = generate_confusion_matrix ( actualLabels,  predictedLabels)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%generate_confusion_matrix: Generates confusion matrix
%   Arguments: 
%       actualLabels - for the test images
%       predictedLabels - SVM output
%   Return value:
%       confMatrix - confusion matrix generated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

confMatrix = confusionmat(actualLabels, predictedLabels);
% disp(confMatrix);

num_labels = 15;
num_instances = length(actualLabels);

original = zeros(num_labels, num_instances);
predicted = zeros(num_labels, num_instances);
for i = 1:num_instances
    original(actualLabels(i), i) = 1;
    predicted(predictedLabels(i), i) = 1;
end

plotconfusion(original, predicted);

end

