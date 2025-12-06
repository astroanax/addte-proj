"""
Fetch stock data from Yahoo Finance for DMD analysis
Downloads intraday data for multiple stocks over the past 5 days
Focused on RAM/Memory semiconductor industry
"""

import yfinance as yf
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Define portfolio of stocks (RAM/Memory semiconductor industry)
# Using US-listed stocks with reliable intraday data
tickers = [
    "MU",  # Micron Technology (owns Crucial brand) - DRAM & NAND
    "WDC",  # Western Digital - NAND flash memory
    "INTC",  # Intel - memory & storage solutions
    "TXN",  # Texas Instruments - semiconductor memory
    "MRVL",  # Marvell Technology - memory controllers
    "AMAT",  # Applied Materials - memory chip equipment
    "LRCX",  # Lam Research - memory fabrication equipment
    "KLAC",  # KLA Corporation - memory chip inspection
    "AMD",  # AMD - memory-related processors
    "NVDA",  # NVIDIA - HBM memory demand driver
]

print(f"Fetching data for {len(tickers)} RAM/Memory industry stocks:")
for t in tickers:
    print(f"  - {t}")

# Fetch 1 month of daily data
# Note: Yahoo Finance only allows 7 days of intraday (1h) data
# For 1 month, we use daily data
print("\nDownloading 1 month of daily data...")
prices = pd.DataFrame()

for ticker in tickers:
    try:
        stock = yf.Ticker(ticker)
        hist = stock.history(period="1mo", interval="1d")
        if not hist.empty:
            prices[ticker] = hist["Close"]
            print(f"  {ticker}: {len(hist)} data points")
        else:
            print(f"  {ticker}: No data available")
    except Exception as e:
        print(f"  {ticker}: Error - {e}")

# Drop any rows with NaN values
prices = prices.dropna()

if prices.empty:
    print("\nERROR: No data was fetched. Please check your internet connection.")
    exit(1)

print(f"\n=== Data Summary ===")
print(f"Data shape: {prices.shape}")
print(f"Number of stocks (N): {prices.shape[1]}")
print(f"Number of time snapshots (M): {prices.shape[0]}")
print(f"Date range: {prices.index[0]} to {prices.index[-1]}")

# Save to CSV for MATLAB
prices.to_csv("stock_data.csv", index=True)
print("\nData saved to 'stock_data.csv'")

# Also save just the price matrix (no headers) for easy MATLAB import
price_matrix = prices.values
np.savetxt("stock_prices.csv", price_matrix, delimiter=",")
print("Price matrix saved to 'stock_prices.csv'")

# Save ticker names separately
tickers_available = list(prices.columns)
with open("stock_tickers.txt", "w") as f:
    f.write(",".join(tickers_available))
print(f"Ticker names saved to 'stock_tickers.txt': {tickers_available}")

# Display summary statistics
print("\n=== Price Statistics ===")
print(prices.describe().round(2))

# Display first few rows
print("\n=== First 5 rows ===")
print(prices.head())

print("\n=== Data fetch complete! ===")
print("Now run DMD_stocks.m in MATLAB to perform DMD analysis.")
