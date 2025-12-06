%% Problem 3: Discrete-Time Signal Operations
% This script demonstrates:
% (i) x[n] - original signal
% (ii) x[n-2] - time shift (delay by 2)
% (iii) x[n+1] - time shift (advance by 1)
% (iv) FIR filter: y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.2*x[n-2]
% (v) IIR filter: y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.5*y[n-1]
%
% Data: Mario "coin" sound pattern

clear; clc; close all;

%% ========== SECTION 1: DEFINE THE SIGNAL ==========
fprintf('=== Problem 3: Discrete-Time Signal Operations ===\n');
fprintf('Signal: Mario Coin Sound Pattern\n\n');

% Mario coin sound - the iconic rising arpeggio pattern
% Represents the two-note "bling!" sound (B5 -> E6 frequencies as amplitudes)
% Pattern: quick rise, sustain, decay

x = [0 2 5 8 10 12 10 8 5 3 1 0];  % Rising then falling - the coin "bling"
n = 0:length(x)-1;  % Sample indices

N = length(x);
fprintf('Signal x[n]: Mario Coin Sound\n');
fprintf('Length: %d samples\n', N);
fprintf('Non-zero elements: %d\n\n', sum(x ~= 0));

%% ========== SECTION 2: PLOT x[n] ==========
figure('Position', [50, 50, 1200, 800], 'Color', 'w');
sgtitle('Problem 3: Discrete-Time Signal Operations - Mario Coin Sound', ...
    'FontSize', 14, 'FontWeight', 'bold');

subplot(3,2,1);
stem(n, x, 'b', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 8);
xlabel('n', 'FontSize', 12);
ylabel('x[n]', 'FontSize', 12);
title('(i) Original Signal x[n] - Mario Coin "Bling!"', 'FontSize', 12);
grid on; box on;
xlim([-2 N+3]);
ylim([min(x)-1 max(x)+1]);

%% ========== SECTION 3: PLOT x[n-2] (Delay by 2) ==========
% x[n-2] means the signal is shifted RIGHT by 2 (delayed)
n_delayed = n + 2;  % New indices for delayed signal

