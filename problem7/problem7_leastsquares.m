%% Problem 7: Least Squares Regression
% Polynomial Curve Fitting on INR/USD Exchange Rate Data
% Demonstrating underfitting, good fit, and overfitting
%
% Least Squares: minimize ||Ax - b||_2
% For polynomial fitting: A is the Vandermonde matrix

clear; clc; close all;

%% Load Data
fprintf('=== Problem 7: Least Squares Regression ===\n\n');

% Read INR/USD exchange rate data
data = readtable('inr_usd_data.csv');

% Extract data
dates = data.date;
t = data.day;  % Day number (0, 1, 2, ...)
y = data.rate;  % Exchange rate (INR per USD)

n = length(t);
fprintf('Number of data points: %d\n', n);
fprintf('Date range: %s to %s\n', datestr(dates(1)), datestr(dates(end)));
fprintf('Exchange rate range: %.4f to %.4f INR/USD\n', min(y), max(y));

%% Normalize data for numerical stability
t_mean = mean(t);
t_std = std(t);
t_norm = (t - t_mean) / t_std;

y_mean = mean(y);
y_std = std(y);

%% Fit Polynomials of Different Degrees
degrees = [1, 2, 3, 5, 10, 20];  % Linear to high-degree
num_fits = length(degrees);

% Store results
coeffs = cell(num_fits, 1);
y_fit = cell(num_fits, 1);
residuals = cell(num_fits, 1);
sse = zeros(num_fits, 1);  % Sum of squared errors
mse = zeros(num_fits, 1);  % Mean squared error
r_squared = zeros(num_fits, 1);  % R^2 coefficient
adj_r_squared = zeros(num_fits, 1);  % Adjusted R^2

fprintf('\nFitting polynomial models...\n');
fprintf('%-10s %-12s %-12s %-12s %-12s\n', 'Degree', 'MSE', 'R^2', 'Adj R^2', 'Status');
fprintf('%s\n', repmat('-', 1, 60));

ss_tot = sum((y - mean(y)).^2);  % Total sum of squares

