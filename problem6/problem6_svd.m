%% Problem 6: SVD and Low-Rank Matrix Approximation
% Image Compression using Singular Value Decomposition
% Demonstrating rank-k approximations on the NITC logo
%
% SVD: A = U * S * V'
% Rank-k approximation: A_k = U(:,1:k) * S(1:k,1:k) * V(:,1:k)'

clear; clc; close all;

%% Load Image
fprintf('=== Problem 6: SVD Image Compression ===\n\n');

% Read the NITC logo
img = imread('nitc.png');

% Convert to grayscale if needed
if size(img, 3) == 3
    A = double(rgb2gray(img));
elseif size(img, 3) == 2
    % Grayscale with alpha channel - just take first channel
    A = double(img(:,:,1));
else
    A = double(img);
end

% Normalize to [0, 1]
A = A / max(A(:));

[m, n] = size(A);
fprintf('Image size: %d x %d pixels\n', m, n);
fprintf('Original storage: %d values\n', m*n);

%% Perform SVD
fprintf('\nComputing SVD...\n');
[U, S, V] = svd(A);

% Extract singular values
sigma = diag(S);
r = length(sigma);  % Full rank
fprintf('Matrix rank: %d\n', r);
fprintf('Largest singular value: %.4f\n', sigma(1));
fprintf('Smallest singular value: %.6f\n', sigma(end));

%% Analyze Singular Value Decay
% Cumulative energy captured
energy = cumsum(sigma.^2) / sum(sigma.^2);

% Find ranks for different energy thresholds
thresholds = [0.90, 0.95, 0.99, 0.999];
ranks_for_thresholds = zeros(size(thresholds));
for i = 1:length(thresholds)
    ranks_for_thresholds(i) = find(energy >= thresholds(i), 1);
    fprintf('Rank for %.1f%% energy: %d (%.1f%% compression)\n', ...
        thresholds(i)*100, ranks_for_thresholds(i), ...
        100*(1 - (ranks_for_thresholds(i)*(m+n+1))/(m*n)));
end

%% Compute Low-Rank Approximations
ranks = [1, 5, 10, 20, 50, 100, min(200, r)];
ranks = ranks(ranks <= r);  % Ensure valid ranks

A_approx = cell(length(ranks), 1);
errors = zeros(length(ranks), 1);
compression_ratios = zeros(length(ranks), 1);
psnr_values = zeros(length(ranks), 1);

fprintf('\nComputing rank-k approximations...\n');
for i = 1:length(ranks)
    k = ranks(i);
    
    % Rank-k approximation: A_k = U_k * S_k * V_k'
    A_approx{i} = U(:, 1:k) * S(1:k, 1:k) * V(:, 1:k)';
    
    % Frobenius norm error
    errors(i) = norm(A - A_approx{i}, 'fro') / norm(A, 'fro');
    
    % Compression ratio: original / compressed storage
    original_storage = m * n;
    compressed_storage = k * (m + n + 1);  % U_k, S_k, V_k
    compression_ratios(i) = original_storage / compressed_storage;
    
    % PSNR (Peak Signal-to-Noise Ratio)
    mse = mean((A(:) - A_approx{i}(:)).^2);
    if mse > 0
        psnr_values(i) = 10 * log10(1 / mse);
    else
        psnr_values(i) = Inf;
    end
    
    fprintf('Rank %3d: Error=%.4f, Compression=%.2fx, PSNR=%.2f dB\n', ...
        k, errors(i), compression_ratios(i), psnr_values(i));
end

%% Figure 1: Original Image and Singular Value Spectrum
figure('Position', [100, 100, 1200, 500]);

subplot(1, 3, 1);
imshow(A, [0, 1]);
title('Original NITC Logo');
xlabel(sprintf('%d x %d pixels', m, n));

subplot(1, 3, 2);
semilogy(sigma, 'b-', 'LineWidth', 1.5);
xlabel('Index k');
ylabel('\sigma_k (log scale)');
title('Singular Value Spectrum');
grid on;
xlim([1, length(sigma)]);

