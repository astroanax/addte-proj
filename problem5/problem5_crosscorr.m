%% Problem 5: Convolution and Cross-Correlation
% Shazam-like Audio Fingerprinting using Cross-Correlation
% Finding a recorded Mario coin sound snippet within the original audio
%
% This demonstrates how cross-correlation can locate a pattern (query)
% within a larger signal (database), similar to audio recognition apps.

clear; clc; close all;

%% Load Audio Files
fprintf('=== Problem 5: Audio Pattern Matching via Cross-Correlation ===\n\n');

% Original "database" audio (Mario coin sound from YouTube)
[x_orig, fs_orig] = audioread('mario_coin_original.wav');
fprintf('Original audio: %.3f seconds at %d Hz\n', length(x_orig)/fs_orig, fs_orig);

% Recorded "query" audio (phone recording of the sound)
[x_rec, fs_rec] = audioread('recording.aac');
fprintf('Recording: %.3f seconds at %d Hz\n', length(x_rec)/fs_rec, fs_rec);

%% Preprocessing
% Convert stereo to mono if needed
if size(x_orig, 2) > 1
    x_orig = mean(x_orig, 2);
end
if size(x_rec, 2) > 1
    x_rec = mean(x_rec, 2);
end

% Resample to common sample rate using linear interpolation
% (no Signal Processing Toolbox required)
fs = max(fs_orig, fs_rec);

if fs_orig ~= fs
    t_old = (0:length(x_orig)-1) / fs_orig;
    t_new = 0:1/fs:t_old(end);
    x_orig = interp1(t_old, x_orig, t_new, 'linear')';
end

if fs_rec ~= fs
    t_old = (0:length(x_rec)-1) / fs_rec;
    t_new = 0:1/fs:t_old(end);
    x_rec = interp1(t_old, x_rec, t_new, 'linear')';
end

fprintf('Resampled both to %d Hz\n', fs);
fprintf('Original: %d samples, Recording: %d samples\n', length(x_orig), length(x_rec));

% Normalize both signals
x_orig = x_orig / max(abs(x_orig));
x_rec = x_rec / max(abs(x_rec));

%% Time vectors
t_orig = (0:length(x_orig)-1) / fs;
t_rec = (0:length(x_rec)-1) / fs;

%% Cross-Correlation
% xcorr(x, y) computes correlation of x with y at all lags
% Peak location indicates where y best matches within x
fprintf('\nComputing cross-correlation...\n');

[r, lags] = xcorr(x_orig, x_rec);
lag_time = lags / fs;

% Find the peak
[max_corr, max_idx] = max(r);
best_lag = lags(max_idx);
best_time = best_lag / fs;

fprintf('Peak correlation at lag = %d samples (%.4f seconds)\n', best_lag, best_time);

% The match starts at this position in the original
match_start = best_lag;
if match_start < 0
    match_start = 0;
end
match_start_time = match_start / fs;
fprintf('Match found at t = %.4f seconds in original\n', match_start_time);

%% Normalized Cross-Correlation (for comparison)
% Normalize by energy for a correlation coefficient
r_norm = r / (norm(x_orig) * norm(x_rec));
max_corr_norm = max(r_norm);
fprintf('Normalized peak correlation: %.4f\n', max_corr_norm);

%% Convolution (for comparison/demonstration)
% Convolution with time-reversed signal is equivalent to correlation
x_rec_rev = flipud(x_rec);
y_conv = conv(x_orig, x_rec_rev, 'full');

%% Plotting
figure('Position', [100, 100, 1400, 900]);

% 1. Original signal (time domain)
subplot(3, 2, 1);
plot(t_orig, x_orig, 'b', 'LineWidth', 0.5);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original Audio: Mario Coin Sound');
grid on;
xlim([0, t_orig(end)]);

% 2. Recorded signal (time domain)
subplot(3, 2, 2);
plot(t_rec, x_rec, 'r', 'LineWidth', 0.5);
xlabel('Time (s)');
ylabel('Amplitude');
title('Recorded Query: Phone Recording');
grid on;
xlim([0, t_rec(end)]);

% 3. Cross-correlation result
subplot(3, 2, 3);
plot(lag_time, r, 'Color', [0.5, 0, 0.5], 'LineWidth', 0.5);
hold on;
plot(best_time, max_corr, 'g*', 'MarkerSize', 15, 'LineWidth', 2);
xlabel('Lag (s)');
ylabel('Correlation');
title(sprintf('Cross-Correlation (Peak at %.3f s)', best_time));
legend('Cross-correlation', sprintf('Peak at %.3f s', best_time), 'Location', 'best');
grid on;

% 4. Zoomed cross-correlation around peak
subplot(3, 2, 4);
zoom_range = abs(lag_time - best_time) < 0.5;  % ±0.5 seconds around peak
plot(lag_time(zoom_range), r(zoom_range), 'Color', [0.5, 0, 0.5], 'LineWidth', 1);
hold on;
plot(best_time, max_corr, 'g*', 'MarkerSize', 15, 'LineWidth', 2);
xlabel('Lag (s)');
ylabel('Correlation');
title('Cross-Correlation (Zoomed around Peak)');
grid on;

% 5. Overlay: Show where match occurs in original
subplot(3, 2, 5);
plot(t_orig, x_orig, 'b', 'LineWidth', 0.5);
hold on;
% Highlight the matched region
match_end_time = match_start_time + length(x_rec)/fs;
if match_start >= 0 && match_start + length(x_rec) <= length(x_orig)
    % Extract matched segment from original
    match_segment = x_orig(match_start+1 : min(match_start+length(x_rec), length(x_orig)));
    t_match = match_start_time + (0:length(match_segment)-1)/fs;
    plot(t_match, match_segment, 'g', 'LineWidth', 1.5);
