%% DMD Analysis on Stock Market Data - Kutz-style Figures
% This code applies Dynamic Mode Decomposition to stock portfolio data
% Based on original DMD.m code from Prof Nathan Kutz
% Modified to produce figures similar to Kutz et al. (2015) paper

clear; clc; close all;

%% ========== SECTION 1: LOAD STOCK DATA ==========
fprintf('=== DMD Analysis on Stock Portfolio ===\n\n');

% Load price matrix (rows = time, columns = stocks)
data = readmatrix('stock_prices.csv');

% Load ticker names
fid = fopen('stock_tickers.txt', 'r');
tickers_str = fgetl(fid);
fclose(fid);
tickers = strsplit(tickers_str, ',');

[M, N] = size(data);  % M = time snapshots, N = number of stocks
fprintf('Number of stocks (N): %d\n', N);
fprintf('Number of time snapshots (M): %d\n', M);
fprintf('Stocks: %s\n\n', tickers_str);

% Time parameters (daily data over 1 month)
dt = 1;  % 1 day intervals
t = (0:M-1) * dt;  % time vector in days

%% ========== SECTION 2: NORMALIZE DATA ==========
% Normalize data for DMD (mean-center and scale)
data_mean = mean(data, 1);
data_std = std(data, 0, 1);
data_normalized = (data - data_mean) ./ data_std;

% Transpose so columns are time snapshots: X is N x M
X = data_normalized.';  % Now N (stocks) x M (time)

%% ========== SECTION 3: SVD ANALYSIS ==========
[u, s, v] = svd(X, 'econ');
singular_values = diag(s);
sv_normalized = singular_values / sum(singular_values);
energy = singular_values.^2 / sum(singular_values.^2) * 100;
cumulative_energy = cumsum(energy);

% Determine rank r (modes capturing 90% energy)
r = find(cumulative_energy >= 90, 1);
if isempty(r)
    r = min(N, M-1);
end
fprintf('Number of dominant modes (r) for 90%% energy: %d\n', r);

%% ========== SECTION 4: DMD ALGORITHM ==========
X1 = X(:, 1:end-1);
X2 = X(:, 2:end);

[U, S, V] = svd(X1, 'econ');
Ur = U(:, 1:r);
Sr = S(1:r, 1:r);
Vr = V(:, 1:r);

Atilde = Ur' * X2 * Vr / Sr;
[W, D] = eig(Atilde);
lambda = diag(D);

% DMD Modes (Phi)
Phi = X2 * Vr / Sr * W;

% Continuous-time eigenvalues (omega)
omega = log(lambda) / dt;

% Mode amplitudes from initial condition
x1 = X(:, 1);
b = Phi \ x1;

%% ========== SECTION 5: RECONSTRUCT DATA ==========
time_dynamics = zeros(r, length(t));
for iter = 1:length(t)
    time_dynamics(:, iter) = b .* exp(omega * t(iter));