for i = 1:num_fits
    d = degrees(i);
    
    % Build Vandermonde matrix A (using normalized t for stability)
    A = zeros(n, d+1);
    for j = 0:d
        A(:, j+1) = t_norm.^j;
    end
    
    % Solve least squares: A*c = y => c = (A'A)^{-1}A'y = A\y
    coeffs{i} = A \ y;
    
    % Compute fitted values
    y_fit{i} = A * coeffs{i};
    
    % Compute residuals and error metrics
    residuals{i} = y - y_fit{i};
    sse(i) = sum(residuals{i}.^2);
    mse(i) = sse(i) / n;
    
    % R^2 = 1 - SS_res / SS_tot
    r_squared(i) = 1 - sse(i) / ss_tot;
    
    % Adjusted R^2 = 1 - (1-R^2)(n-1)/(n-p-1) where p = degree
    adj_r_squared(i) = 1 - (1 - r_squared(i)) * (n - 1) / (n - d - 1);
    
    % Determine fit status
    if d == 1
        status = 'Underfit';
    elseif d <= 3
        status = 'Good fit';
    elseif d <= 10
        status = 'Risk overfit';
    else
        status = 'Overfit';
    end
    
    fprintf('%-10d %-12.6f %-12.4f %-12.4f %-12s\n', d, mse(i), r_squared(i), adj_r_squared(i), status);
end

%% Cross-Validation: Train/Test Split
fprintf('\n=== Cross-Validation (80/20 Split) ===\n');

% Random split
rng(42);  % For reproducibility
idx = randperm(n);
n_train = round(0.8 * n);
train_idx = idx(1:n_train);
test_idx = idx(n_train+1:end);

t_train = t_norm(train_idx);
y_train = y(train_idx);
t_test = t_norm(test_idx);
y_test = y(test_idx);

train_mse = zeros(num_fits, 1);
test_mse = zeros(num_fits, 1);

fprintf('%-10s %-12s %-12s %-12s\n', 'Degree', 'Train MSE', 'Test MSE', 'Overfit?');
fprintf('%s\n', repmat('-', 1, 50));

for i = 1:num_fits
    d = degrees(i);
    
    % Build training Vandermonde matrix
    A_train = zeros(n_train, d+1);
    for j = 0:d
        A_train(:, j+1) = t_train.^j;
    end
    
    % Fit on training data
    c = A_train \ y_train;
    
    % Predict on training set
    y_train_pred = A_train * c;
    train_mse(i) = mean((y_train - y_train_pred).^2);
    
    % Predict on test set
    A_test = zeros(length(t_test), d+1);
    for j = 0:d
        A_test(:, j+1) = t_test.^j;
    end
    y_test_pred = A_test * c;
    test_mse(i) = mean((y_test - y_test_pred).^2);
    
    overfit = '';
    if test_mse(i) > 2 * train_mse(i)
        overfit = 'Yes';
    end
    
    fprintf('%-10d %-12.6f %-12.6f %-12s\n', d, train_mse(i), test_mse(i), overfit);
end

%% Figure 1: Raw Data and Polynomial Fits
figure('Position', [100, 100, 1400, 600]);

subplot(1, 2, 1);
plot(t, y, 'k.', 'MarkerSize', 4);
hold on;
colors = lines(num_fits);
for i = 1:min(4, num_fits)  % Show first 4 fits
    plot(t, y_fit{i}, 'Color', colors(i,:), 'LineWidth', 1.5);
end
xlabel('Day');
ylabel('INR/USD Exchange Rate');
title('Polynomial Fits: Degrees 1, 2, 3, 5');
legend(['Data', arrayfun(@(x) sprintf('Degree %d', x), degrees(1:4), 'UniformOutput', false)], ...
    'Location', 'best');
grid on;

subplot(1, 2, 2);
plot(t, y, 'k.', 'MarkerSize', 4);
hold on;
for i = 4:num_fits  % Show higher degree fits
    plot(t, y_fit{i}, 'Color', colors(i,:), 'LineWidth', 1.5);
end
xlabel('Day');
ylabel('INR/USD Exchange Rate');
title('Polynomial Fits: Higher Degrees (Risk of Overfitting)');
legend(['Data', arrayfun(@(x) sprintf('Degree %d', x), degrees(4:end), 'UniformOutput', false)], ...
    'Location', 'best');
grid on;

sgtitle('Problem 7: INR/USD Exchange Rate - Polynomial Regression', 'FontSize', 14, 'FontWeight', 'bold');

print('p7_fig1_polynomial_fits', '-dpng', '-r150');
fprintf('\nSaved: p7_fig1_polynomial_fits.png\n');

%% Figure 2: Residual Analysis
figure('Position', [100, 100, 1400, 600]);

for i = 1:4
    subplot(2, 2, i);
    plot(t, residuals{i}, 'b.', 'MarkerSize', 4);
    hold on;
    yline(0, 'r--', 'LineWidth', 1);
    xlabel('Day');
    ylabel('Residual');
    title(sprintf('Degree %d: MSE = %.4f, R^2 = %.4f', degrees(i), mse(i), r_squared(i)));
    grid on;
end

sgtitle('Problem 7: Residual Analysis', 'FontSize', 14, 'FontWeight', 'bold');

print('p7_fig2_residuals', '-dpng', '-r150');
fprintf('Saved: p7_fig2_residuals.png\n');

%% Figure 3: Model Selection Metrics
figure('Position', [100, 100, 1200, 500]);

subplot(1, 3, 1);
bar(categorical(degrees), r_squared, 'FaceColor', [0.2, 0.6, 0.8]);
xlabel('Polynomial Degree');
ylabel('R^2');
title('Coefficient of Determination');
ylim([0, 1]);
grid on;

subplot(1, 3, 2);
bar(categorical(degrees), adj_r_squared, 'FaceColor', [0.8, 0.4, 0.2]);
xlabel('Polynomial Degree');
ylabel('Adjusted R^2');
title('Adjusted R^2 (Penalizes Complexity)');
ylim([0, 1]);
grid on;

subplot(1, 3, 3);
semilogy(degrees, mse, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 10, 'MarkerFaceColor', 'b');
xlabel('Polynomial Degree');
ylabel('MSE (log scale)');
title('Mean Squared Error');
grid on;

sgtitle('Problem 7: Model Selection Metrics', 'FontSize', 14, 'FontWeight', 'bold');

print('p7_fig3_metrics', '-dpng', '-r150');
fprintf('Saved: p7_fig3_metrics.png\n');

%% Figure 4: Train vs Test Error (Bias-Variance Tradeoff)
figure('Position', [100, 100, 800, 500]);

semilogy(degrees, train_mse, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 10, 'MarkerFaceColor', 'b');
hold on;
semilogy(degrees, test_mse, 'r-s', 'LineWidth', 1.5, 'MarkerSize', 10, 'MarkerFaceColor', 'r');
xlabel('Polynomial Degree');
ylabel('MSE (log scale)');
title('Bias-Variance Tradeoff: Train vs Test Error');
legend('Training Error', 'Test Error', 'Location', 'best');
grid on;

% Mark optimal degree (lowest test error)
[~, opt_idx] = min(test_mse);
plot(degrees(opt_idx), test_mse(opt_idx), 'g*', 'MarkerSize', 20, 'LineWidth', 2);
text(degrees(opt_idx), test_mse(opt_idx)*1.5, sprintf('Optimal: Degree %d', degrees(opt_idx)), ...
    'FontSize', 12, 'Color', 'g');

sgtitle('Problem 7: Cross-Validation Analysis', 'FontSize', 14, 'FontWeight', 'bold');

print('p7_fig4_bias_variance', '-dpng', '-r150');
fprintf('Saved: p7_fig4_bias_variance.png\n');

%% Figure 5: Best Fit Visualization
figure('Position', [100, 100, 1000, 600]);

% Find best model based on adjusted R^2
[~, best_idx] = max(adj_r_squared);
best_degree = degrees(best_idx);

plot(t, y, 'k.', 'MarkerSize', 6);
hold on;
plot(t, y_fit{best_idx}, 'r-', 'LineWidth', 2);

% Add confidence band (approximate using residual std)
res_std = std(residuals{best_idx});
plot(t, y_fit{best_idx} + 2*res_std, 'r--', 'LineWidth', 1);
plot(t, y_fit{best_idx} - 2*res_std, 'r--', 'LineWidth', 1);

xlabel('Day');
ylabel('INR/USD Exchange Rate');
title(sprintf('Best Fit: Degree %d Polynomial (R^2 = %.4f, Adj R^2 = %.4f)', ...
    best_degree, r_squared(best_idx), adj_r_squared(best_idx)));
legend('Data', 'Polynomial fit', '±2σ band', 'Location', 'best');
grid on;

% Add date labels on x-axis (approximate)
xticks(linspace(0, max(t), 5));
date_labels = dates(round(linspace(1, n, 5)));
xticklabels(datestr(date_labels, 'mmm-yy'));

print('p7_fig5_best_fit', '-dpng', '-r150');
fprintf('Saved: p7_fig5_best_fit.png\n');

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Data: INR/USD Exchange Rate (1 year, %d trading days)\n', n);
fprintf('Date range: %s to %s\n', datestr(dates(1)), datestr(dates(end)));
fprintf('Rate range: %.2f to %.2f INR/USD\n', min(y), max(y));
fprintf('\nBest model (by Adjusted R^2): Degree %d polynomial\n', best_degree);
fprintf('  R^2 = %.4f\n', r_squared(best_idx));
fprintf('  Adjusted R^2 = %.4f\n', adj_r_squared(best_idx));
fprintf('  MSE = %.6f\n', mse(best_idx));

fprintf('\n=== Mathematical Background ===\n');
fprintf('Least Squares: min_x ||Ax - b||_2\n');
fprintf('Normal Equations: A''Ax = A''b\n');
fprintf('Solution: x = (A''A)^{-1}A''b = A\\b (in MATLAB)\n');
fprintf('Vandermonde matrix A: A_{ij} = t_i^{j-1}\n');

fprintf('\nDone!\n');
