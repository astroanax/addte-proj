"""
Fetch INR/USD Exchange Rate Data for Least Squares Regression Analysis
Uses Yahoo Finance API via yfinance
"""

import yfinance as yf
import pandas as pd
from datetime import datetime, timedelta


def fetch_inr_usd_data():
    """Fetch INR/USD exchange rate data for the past year."""

    # INR=X is the USD/INR ticker on Yahoo Finance
    ticker = "INR=X"

    # Get 1 year of data
    end_date = datetime.now()
    start_date = end_date - timedelta(days=365)

    print(f"Fetching INR/USD data from {start_date.date()} to {end_date.date()}...")

    # Download data
    data = yf.download(ticker, start=start_date, end=end_date, progress=False)

    if data.empty:
        print("Error: No data retrieved")
        return None

    print(f"Retrieved {len(data)} data points")

    # Use closing price
    if isinstance(data.columns, pd.MultiIndex):
        # Handle MultiIndex columns from yfinance
        close_prices = (
            data["Close"].iloc[:, 0] if data["Close"].shape[1] > 0 else data["Close"]
        )
    else:
        close_prices = data["Close"]

    # Create output dataframe
    df = pd.DataFrame({"date": data.index, "rate": close_prices.values})

    # Add day number (for regression)
    df["day"] = range(len(df))

    # Save to CSV
    output_file = "inr_usd_data.csv"
    df.to_csv(output_file, index=False)
    print(f"Saved to {output_file}")

    # Print summary statistics
    print(f"\n=== Summary Statistics ===")
    print(f"Date range: {df['date'].iloc[0].date()} to {df['date'].iloc[-1].date()}")
    print(f"Number of trading days: {len(df)}")
    print(f"Min rate: {df['rate'].min():.4f} INR/USD")
    print(f"Max rate: {df['rate'].max():.4f} INR/USD")
    print(f"Mean rate: {df['rate'].mean():.4f} INR/USD")
    print(f"Std dev: {df['rate'].std():.4f}")

    return df


if __name__ == "__main__":
    df = fetch_inr_usd_data()