end
xline(match_start_time, 'g--', 'LineWidth', 2);
xline(match_end_time, 'r--', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Amplitude');
title(sprintf('Match Location in Original (t = %.3f to %.3f s)', match_start_time, match_end_time));
legend('Original', 'Matched segment', 'Match start', 'Match end', 'Location', 'best');
grid on;
xlim([0, t_orig(end)]);

% 6. Comparison: Convolution vs Cross-correlation
subplot(3, 2, 6);
t_conv = (0:length(y_conv)-1)/fs - length(x_rec)/fs;
plot(t_conv, y_conv/max(abs(y_conv)), 'b', 'LineWidth', 0.5);
hold on;
plot(lag_time, r/max(abs(r)), 'r--', 'LineWidth', 0.5);
xlabel('Time (s)');
ylabel('Normalized Amplitude');
title('Convolution vs Cross-Correlation');
legend('Conv(x, flip(y))', 'XCorr(x, y)', 'Location', 'best');
grid on;

sgtitle('Problem 5: Shazam-like Audio Pattern Matching', 'FontSize', 14, 'FontWeight', 'bold');

% Save figure
print('p5_fig1_crosscorrelation', '-dpng', '-r150');
fprintf('\nSaved: p5_fig1_crosscorrelation.png\n');

%% Figure 2: Spectrograms (manual implementation - no Signal Processing Toolbox)
figure('Position', [100, 100, 1200, 800]);

% Spectrogram parameters
window_len = round(0.02 * fs);  % 20ms window
hop = round(0.005 * fs);  % 5ms hop (75% overlap)
nfft = 2^nextpow2(window_len);
% Hann window (manual - no toolbox)
n_win = (0:window_len-1)';
win = 0.5 * (1 - cos(2*pi*n_win / (window_len-1)));

% Manual spectrogram function
compute_spectrogram = @(x) compute_spec(x, win, hop, nfft);

[S_orig, f_spec, t_spec_orig] = compute_spectrogram(x_orig);
[S_rec, ~, t_spec_rec] = compute_spectrogram(x_rec);

% Original spectrogram
subplot(2, 2, 1);
imagesc(t_spec_orig, f_spec/1000, 20*log10(abs(S_orig) + eps));
axis xy;
colorbar;
ylim([0, 10]);  % Focus on 0-10 kHz
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('Original Audio Spectrogram');

% Recording spectrogram
subplot(2, 2, 2);
imagesc(t_spec_rec, f_spec/1000, 20*log10(abs(S_rec) + eps));
axis xy;
colorbar;
ylim([0, 10]);
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('Recorded Query Spectrogram');

% DFT comparison
subplot(2, 2, 3);
N_orig = length(x_orig);
f_orig = (0:N_orig-1) * fs / N_orig;
X_orig = abs(fft(x_orig));
plot(f_orig(1:N_orig/2), X_orig(1:N_orig/2), 'b', 'LineWidth', 0.5);
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('DFT: Original Audio');
xlim([0, 5000]);
grid on;

subplot(2, 2, 4);
N_rec = length(x_rec);
f_rec = (0:N_rec-1) * fs / N_rec;
X_rec = abs(fft(x_rec));
plot(f_rec(1:N_rec/2), X_rec(1:N_rec/2), 'r', 'LineWidth', 0.5);
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('DFT: Recorded Query');
xlim([0, 5000]);
grid on;

sgtitle('Problem 5: Frequency Analysis of Audio Signals', 'FontSize', 14, 'FontWeight', 'bold');

print('p5_fig2_spectrograms', '-dpng', '-r150');
fprintf('Saved: p5_fig2_spectrograms.png\n');

%% Summary Statistics
fprintf('\n=== Summary ===\n');
fprintf('Original audio duration: %.3f seconds\n', length(x_orig)/fs);
fprintf('Query recording duration: %.3f seconds\n', length(x_rec)/fs);
fprintf('Sample rate: %d Hz\n', fs);
fprintf('Cross-correlation peak at: %.4f seconds\n', best_time);
fprintf('Normalized correlation coefficient: %.4f\n', max_corr_norm);
fprintf('\nThe recording matches the original starting at t = %.3f seconds\n', match_start_time);

fprintf('\n=== Mathematical Background ===\n');
fprintf('Cross-correlation: (x ⋆ y)[n] = Σ x[m] · y[m+n]\n');
fprintf('Convolution:       (x * y)[n] = Σ x[m] · y[n-m]\n');
fprintf('Relationship: xcorr(x,y) = conv(x, flip(y))\n');

fprintf('\nDone!\n');

%% Helper function for spectrogram (no toolbox required)
function [S, f, t] = compute_spec(x, win, hop, nfft)
    x = x(:);
    win = win(:);
    win_len = length(win);
    num_frames = floor((length(x) - win_len) / hop) + 1;
    
    S = zeros(nfft, num_frames);
    for i = 1:num_frames
        start_idx = (i-1)*hop + 1;
        frame = x(start_idx:start_idx+win_len-1) .* win;
        S(:, i) = fft(frame, nfft);
    end
    
    % Only keep positive frequencies
    S = S(1:nfft/2+1, :);
    f = (0:nfft/2)' * (48000 / nfft);  % Assuming fs=48000
    t = ((0:num_frames-1) * hop + win_len/2) / 48000;
end
