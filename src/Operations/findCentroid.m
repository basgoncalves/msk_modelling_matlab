function [xc, yc] = findCentroid(M)


if nargin < 1
    M = createRandomMatrix;
    [xc, yc] = plotCentroid(M);
    set(gcf,'Position',[354   571   560   420])

    M2 = createRandomMatrix_irregular;
    [xc, yc] = plotCentroid(M2);
    set(gcf,'Position',[941   569   560   420])
else

     [xc, yc] = plotCentroid(M);
end

function M = createRandomMatrix()

% Create a matrix with NaN values
matrixSize = 30;
M = NaN(matrixSize);

% Define the range for the random numbers in the middle
minValue = 1;
maxValue = 100;

% Generate random numbers in the middle of the matrix
middleStart = ceil(matrixSize/4);
middleEnd = matrixSize - middleStart + 1;
M(middleStart:middleEnd, middleStart:middleEnd) = randi([minValue, maxValue], middleEnd-middleStart+1, middleEnd-middleStart+1);

function M = createRandomMatrix_irregular()

% Define the size of the matrix
matrixSize = 30;

% Create a matrix with NaN values
M = NaN(matrixSize);

% Generate random irregular shape
middleShape = zeros(matrixSize/3);
numPoints = randi([25, 50]);
for i = 1:numPoints
    x = randi([1, matrixSize/3]);
    y = randi([1, matrixSize/3]);
    middleShape(x, y) = 1;
end

% Assign the irregular shape to the middle of the matrix
M(matrixSize/3+1:2*matrixSize/3, matrixSize/3+1:2*matrixSize/3) = middleShape;

function [xc, yc] = plotCentroid(M)

[row, col] = find(~isnan(M));
xc = mean(col);
yc = mean(row);

figure; 
imagesc(M);
hold on
plot(xc,yc, '.r', 'MarkerSize',20)

% END