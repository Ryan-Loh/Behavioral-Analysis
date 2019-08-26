% Plot a circle.
angles = linspace(0, 2*pi, 720); % 720 is the total number of points
radius = 20;
xCenter = 50;
yCenter = 40;
x = radius * cos(angles) + xCenter; 
y = radius * sin(angles) + yCenter;
% Plot circle.
plot(x, y, 'b-', 'LineWidth', 2);
% Plot center.
hold on;
plot(xCenter, yCenter, 'k+', 'LineWidth', 2, 'MarkerSize', 16);
grid on;
axis equal;
xlabel('X', 'FontSize', 16);
ylabel('Y', 'FontSize', 16);
% Now get random locations along the circle.
s1 = 5; % Number of random points to get.
randomIndexes = randperm(length(angles), s1)
xRandom = x(randomIndexes);
yRandom = y(randomIndexes);
plot(xRandom, yRandom, 'ro', 'LineWidth', 2, 'MarkerSize', 16);