subplot(3,2,2);
stem(n, x, 'b--', 'LineWidth', 1, 'MarkerSize', 6);  % Original (faded)
hold on;
stem(n_delayed, x, 'r', 'LineWidth', 2, 'MarkerFaceColor', 'r', 'MarkerSize', 8);
xlabel('n', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('(ii) x[n-2] - Delayed by 2 samples', 'FontSize', 12);
legend('x[n] (original)', 'x[n-2] (delayed)', 'Location', 'best');
grid on; box on;
xlim([-2 N+5]);
ylim([min(x)-1 max(x)+1]);

%% ========== SECTION 4: PLOT x[n+1] (Advance by 1) ==========
% x[n+1] means the signal is shifted LEFT by 1 (advanced)
n_advanced = n - 1;  % New indices for advanced signal

subplot(3,2,3);
stem(n, x, 'b--', 'LineWidth', 1, 'MarkerSize', 6);  % Original (faded)
hold on;
stem(n_advanced, x, 'g', 'LineWidth', 2, 'MarkerFaceColor', 'g', 'MarkerSize', 8);
xlabel('n', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('(iii) x[n+1] - Advanced by 1 sample', 'FontSize', 12);
legend('x[n] (original)', 'x[n+1] (advanced)', 'Location', 'best');
grid on; box on;
xlim([-3 N+2]);
ylim([min(x)-1 max(x)+1]);

%% ========== SECTION 5: FIR FILTER (Part iv) ==========
% y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.2*x[n-2]
% This is a 3-tap FIR (Finite Impulse Response) filter - weighted moving average

fprintf('(iv) FIR Filter: y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.2*x[n-2]\n');

% Pad signal with zeros for delayed terms
x_padded = [0 0 x];  % Two zeros at the beginning for x[n-1] and x[n-2]

y_fir = zeros(1, N);
for i = 1:N
    idx = i + 2;  % Offset due to padding
    y_fir(i) = 0.2*x_padded(idx) + 0.3*x_padded(idx-1) + 0.2*x_padded(idx-2);
end

subplot(3,2,4);
stem(n, x, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 7);
hold on;
stem(n, y_fir, 'm', 'LineWidth', 2, 'MarkerFaceColor', 'm', 'MarkerSize', 8);
xlabel('n', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('(iv) FIR Filter: y[n] = 0.2x[n] + 0.3x[n-1] + 0.2x[n-2]', 'FontSize', 11);
legend('x[n]', 'y[n] (FIR filtered)', 'Location', 'best');
grid on; box on;
xlim([-2 N+3]);

%% ========== SECTION 6: IIR FILTER (Part v) ==========
% y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.5*y[n-1], with y[-1] = 0
% This is an IIR (Infinite Impulse Response) filter - has feedback

fprintf('(v) IIR Filter: y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.5*y[n-1], y[-1]=0\n\n');

x_padded_iir = [0 x];  % One zero for x[n-1]
y_iir = zeros(1, N);
y_prev = 0;  % y[-1] = 0

for i = 1:N
    idx = i + 1;  % Offset due to padding
    y_iir(i) = 0.2*x_padded_iir(idx) + 0.3*x_padded_iir(idx-1) + 0.5*y_prev;
    y_prev = y_iir(i);  % Update for next iteration
end

subplot(3,2,5);
stem(n, x, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 7);
hold on;
stem(n, y_iir, 'c', 'LineWidth', 2, 'MarkerFaceColor', 'c', 'MarkerSize', 8);
xlabel('n', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('(v) IIR Filter: y[n] = 0.2x[n] + 0.3x[n-1] + 0.5y[n-1]', 'FontSize', 11);
legend('x[n]', 'y[n] (IIR filtered)', 'Location', 'best');
grid on; box on;
xlim([-2 N+3]);

%% ========== SECTION 7: ALL SIGNALS COMPARISON ==========
subplot(3,2,6);
stem(n, x, 'b', 'LineWidth', 1.5, 'MarkerSize', 7);
hold on;
stem(n, y_fir, 'm', 'LineWidth', 1.5, 'MarkerSize', 7);
stem(n, y_iir, 'c', 'LineWidth', 1.5, 'MarkerSize', 7);
xlabel('n', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('Comparison: Original vs FIR vs IIR', 'FontSize', 12);
legend('x[n] (original)', 'y[n] (FIR)', 'y[n] (IIR)', 'Location', 'best');
grid on; box on;
xlim([-2 N+3]);

saveas(gcf, 'p3_fig1_signals.png');
fprintf('Saved: p3_fig1_signals.png\n');

%% ========== SECTION 8: DFT COMPARISON (FIR) ==========
figure('Position', [100, 100, 1200, 500], 'Color', 'w');
sgtitle('DFT Comparison: Original x[n] vs FIR Filtered y[n]', ...
    'FontSize', 14, 'FontWeight', 'bold');

% Zero-pad for better frequency resolution
Nfft = 64;

% DFT of x[n]
X = fft(x, Nfft);
X_mag = abs(X(1:Nfft/2+1));
f_norm = (0:Nfft/2) / Nfft;  % Normalized frequency (0 to 0.5)

% DFT of y_fir[n]
Y_fir = fft(y_fir, Nfft);
Y_fir_mag = abs(Y_fir(1:Nfft/2+1));

subplot(2,2,1);
stem(f_norm, X_mag, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 5);
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 11);
ylabel('|X[k]|', 'FontSize', 12);
title('DFT of Original x[n]', 'FontSize', 12);
grid on; box on;

subplot(2,2,2);
stem(f_norm, Y_fir_mag, 'm', 'LineWidth', 1.5, 'MarkerFaceColor', 'm', 'MarkerSize', 5);
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 11);
ylabel('|Y[k]|', 'FontSize', 12);
title('DFT of FIR Filtered y[n]', 'FontSize', 12);
grid on; box on;

subplot(2,2,[3,4]);
plot(f_norm, X_mag, 'b-o', 'LineWidth', 2, 'MarkerSize', 5);
hold on;
plot(f_norm, Y_fir_mag, 'm-s', 'LineWidth', 2, 'MarkerSize', 5);
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 11);
ylabel('Magnitude', 'FontSize', 12);
title('DFT Comparison: x[n] vs FIR y[n] (Low-pass effect visible)', 'FontSize', 12);
legend('|X[k]| (Original)', '|Y[k]| (FIR Filtered)', 'Location', 'best');
grid on; box on;

% Add annotation
text(0.3, max(X_mag)*0.8, 'FIR filter attenuates high frequencies', ...
    'FontSize', 10, 'Color', 'm');

saveas(gcf, 'p3_fig2_dft_fir.png');
fprintf('Saved: p3_fig2_dft_fir.png\n');

%% ========== SECTION 9: DFT COMPARISON (IIR) ==========
figure('Position', [150, 150, 1200, 500], 'Color', 'w');
sgtitle('DFT Comparison: Original x[n] vs IIR Filtered y[n]', ...
    'FontSize', 14, 'FontWeight', 'bold');

% DFT of y_iir[n]
Y_iir = fft(y_iir, Nfft);
Y_iir_mag = abs(Y_iir(1:Nfft/2+1));

subplot(2,2,1);
stem(f_norm, X_mag, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'MarkerSize', 5);
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 11);
ylabel('|X[k]|', 'FontSize', 12);
title('DFT of Original x[n]', 'FontSize', 12);
grid on; box on;

subplot(2,2,2);
stem(f_norm, Y_iir_mag, 'c', 'LineWidth', 1.5, 'MarkerFaceColor', 'c', 'MarkerSize', 5);
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 11);
ylabel('|Y[k]|', 'FontSize', 12);
title('DFT of IIR Filtered y[n]', 'FontSize', 12);
grid on; box on;

