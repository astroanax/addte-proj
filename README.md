# ME3435E - Applied Data-Driven Techniques in Engineering

Project report implementing 7 problems on data-driven methods using MATLAB and Python.

## Prerequisites

- MATLAB R2020a or later
- Python 3.8+ with virtual environment
- Required Python packages: `yfinance`, `numpy`, `pandas`, `requests`

### Python Setup

```bash
cd /home/astroanax/dev/addte
source .venv/bin/activate
```

## Problem 1: Dynamic Mode Decomposition (DMD) on Stock Portfolio

Directory: `problem1/`

1. Fetch stock data:
```bash
python problem1/fetch_stock_data.py
```

2. Run DMD analysis:
```matlab
run('problem1/DMD_stocks.m')
```

Output: `fig1_dmd_decomposition.png`, `fig2_mode_analysis.png`, `fig3_eigenvalue_distribution.png`, `fig4_reconstruction.png`, `fig5_summary.png`

## Problem 2: DFT Analysis and Digital Filtering

Directory: `problem2/`

1. Fetch LIGO gravitational wave data:
```bash
python problem2/fetch_ligo_data.py
```

2. Run DFT and filtering analysis:
```matlab
run('problem2/problem2_filtering.m')
```

Output: `p2_fig1_time_domain.png` through `p2_fig6_filter_response.png`

## Problem 3: Discrete-Time Signal Operations

Directory: `problem3/`

1. Run discrete signal analysis:
```matlab
run('problem3/problem3_discrete.m')
```

Output: `p3_fig1_signals.png` through `p3_fig4_dft_all.png`

## Problem 4: SINDy on Double Pendulum

Directory: `problem4/`

1. Run SINDy analysis:
```matlab
run('problem4/EX_DoublePendulum.m')
```

Note: Requires `double_pendulum.m` in the same directory or MATLAB path.

Output: `p4_fig1_time_series.png` through `p4_fig4_coefficients.png`

## Problem 5: Cross-Correlation for Audio Pattern Matching

Directory: `problem5/`

1. Place audio files in directory:
   - `mario_coin_original.wav` (original audio)
   - `recording.aac` (recorded query)

2. Run cross-correlation analysis:
```matlab
run('problem5/problem5_crosscorr.m')
```

Output: `p5_fig1_crosscorrelation.png`, `p5_fig2_spectrograms.png`

## Problem 6: SVD for Image Compression

Directory: `problem6/`

1. Ensure `nitc.png` exists in directory.

2. Run SVD analysis:
```matlab
run('problem6/problem6_svd.m')
```

Output: `p6_fig1_svd_analysis.png` through `p6_fig4_comparison.png`

## Problem 7: Least Squares Regression

Directory: `problem7/`

1. Fetch INR/USD exchange rate data:
```bash
python problem7/fetch_inr_usd.py
```

2. Run polynomial regression analysis:
```matlab
run('problem7/problem7_leastsquares.m')
```

Output: `p7_fig1_polynomial_fits.png` through `p7_fig5_best_fit.png`

## Report

Directory: `report/`

Compile LaTeX report:
```bash
cd report
pdflatex report.tex
pdflatex report.tex
```

Output: `report.pdf` (43 pages)

## Running MATLAB from Command Line

```bash
matlab -nodisplay -nosplash -nodesktop -r "run('script.m'); exit;"
```

## File Structure

```
addte/
├── problem1/     # DMD on Stocks
├── problem2/     # DFT/Filtering
├── problem3/     # Discrete Signals
├── problem4/     # SINDy
├── problem5/     # Cross-correlation
├── problem6/     # SVD Compression
├── problem7/     # Least Squares
├── report/       # LaTeX report
├── references/   # Reference papers
└── README.md     # This file
```
