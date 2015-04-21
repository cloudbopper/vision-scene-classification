printfilenames = 0;
if (printfilenames)
    parent_dir = 'data/outputs/baseline';
    files = dir(sprintf('%s/outputs_*.mat', parent_dir));
    for i=1:length(files)
        f = files(i).name;
        load(sprintf('%s/%s', parent_dir, f));
        correct = sum(test_labels == predictions_svm);
        total = length(test_labels);
        accuracy = 100*correct/total;
        fprintf('%.2f\n', accuracy);
    end
end

M = csvread('data/outputs/grid_search_2.csv');
LLC1 = M(1:12,:);
LLC2 = M(13:24,:);
OPT = M(25:36,:);
BSL = M(37:48,:);

% plot accuracy vs num training images
fig1 = figure;
hold on;
row1 = 9:12;
row2 = 21:24;
row3 = 33:36;
row4 = 45:48;
plot(M(row1, 2), M(row1, 4), 'b-');
plot(M(row2, 2), M(row2, 4), 'r+-');
plot(M(row3, 2), M(row3, 4), 'go-');
plot(M(row4, 2), M(row4, 4), 'kx-');
legend('LLC with k-means codebook, size = 1024', 'LLC with k-means codebook, size = 2048', ...
    'LLC with optimized codebook, size = 1024', 'Baseline with k-means codebook, size = 1024');
title('Accuracy vs number of training images (pyramid level 3)');
xlabel('Number of training images per class');
ylabel('Accuracy');

% plot accuracy vs pyramid level
fig2 = figure;
hold on;
idx1 = 4:4:12;
idx2 = 16:4:24;
idx3 = 28:4:36;
idx4 = 40:4:48;
plot(M(idx1, 1), M(idx1, 4), 'b-');
plot(M(idx2, 1), M(idx2, 4), 'r+-');
plot(M(idx3, 1), M(idx3, 4), 'go-');
plot(M(idx4, 1), M(idx4, 4), 'kx-');
legend('LLC with k-means codebook, size = 1024', 'LLC with k-means codebook, size = 2048', ...
    'LLC with optimized codebook, size = 1024', 'Baseline with k-means codebook, size = 1024');
title('Accuracy vs number of training images (100 training images per class)');
xlabel('Pyramid levels');
ylabel('Accuracy');