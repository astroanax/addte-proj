%% Problem 2: DFT Analysis and Filtering of LIGO Gravitational Wave Data
% This script demonstrates:
% (i) DFT (Frequency-Amplitude plot)
% (ii) Low-pass, High-pass, and Band-pass filtering
% Data: GW150914 - First gravitational wave detection

clear; clc; close all;

%% ========== SECTION 1: LOAD DATA ==========
fprintf('=== Problem 2: DFT and Filtering Analysis ===\n');
fprintf('Data: LIGO GW150914 Gravitational Wave Signal\n\n');

% Load strain data
strain = readmatrix('ligo_strain.csv');

% Read metadata
fid = fopen('ligo_metadata.txt', 'r');
metadata = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

% Parse sample rate from metadata
fs = 4096;  % Default
for i = 1:length(metadata{1})
    line = metadata{1}{i};
    if startsWith(line, 'sample_rate=')
        fs = str2double(extractAfter(line, 'sample_rate='));
    end
end

N = length(strain);
duration = N / fs;
t = (0:N-1) / fs;  % Time vector in seconds

fprintf('Sample rate: %d Hz\n', fs);
fprintf('Duration: %.3f seconds\n', duration);
fprintf('Number of samples: %d\n\n', N);

%% ========== SECTION 2: TIME DOMAIN PLOT ==========
figure('Position', [50, 50, 1200, 400], 'Color', 'w');
plot(t, strain, 'b-', 'LineWidth', 0.5);
xlabel('Time (seconds)', 'FontSize', 12);
ylabel('Strain', 'FontSize', 12);
title('LIGO GW150914 Gravitational Wave Signal - Time Domain', 'FontSize', 14);
grid on; box on;
xlim([0 duration]);

saveas(gcf, 'p2_fig1_time_domain.png');
fprintf('Saved: p2_fig1_time_domain.png\n');

%% ========== SECTION 3: DFT ANALYSIS ==========
% Compute DFT using FFT
Y = fft(strain);

% Single-sided amplitude spectrum
P2 = abs(Y / N);           % Two-sided spectrum
P1 = P2(1:N/2+1);          % Single-sided spectrum
P1(2:end-1) = 2 * P1(2:end-1);  % Double the non-DC/Nyquist components

% Frequency vector
f = fs * (0:(N/2)) / N;

% Find dominant frequencies (simple peak detection without toolbox)
% Find local maxima
threshold = max(P1) * 0.1;
peaks = [];
locs = [];
for i = 2:length(P1)-1
    if P1(i) > P1(i-1) && P1(i) > P1(i+1) && P1(i) > threshold
        peaks = [peaks; P1(i)];
        locs = [locs; i];
    end
end
dominant_freqs = f(locs);

% Sort by amplitude and take top 5
[peaks_sorted, sort_idx] = sort(peaks, 'descend');
dominant_freqs_sorted = dominant_freqs(sort_idx);

fprintf('Dominant frequencies detected:\n');
for i = 1:min(5, length(dominant_freqs_sorted))
    fprintf('  %.1f Hz (amplitude: %.4f)\n', dominant_freqs_sorted(i), peaks_sorted(i));
end
fprintf('\n');

% Plot DFT
figure('Position', [100, 100, 1200, 500], 'Color', 'w');