subplot(2,2,[3,4]);
plot(f_norm, X_mag, 'b-o', 'LineWidth', 2, 'MarkerSize', 5);
hold on;
plot(f_norm, Y_iir_mag, 'c-s', 'LineWidth', 2, 'MarkerSize', 5);
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 11);
ylabel('Magnitude', 'FontSize', 12);
title('DFT Comparison: x[n] vs IIR y[n] (Stronger low-pass + resonance)', 'FontSize', 12);
legend('|X[k]| (Original)', '|Y[k]| (IIR Filtered)', 'Location', 'best');
grid on; box on;

% Add annotation
text(0.3, max(X_mag)*0.8, 'IIR filter: feedback creates different response', ...
    'FontSize', 10, 'Color', 'c');

saveas(gcf, 'p3_fig3_dft_iir.png');
fprintf('Saved: p3_fig3_dft_iir.png\n');

%% ========== SECTION 10: COMBINED DFT COMPARISON ==========
figure('Position', [200, 200, 1000, 400], 'Color', 'w');
plot(f_norm, X_mag, 'b-o', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Original x[n]');
hold on;
plot(f_norm, Y_fir_mag, 'm-s', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'FIR y[n]');
plot(f_norm, Y_iir_mag, 'c-^', 'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'IIR y[n]');
xlabel('Normalized Frequency (×π rad/sample)', 'FontSize', 12);
ylabel('Magnitude', 'FontSize', 12);
title('DFT Comparison: Original vs FIR vs IIR Filtered Signals', 'FontSize', 14);
legend('Location', 'best');
grid on; box on;

saveas(gcf, 'p3_fig4_dft_all.png');
fprintf('Saved: p3_fig4_dft_all.png\n');

%% ========== SUMMARY ==========
fprintf('\n========================================\n');
fprintf('      PROBLEM 3 ANALYSIS SUMMARY        \n');
fprintf('========================================\n');
fprintf('Signal: Mario Coin Sound Pattern\n');
fprintf('x[n] = [%s]\n', num2str(x));
fprintf('Length: %d samples\n\n', N);

fprintf('Time Shifts:\n');
fprintf('  x[n-2]: Delayed by 2 samples (shift right)\n');
fprintf('  x[n+1]: Advanced by 1 sample (shift left)\n\n');

fprintf('FIR Filter (Part iv):\n');
fprintf('  y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.2*x[n-2]\n');
fprintf('  Type: 3-tap moving average (low-pass)\n');
fprintf('  Effect: Smooths the signal, attenuates high frequencies\n\n');

fprintf('IIR Filter (Part v):\n');
fprintf('  y[n] = 0.2*x[n] + 0.3*x[n-1] + 0.5*y[n-1]\n');
fprintf('  Type: Recursive filter with feedback\n');
fprintf('  Effect: Stronger low-pass, adds "ringing" due to feedback\n\n');

fprintf('Figures saved:\n');
fprintf('  p3_fig1_signals.png - All signal operations\n');
fprintf('  p3_fig2_dft_fir.png - DFT comparison (FIR)\n');
fprintf('  p3_fig3_dft_iir.png - DFT comparison (IIR)\n');
fprintf('  p3_fig4_dft_all.png - Combined DFT comparison\n');
fprintf('========================================\n');
