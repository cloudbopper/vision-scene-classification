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
disp(confMatrix);

%confMatrix = confusionmat(test_labels, predictions_svm);

end