subplot(2,1,1);
plot(f, P1, 'b-', 'LineWidth', 1);
hold on;
if ~isempty(peaks_sorted)
    plot(dominant_freqs_sorted(1:min(5,end)), peaks_sorted(1:min(5,end)), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
end
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('DFT: Frequency-Amplitude Spectrum (Linear Scale)', 'FontSize', 14);
xlim([0 fs/2]);
grid on; box on;
legend('Spectrum', 'Dominant Peaks', 'Location', 'best');

subplot(2,1,2);
plot(f, 20*log10(P1 + eps), 'b-', 'LineWidth', 1);
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Amplitude (dB)', 'FontSize', 12);
title('DFT: Frequency-Amplitude Spectrum (Log Scale - dB)', 'FontSize', 14);
xlim([0 fs/2]);
grid on; box on;

saveas(gcf, 'p2_fig2_dft_spectrum.png');
fprintf('Saved: p2_fig2_dft_spectrum.png\n');

%% ========== SECTION 4: FILTER DESIGN (Frequency Domain / Ideal Filters) ==========
% Define filter cutoff frequencies
% GW150914 chirp is roughly 35-250 Hz, we'll design filters around this

f_low = 50;    % Low-pass cutoff (Hz) - passes only low frequencies
f_high = 100;  % High-pass cutoff (Hz) - passes only high frequencies
f_band = [50 200];  % Band-pass range (Hz) - passes the chirp frequencies

fprintf('Filter Parameters:\n');
fprintf('  Low-pass filter: cutoff = %d Hz\n', f_low);
fprintf('  High-pass filter: cutoff = %d Hz\n', f_high);
fprintf('  Band-pass filter: passband = [%d, %d] Hz\n\n', f_band(1), f_band(2));

% We'll implement filtering in the frequency domain (ideal filters)
% This is conceptually clearer and doesn't require toolboxes

%% ========== SECTION 5: APPLY FILTERS (Frequency Domain Implementation) ==========
% Frequency domain filtering: multiply FFT by filter transfer function

% Full frequency vector for FFT (including negative frequencies)
f_full = (0:N-1) * fs / N;
f_full(f_full > fs/2) = f_full(f_full > fs/2) - fs;  % Wrap negative frequencies

% Create ideal filter transfer functions (smooth transition using Gaussian roll-off)
% This avoids sharp cutoffs that cause ringing

% Transition bandwidth for smooth roll-off
trans_bw = 10;  % Hz

% Low-pass filter: H(f) = 1 for |f| < f_low, 0 otherwise
H_low = exp(-((abs(f_full) - f_low).^2) ./ (2 * trans_bw^2));
H_low(abs(f_full) <= f_low) = 1;
H_low(abs(f_full) > f_low + 3*trans_bw) = 0;

% High-pass filter: H(f) = 0 for |f| < f_high, 1 otherwise
H_high = 1 - exp(-((abs(f_full) - f_high).^2) ./ (2 * trans_bw^2));
H_high(abs(f_full) >= f_high) = 1;
H_high(abs(f_full) < f_high - 3*trans_bw) = 0;

% Band-pass filter: combination of low-pass and high-pass
H_band_low = exp(-((abs(f_full) - f_band(2)).^2) ./ (2 * trans_bw^2));
H_band_low(abs(f_full) <= f_band(2)) = 1;
H_band_low(abs(f_full) > f_band(2) + 3*trans_bw) = 0;

H_band_high = 1 - exp(-((abs(f_full) - f_band(1)).^2) ./ (2 * trans_bw^2));
H_band_high(abs(f_full) >= f_band(1)) = 1;
H_band_high(abs(f_full) < f_band(1) - 3*trans_bw) = 0;

H_band = H_band_low .* H_band_high;

% Apply filters in frequency domain
Y = fft(strain);
strain_lowpass = real(ifft(Y .* H_low'));
strain_highpass = real(ifft(Y .* H_high'));
strain_bandpass = real(ifft(Y .* H_band'));

%% ========== SECTION 6: TIME DOMAIN COMPARISON ==========
figure('Position', [150, 150, 1400, 800], 'Color', 'w');
sgtitle('Filtering Results - Time Domain Comparison', 'FontSize', 14, 'FontWeight', 'bold');

subplot(4,1,1);
plot(t, strain, 'b-', 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('Strain');
title('Original Signal', 'FontSize', 12);
grid on; xlim([0 duration]);

subplot(4,1,2);
plot(t, strain_lowpass, 'Color', [0.8 0.2 0.2], 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('Strain');
title(sprintf('Low-Pass Filtered (f_c = %d Hz) - Removes high-frequency components', f_low), 'FontSize', 12);
grid on; xlim([0 duration]);

subplot(4,1,3);
plot(t, strain_highpass, 'Color', [0.2 0.6 0.2], 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('Strain');
title(sprintf('High-Pass Filtered (f_c = %d Hz) - Removes low-frequency components', f_high), 'FontSize', 12);
grid on; xlim([0 duration]);

subplot(4,1,4);
plot(t, strain_bandpass, 'Color', [0.6 0.2 0.8], 'LineWidth', 0.5);
xlabel('Time (s)'); ylabel('Strain');
title(sprintf('Band-Pass Filtered ([%d, %d] Hz) - Isolates chirp frequency range', f_band(1), f_band(2)), 'FontSize', 12);
grid on; xlim([0 duration]);

saveas(gcf, 'p2_fig3_filtered_time.png');
fprintf('Saved: p2_fig3_filtered_time.png\n');

%% ========== SECTION 7: FREQUENCY DOMAIN COMPARISON ==========
% Compute DFT of filtered signals
Y_low = fft(strain_lowpass);
Y_high = fft(strain_highpass);
Y_band = fft(strain_bandpass);

% Single-sided spectra
P1_low = abs(Y_low / N); P1_low = P1_low(1:N/2+1); P1_low(2:end-1) = 2*P1_low(2:end-1);
P1_high = abs(Y_high / N); P1_high = P1_high(1:N/2+1); P1_high(2:end-1) = 2*P1_high(2:end-1);
P1_band = abs(Y_band / N); P1_band = P1_band(1:N/2+1); P1_band(2:end-1) = 2*P1_band(2:end-1);

figure('Position', [200, 200, 1400, 800], 'Color', 'w');
sgtitle('Filtering Results - Frequency Domain Comparison', 'FontSize', 14, 'FontWeight', 'bold');

subplot(4,1,1);
plot(f, P1, 'b-', 'LineWidth', 1);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Original Signal Spectrum', 'FontSize', 12);
grid on; xlim([0 500]);

subplot(4,1,2);
plot(f, P1_low, 'Color', [0.8 0.2 0.2], 'LineWidth', 1);
hold on;
xline(f_low, 'k--', sprintf('f_c = %d Hz', f_low), 'LineWidth', 1.5);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('Low-Pass Filtered Spectrum (f_c = %d Hz)', f_low), 'FontSize', 12);
grid on; xlim([0 500]);

subplot(4,1,3);
plot(f, P1_high, 'Color', [0.2 0.6 0.2], 'LineWidth', 1);
hold on;
xline(f_high, 'k--', sprintf('f_c = %d Hz', f_high), 'LineWidth', 1.5);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('High-Pass Filtered Spectrum (f_c = %d Hz)', f_high), 'FontSize', 12);
grid on; xlim([0 500]);

subplot(4,1,4);
plot(f, P1_band, 'Color', [0.6 0.2 0.8], 'LineWidth', 1);
hold on;
xline(f_band(1), 'k--', sprintf('%d Hz', f_band(1)), 'LineWidth', 1.5);
xline(f_band(2), 'k--', sprintf('%d Hz', f_band(2)), 'LineWidth', 1.5);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('Band-Pass Filtered Spectrum ([%d, %d] Hz)', f_band(1), f_band(2)), 'FontSize', 12);
grid on; xlim([0 500]);

saveas(gcf, 'p2_fig4_filtered_freq.png');
fprintf('Saved: p2_fig4_filtered_freq.png\n');

%% ========== SECTION 8: OVERLAY COMPARISON ==========
figure('Position', [250, 250, 1200, 600], 'Color', 'w');

% Time domain overlay
subplot(2,1,1);
plot(t, strain, 'b-', 'LineWidth', 1, 'DisplayName', 'Original');
hold on;
plot(t, strain_lowpass, 'r-', 'LineWidth', 1, 'DisplayName', sprintf('Low-pass (%d Hz)', f_low));
plot(t, strain_highpass, 'g-', 'LineWidth', 1, 'DisplayName', sprintf('High-pass (%d Hz)', f_high));
plot(t, strain_bandpass, 'm-', 'LineWidth', 1.5, 'DisplayName', sprintf('Band-pass ([%d,%d] Hz)', f_band(1), f_band(2)));
xlabel('Time (s)', 'FontSize', 12);
ylabel('Strain', 'FontSize', 12);
title('Time Domain: Original vs Filtered Signals', 'FontSize', 14);
legend('Location', 'best');
grid on; xlim([0 duration]);

% Frequency domain overlay
subplot(2,1,2);
plot(f, P1, 'b-', 'LineWidth', 1, 'DisplayName', 'Original');
hold on;
plot(f, P1_low, 'r-', 'LineWidth', 1, 'DisplayName', sprintf('Low-pass (%d Hz)', f_low));
plot(f, P1_high, 'g-', 'LineWidth', 1, 'DisplayName', sprintf('High-pass (%d Hz)', f_high));
plot(f, P1_band, 'm-', 'LineWidth', 1.5, 'DisplayName', sprintf('Band-pass ([%d,%d] Hz)', f_band(1), f_band(2)));
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Amplitude', 'FontSize', 12);
title('Frequency Domain: Original vs Filtered Spectra', 'FontSize', 14);
legend('Location', 'best');
grid on; xlim([0 500]);

saveas(gcf, 'p2_fig5_overlay_comparison.png');
fprintf('Saved: p2_fig5_overlay_comparison.png\n');

%% ========== SECTION 9: FILTER FREQUENCY RESPONSE ==========
figure('Position', [300, 300, 1200, 400], 'Color', 'w');
sgtitle('Filter Frequency Response (Ideal Filters with Gaussian Roll-off)', 'FontSize', 14, 'FontWeight', 'bold');

% Use the positive frequency part of our filter transfer functions
f_plot = f_full(1:N/2+1);
H_low_plot = H_low(1:N/2+1);
H_high_plot = H_high(1:N/2+1);
H_band_plot = H_band(1:N/2+1);

subplot(1,3,1);
plot(f_plot, H_low_plot, 'r-', 'LineWidth', 2);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title(sprintf('Low-Pass (f_c = %d Hz)', f_low));
grid on; xlim([0 500]); ylim([-0.1 1.1]);
xline(f_low, 'k--', 'LineWidth', 1);

subplot(1,3,2);
plot(f_plot, H_high_plot, 'g-', 'LineWidth', 2);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title(sprintf('High-Pass (f_c = %d Hz)', f_high));
grid on; xlim([0 500]); ylim([-0.1 1.1]);
xline(f_high, 'k--', 'LineWidth', 1);

subplot(1,3,3);
plot(f_plot, H_band_plot, 'm-', 'LineWidth', 2);
xlabel('Frequency (Hz)'); ylabel('Magnitude');
title(sprintf('Band-Pass ([%d, %d] Hz)', f_band(1), f_band(2)));
grid on; xlim([0 500]); ylim([-0.1 1.1]);
xline(f_band(1), 'k--', 'LineWidth', 1);
xline(f_band(2), 'k--', 'LineWidth', 1);

saveas(gcf, 'p2_fig6_filter_response.png');
fprintf('Saved: p2_fig6_filter_response.png\n');

%% ========== SUMMARY ==========
fprintf('\n========================================\n');
fprintf('      PROBLEM 2 ANALYSIS SUMMARY        \n');
fprintf('========================================\n');
fprintf('Data: LIGO GW150914 Gravitational Wave\n');
fprintf('Sample rate: %d Hz\n', fs);
fprintf('Duration: %.3f seconds\n', duration);
fprintf('Samples: %d\n', N);
fprintf('\nFilters Applied (Frequency Domain - Ideal with Gaussian roll-off):\n');
fprintf('  1. Low-pass: f_c = %d Hz\n', f_low);
fprintf('  2. High-pass: f_c = %d Hz\n', f_high);
fprintf('  3. Band-pass: [%d, %d] Hz\n', f_band(1), f_band(2));
fprintf('\nFigures saved:\n');
fprintf('  p2_fig1_time_domain.png - Original signal\n');
fprintf('  p2_fig2_dft_spectrum.png - DFT frequency-amplitude plot\n');
fprintf('  p2_fig3_filtered_time.png - Filtered signals (time domain)\n');
fprintf('  p2_fig4_filtered_freq.png - Filtered signals (frequency domain)\n');
fprintf('  p2_fig5_overlay_comparison.png - Overlay comparison\n');
fprintf('  p2_fig6_filter_response.png - Filter frequency response\n');
fprintf('========================================\n');