subplot(1, 3, 3);
plot(energy * 100, 'r-', 'LineWidth', 1.5);
hold on;
for i = 1:length(thresholds)
    yline(thresholds(i)*100, '--', sprintf('%.1f%%', thresholds(i)*100));
    plot(ranks_for_thresholds(i), thresholds(i)*100, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
end
xlabel('Rank k');
ylabel('Cumulative Energy (%)');
title('Energy Captured vs Rank');
grid on;
xlim([1, length(sigma)]);
ylim([0, 105]);

sgtitle('Problem 6: SVD Analysis of NITC Logo', 'FontSize', 14, 'FontWeight', 'bold');

print('p6_fig1_svd_analysis', '-dpng', '-r150');
fprintf('\nSaved: p6_fig1_svd_analysis.png\n');

%% Figure 2: Low-Rank Approximations Grid
figure('Position', [100, 100, 1400, 900]);

% Show original
subplot(2, 4, 1);
imshow(A, [0, 1]);
title(sprintf('Original\n%dx%d', m, n));

% Show approximations
display_ranks = [1, 5, 10, 20, 50, 100, min(200, r)];
display_ranks = display_ranks(display_ranks <= r);
for i = 1:min(7, length(display_ranks))
    subplot(2, 4, i+1);
    % Clip values to [0, 1] for display
    img_display = max(0, min(1, A_approx{i}));
    imshow(img_display, [0, 1]);
    title(sprintf('Rank %d\nError: %.2f%%', ranks(i), errors(i)*100));
end

sgtitle('Problem 6: Low-Rank Approximations of NITC Logo', 'FontSize', 14, 'FontWeight', 'bold');

print('p6_fig2_approximations', '-dpng', '-r150');
fprintf('Saved: p6_fig2_approximations.png\n');

%% Figure 3: Error and Compression Analysis
figure('Position', [100, 100, 1200, 500]);

subplot(1, 3, 1);
plot(ranks, errors * 100, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
xlabel('Rank k');
ylabel('Relative Error (%)');
title('Reconstruction Error vs Rank');
grid on;
set(gca, 'XScale', 'log');

subplot(1, 3, 2);
plot(ranks, compression_ratios, 'ro-', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('Rank k');
ylabel('Compression Ratio');
title('Compression Ratio vs Rank');
grid on;
set(gca, 'XScale', 'log');

subplot(1, 3, 3);
plot(compression_ratios, psnr_values, 'go-', 'LineWidth', 1.5, 'MarkerSize', 8, 'MarkerFaceColor', 'g');
xlabel('Compression Ratio');
ylabel('PSNR (dB)');
title('Quality vs Compression Trade-off');
grid on;

sgtitle('Problem 6: SVD Compression Performance', 'FontSize', 14, 'FontWeight', 'bold');

print('p6_fig3_compression', '-dpng', '-r150');
fprintf('Saved: p6_fig3_compression.png\n');

%% Figure 4: Visual Comparison at Different Quality Levels
figure('Position', [100, 100, 1400, 400]);

% Select 4 representative ranks
rep_ranks_idx = [1, 3, 5, length(ranks)];  % rank 1, 10, 50, 200
for i = 1:4
    idx = min(rep_ranks_idx(i), length(ranks));
    subplot(1, 4, i);
    img_display = max(0, min(1, A_approx{idx}));
    imshow(img_display, [0, 1]);
    k = ranks(idx);
    storage_pct = 100 * k * (m + n + 1) / (m * n);
    title(sprintf('Rank %d\nStorage: %.1f%%\nPSNR: %.1f dB', k, storage_pct, psnr_values(idx)));
end

sgtitle('Problem 6: Quality vs Storage Trade-off', 'FontSize', 14, 'FontWeight', 'bold');

print('p6_fig4_comparison', '-dpng', '-r150');
fprintf('Saved: p6_fig4_comparison.png\n');

%% Summary
fprintf('\n=== Summary ===\n');
fprintf('Image dimensions: %d x %d\n', m, n);
fprintf('Full rank: %d\n', r);
fprintf('\nOptimal trade-off points:\n');
for i = 1:length(ranks)
    if compression_ratios(i) > 2 && psnr_values(i) > 25
        fprintf('  Rank %d: %.1fx compression, %.1f dB PSNR, %.2f%% error\n', ...
            ranks(i), compression_ratios(i), psnr_values(i), errors(i)*100);
    end
end

fprintf('\n=== Mathematical Background ===\n');
fprintf('SVD Decomposition: A = U * Σ * V''\n');
fprintf('where U ∈ ℝ^{m×m}, Σ ∈ ℝ^{m×n}, V ∈ ℝ^{n×n}\n');
fprintf('Rank-k approximation: A_k = Σ_{i=1}^{k} σ_i * u_i * v_i''\n');
fprintf('Eckart-Young Theorem: A_k is the best rank-k approximation in Frobenius norm\n');

fprintf('\nDone!\n');