end
X_dmd = Phi * time_dynamics;
data_reconstructed = (real(X_dmd).' .* data_std) + data_mean;

reconstruction_error = norm(data - data_reconstructed, 'fro') / norm(data, 'fro') * 100;
fprintf('Reconstruction error: %.2f%%\n\n', reconstruction_error);

%% ========== FIGURE 4.1 STYLE: DMD DECOMPOSITION OVERVIEW ==========
figure('Position', [50, 50, 1400, 900], 'Color', 'w');
sgtitle(sprintf('DMD Decomposition of RAM/Memory Portfolio (%d stocks, %d snapshots)', N, M), ...
    'FontSize', 14, 'FontWeight', 'bold');

% Define colors for modes (like in paper: red, blue, green, yellow, etc.)
mode_colors = [
    0.8 0.2 0.2;   % Red
    0.2 0.4 0.8;   % Blue
    0.2 0.7 0.3;   % Green
    0.9 0.7 0.1;   % Yellow/Gold
    0.6 0.2 0.6;   % Purple
    0.1 0.7 0.7;   % Cyan
];

% Top-left: Singular values (log scale) - like paper
subplot(3, 4, 1);
semilogy(1:length(sv_normalized), sv_normalized * 100, 'ko-', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
hold on;
for k = 1:min(r, size(mode_colors, 1))
    semilogy(k, sv_normalized(k) * 100, 'o', 'MarkerSize', 12, ...
        'MarkerFaceColor', mode_colors(k,:), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
end
xlabel('Mode k', 'FontSize', 11);
ylabel('\sigma_k / \Sigma\sigma_j (%)', 'FontSize', 11);
title('Singular Value Distribution', 'FontSize', 12);
grid on; box on;
xlim([0.5 N+0.5]);

% Middle-left: Eigenvalues in complex plane (omega)
subplot(3, 4, 5);
hold on;
% Plot stability boundary (imaginary axis)
xline(0, 'k--', 'LineWidth', 1.5);
% Plot all eigenvalues
for k = 1:r
    if k <= size(mode_colors, 1)
        scatter(real(omega(k)), imag(omega(k)), 150, mode_colors(k,:), 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    else
        scatter(real(omega(k)), imag(omega(k)), 150, [0.5 0.5 0.5], 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    end
end
xlabel('Re(\omega_k) - Growth Rate', 'FontSize', 11);
ylabel('Im(\omega_k) - Frequency', 'FontSize', 11);
title('DMD Eigenvalues \omega_k', 'FontSize', 12);
grid on; box on;
% Add text annotation
text(0.02, max(imag(omega))*0.8, 'Growth \rightarrow', 'FontSize', 10);

% Bottom-left: Eigenvalue magnitudes histogram
subplot(3, 4, 9);
histogram(abs(omega), 10, 'FaceColor', [0.3 0.5 0.7], 'EdgeColor', 'k');
xlabel('|\omega_k|', 'FontSize', 11);
ylabel('Count', 'FontSize', 11);
title('Eigenvalue Magnitude Distribution', 'FontSize', 12);
grid on; box on;

% Top-right panels: First 4 DMD modes (portfolio composition)
for k = 1:min(4, r)
    subplot(3, 4, k + 1 + floor((k-1)/2)*2);
    if k <= 2
        subplot(3, 4, k + 1);
    else
        subplot(3, 4, k + 3);
    end
    
    bar_data = real(Phi(:, k));
    b_handle = bar(bar_data);
    
    % Color bars based on sign
    if k <= size(mode_colors, 1)
        b_handle.FaceColor = mode_colors(k,:);
    end
    
    set(gca, 'XTick', 1:N, 'XTickLabel', tickers, 'FontSize', 8);
    xtickangle(45);
    ylabel('\psi_k(x)', 'FontSize', 11);
    title(sprintf('\\psi_{%d}(x): \\omega = %.3f%+.3fi', k, real(omega(k)), imag(omega(k))), ...
        'FontSize', 11, 'Color', mode_colors(min(k, size(mode_colors,1)),:));
    grid on; box on;
    xlim([0.5 N+0.5]);
end

% Bottom panels: Stock decomposition onto DMD modes (first 2 stocks)
for stock_idx = 1:2
    subplot(3, 4, 8 + stock_idx);
    
    % Project stock onto each mode
    stock_projection = zeros(1, r);
    for k = 1:r
        stock_projection(k) = abs(Phi(stock_idx, k) * b(k));
    end
    
    bar_handle = bar(stock_projection);
    hold on;
    
    % Highlight first 4 modes with colors
    for k = 1:min(4, r)
        bar(k, stock_projection(k), 'FaceColor', mode_colors(k,:), 'EdgeColor', 'k');
    end
    
    xlabel('Mode k', 'FontSize', 11);
    ylabel('|contribution|', 'FontSize', 11);
    title(sprintf('%s Decomposition on DMD Modes', tickers{stock_idx}), 'FontSize', 11);
    grid on; box on;
    xlim([0.5 r+0.5]);
end

% Save figure
saveas(gcf, 'fig1_dmd_decomposition.png');
fprintf('Saved: fig1_dmd_decomposition.png\n');

%% ========== FIGURE 4.2 STYLE: ANOTHER VIEW OF DECOMPOSITION ==========
figure('Position', [100, 100, 1200, 800], 'Color', 'w');
sgtitle('DMD Mode Analysis - RAM/Memory Sector', 'FontSize', 14, 'FontWeight', 'bold');

% Panel 1: All DMD modes as heatmap
subplot(2, 3, 1);
imagesc(real(Phi(:, 1:r)));
colorbar;
colormap(gca, 'jet');
set(gca, 'YTick', 1:N, 'YTickLabel', tickers, 'FontSize', 9);
xlabel('Mode k', 'FontSize', 11);
ylabel('Stock', 'FontSize', 11);
title('DMD Modes \Phi (Stock Composition)', 'FontSize', 12);

% Panel 2: Eigenvalues with unit circle (discrete time)
subplot(2, 3, 2);
theta_circle = linspace(0, 2*pi, 100);
plot(cos(theta_circle), sin(theta_circle), 'k--', 'LineWidth', 1.5);
hold on;
for k = 1:r
    if k <= size(mode_colors, 1)
        scatter(real(lambda(k)), imag(lambda(k)), 150, mode_colors(k,:), 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    else
        scatter(real(lambda(k)), imag(lambda(k)), 150, [0.5 0.5 0.5], 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    end
end
xlabel('Re(\lambda)', 'FontSize', 11);
ylabel('Im(\lambda)', 'FontSize', 11);
title('Discrete Eigenvalues \lambda_k', 'FontSize', 12);
axis equal; grid on; box on;
legend('Unit Circle', 'Location', 'best');

% Panel 3: Mode amplitudes
subplot(2, 3, 3);
bar_amp = bar(abs(b));
hold on;
for k = 1:min(r, size(mode_colors, 1))
    bar(k, abs(b(k)), 'FaceColor', mode_colors(k,:), 'EdgeColor', 'k');
end
xlabel('Mode k', 'FontSize', 11);
ylabel('|b_k|', 'FontSize', 11);
title('Mode Amplitudes', 'FontSize', 12);
grid on; box on;
xlim([0.5 r+0.5]);

% Panel 4: Time dynamics of modes
subplot(2, 3, 4);
hold on;
for k = 1:min(4, r)
    plot(t, real(time_dynamics(k, :)), '-', 'LineWidth', 2, 'Color', mode_colors(k,:));
end
xlabel('Time (days)', 'FontSize', 11);
ylabel('b_k exp(\omega_k t)', 'FontSize', 11);
title('Time Evolution of Modes', 'FontSize', 12);
legend(arrayfun(@(x) sprintf('Mode %d', x), 1:min(4,r), 'UniformOutput', false), ...
    'Location', 'best');
grid on; box on;

% Panel 5: Growth rates
subplot(2, 3, 5);
growth_rates = real(omega);
bar_gr = barh(growth_rates);
hold on;
for k = 1:min(r, size(mode_colors, 1))
    barh(k, growth_rates(k), 'FaceColor', mode_colors(k,:), 'EdgeColor', 'k');
end
xline(0, 'k--', 'LineWidth', 1.5);
ylabel('Mode k', 'FontSize', 11);
xlabel('Growth Rate Re(\omega_k)', 'FontSize', 11);
title('Mode Growth/Decay Rates', 'FontSize', 12);
grid on; box on;
ylim([0.5 r+0.5]);

% Panel 6: Frequencies
subplot(2, 3, 6);
frequencies = imag(omega);
bar_fr = barh(frequencies);
hold on;
for k = 1:min(r, size(mode_colors, 1))
    barh(k, frequencies(k), 'FaceColor', mode_colors(k,:), 'EdgeColor', 'k');
end
xline(0, 'k--', 'LineWidth', 1.5);
ylabel('Mode k', 'FontSize', 11);
xlabel('Frequency Im(\omega_k) (rad/day)', 'FontSize', 11);
title('Mode Oscillation Frequencies', 'FontSize', 12);
grid on; box on;
ylim([0.5 r+0.5]);

saveas(gcf, 'fig2_mode_analysis.png');
fprintf('Saved: fig2_mode_analysis.png\n');

%% ========== FIGURE 4.3 STYLE: EIGENVALUE DISTRIBUTION ==========
figure('Position', [150, 150, 1000, 400], 'Color', 'w');
sgtitle('DMD Eigenvalue Distribution - RAM/Memory Sector', 'FontSize', 14, 'FontWeight', 'bold');

% Left: Eigenvalue scatter in complex plane
subplot(1, 2, 1);
hold on;
xline(0, 'k--', 'LineWidth', 2);
scatter(real(omega), imag(omega), 200, abs(b), 'filled', ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
colorbar;
colormap(gca, 'hot');
xlabel('Re(\omega_k) - Growth Rate', 'FontSize', 12);
ylabel('Im(\omega_k) - Frequency', 'FontSize', 12);
title('\omega_k Distribution (color = amplitude)', 'FontSize', 12);
grid on; box on;

% Add quadrant labels
xl = xlim; yl = ylim;
text(xl(2)*0.7, yl(2)*0.8, 'Growing', 'FontSize', 10, 'Color', 'g', 'FontWeight', 'bold');
text(xl(1)*0.7, yl(2)*0.8, 'Decaying', 'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');

% Right: Histogram of growth rates
subplot(1, 2, 2);
histogram(real(omega), 8, 'FaceColor', [0.2 0.5 0.7], 'EdgeColor', 'k', 'LineWidth', 1.5);
hold on;
xline(0, 'r--', 'LineWidth', 2);
xlabel('Re(\omega_k)', 'FontSize', 12);
ylabel('Count', 'FontSize', 12);
title('Growth Rate Distribution', 'FontSize', 12);
grid on; box on;

saveas(gcf, 'fig3_eigenvalue_distribution.png');
fprintf('Saved: fig3_eigenvalue_distribution.png\n');

%% ========== FIGURE 4.4 STYLE: ORIGINAL VS RECONSTRUCTED ==========
figure('Position', [200, 200, 1400, 600], 'Color', 'w');
sgtitle('Original Data vs DMD Reconstruction', 'FontSize', 14, 'FontWeight', 'bold');

% Plot all stocks
num_plots = min(N, 10);
for k = 1:num_plots
    subplot(2, 5, k);
    plot(t, data(:, k), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(t, data_reconstructed(:, k), 'r--', 'LineWidth', 1.5);
    xlabel('Time (days)', 'FontSize', 9);
    ylabel('Price ($)', 'FontSize', 9);
    title(tickers{k}, 'FontSize', 11, 'FontWeight', 'bold');
    if k == 1
        legend('Original', 'DMD', 'Location', 'best', 'FontSize', 8);
    end
    grid on; box on;
end

saveas(gcf, 'fig4_reconstruction.png');
fprintf('Saved: fig4_reconstruction.png\n');

%% ========== FIGURE 4.5 STYLE: PORTFOLIO PERFORMANCE SUMMARY ==========
figure('Position', [250, 250, 1200, 800], 'Color', 'w');
sgtitle('DMD Portfolio Analysis Summary', 'FontSize', 14, 'FontWeight', 'bold');

% Panel 1: Normalized price evolution
subplot(2, 2, 1);
plot(t, data_normalized, 'LineWidth', 1.5);
xlabel('Time (days)', 'FontSize', 11);
ylabel('Normalized Price', 'FontSize', 11);
title('Normalized Stock Prices', 'FontSize', 12);
legend(tickers, 'Location', 'bestoutside', 'FontSize', 8);
grid on; box on;

% Panel 2: Cumulative energy by modes
subplot(2, 2, 2);
bar(energy(1:min(r+2, N)), 'FaceColor', [0.3 0.6 0.8], 'EdgeColor', 'k');
hold on;
plot(cumulative_energy(1:min(r+2, N)), 'ro-', 'LineWidth', 2, 'MarkerFaceColor', 'r');
yline(90, 'g--', '90%', 'LineWidth', 2);
xlabel('Mode k', 'FontSize', 11);
ylabel('Energy (%)', 'FontSize', 11);
title('Energy Distribution by Mode', 'FontSize', 12);
legend('Individual', 'Cumulative', 'Location', 'east');
grid on; box on;

% Panel 3: Mode interpretation table (as text)
subplot(2, 2, 3);
axis off;
text(0.1, 0.95, 'DMD Mode Interpretation:', 'FontSize', 12, 'FontWeight', 'bold');
y_pos = 0.85;
for k = 1:r
    if real(omega(k)) > 0.01
        trend = 'GROWING';
        trend_color = 'g';
    elseif real(omega(k)) < -0.01
        trend = 'DECAYING';
        trend_color = 'r';
    else
        trend = 'STABLE';
        trend_color = 'b';
    end
    
    if abs(imag(omega(k))) > 0.01
        period = 2*pi / abs(imag(omega(k)));
        osc_str = sprintf('Period: %.1f days', period);
    else
        osc_str = 'Non-oscillatory';
    end
    
    mode_str = sprintf('Mode %d: \\omega = %.3f%+.3fi  |  %s  |  %s  |  |b|=%.2f', ...
        k, real(omega(k)), imag(omega(k)), trend, osc_str, abs(b(k)));
    text(0.1, y_pos, mode_str, 'FontSize', 10, 'Color', trend_color);
    y_pos = y_pos - 0.12;
end

text(0.1, 0.1, sprintf('Reconstruction Error: %.2f%%', reconstruction_error), ...
    'FontSize', 11, 'FontWeight', 'bold');

% Panel 4: Reconstruction error per stock
subplot(2, 2, 4);
error_per_stock = sqrt(sum((data - data_reconstructed).^2, 1)) ./ sqrt(sum(data.^2, 1)) * 100;
bar(error_per_stock, 'FaceColor', [0.8 0.4 0.4], 'EdgeColor', 'k');
set(gca, 'XTick', 1:N, 'XTickLabel', tickers, 'FontSize', 9);
xtickangle(45);
xlabel('Stock', 'FontSize', 11);
ylabel('Relative Error (%)', 'FontSize', 11);
title('Reconstruction Error by Stock', 'FontSize', 12);
grid on; box on;

saveas(gcf, 'fig5_summary.png');
fprintf('Saved: fig5_summary.png\n');

%% ========== PRINT SUMMARY ==========
fprintf('\n========================================\n');
fprintf('          DMD ANALYSIS SUMMARY          \n');
fprintf('========================================\n');
fprintf('Portfolio: RAM/Memory Semiconductor Sector\n');
fprintf('Stocks: %s\n', tickers_str);
fprintf('Data: %d stocks, %d time snapshots (hourly)\n', N, M);
fprintf('Dominant modes used: %d (90%% energy threshold)\n', r);
fprintf('Overall reconstruction error: %.2f%%\n', reconstruction_error);
fprintf('\nMode Analysis:\n');
for k = 1:r
    fprintf('  Mode %d: omega = %+.4f %+.4fi', k, real(omega(k)), imag(omega(k)));
    if real(omega(k)) > 0.01
        fprintf(' [GROWING]');
    elseif real(omega(k)) < -0.01
        fprintf(' [DECAYING]');
    else
        fprintf(' [STABLE]');
    end
    fprintf('\n');
end
fprintf('\nFigures saved:\n');
fprintf('  fig1_dmd_decomposition.png - Full DMD decomposition (Fig 4.1 style)\n');
fprintf('  fig2_mode_analysis.png - Mode analysis details (Fig 4.2 style)\n');
fprintf('  fig3_eigenvalue_distribution.png - Eigenvalue distribution (Fig 4.3 style)\n');
fprintf('  fig4_reconstruction.png - Original vs reconstructed (Fig 4.4 style)\n');
fprintf('  fig5_summary.png - Portfolio summary (Fig 4.5 style)\n');
fprintf('========================================\n');
