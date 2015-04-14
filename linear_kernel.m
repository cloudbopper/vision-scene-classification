function [ K ] = linear_kernel( X )
% computes kernel matrix using linear kernel

training_size = size(X,1);
K = zeros(training_size, training_size);
for i=1:training_size
    K(i,i) = dot(X(i,:), X(i,:));
    for j=i+1:training_size
        K(i,j) = dot(X(i,:), X(j,:));
        K(j,i) = K(i,j);
    end
end

end

