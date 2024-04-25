import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from statsmodels.formula.api import ols

# Load data
df09 = pd.read_excel("customer_transactions_sample.xlsx", sheet_name="Year 2009-2010")
df10 = pd.read_excel("customer_transactions_sample.xlsx", sheet_name="Year 2010-2011")

# Combine dataframes
df11 = pd.concat([df09, df10])
df11.rename(columns={"Customer ID": "CustomerID"}, inplace=True)

# Data cleaning
df11['InvoiceDate'] = pd.to_datetime(df11['InvoiceDate'])
df11.dropna(subset=['Quantity'], inplace=True)
df11 = df11[df11['Quantity'] > 0]
df11 = df11[df11['Country'] == 'United Kingdom']
df11 = df11[df11['Description'].str.contains(r'CHRISTMAS|TREE|DECORATIONS|SIGNS|LIGHTS|ORNAMENTS', regex=True, case=False)]

# Aggregate data
df11_agg = df11.groupby('CustomerID')['Quantity'].sum().reset_index()

# Remove outliers
Q1 = df11_agg['Quantity'].quantile(0.25)
Q3 = df11_agg['Quantity'].quantile(0.75)
IQR = Q3 - Q1
lower_bound = Q1 - 1.5 * IQR
upper_bound = Q3 + 1.5 * IQR
df11_agg = df11_agg[(df11_agg['Quantity'] >= lower_bound) & (df11_agg['Quantity'] <= upper_bound)]

# Plot aggregated quantity by day
df11_aggregated = df11.groupby('InvoiceDate')['Quantity'].sum().reset_index()
plt.figure(figsize=(10, 6))
sns.lineplot(data=df11_aggregated, x='InvoiceDate', y='Quantity')
plt.xlabel('Date')
plt.ylabel('Total Quantity')
plt.title('Aggregated Quantity by Day')
plt.show()

# Prophet forecasting
from fbprophet import Prophet

df11_aggregated.columns = ['ds', 'y']
m = Prophet(yearly_seasonality=True, weekly_seasonality=True)
m.fit(df11_aggregated)
future = m.make_future_dataframe(periods=364)
forecast = m.predict(future)

# Plot actual vs. predicted with upper and lower bounds
plt.figure(figsize=(10, 6))
plt.plot(df11_aggregated['ds'], df11_aggregated['y'], color='red', label='Actual', linewidth=1)
plt.plot(forecast['ds'], forecast['yhat'], color='blue', label='Predicted', linewidth=1)
plt.fill_between(forecast['ds'], forecast['yhat_upper'], forecast['yhat_lower'], color='grey', alpha=0.3)
plt.xlabel('Date')
plt.ylabel('Values')
plt.title('Actual vs. Predicted with Upper and Lower Bounds')
plt.legend()
plt.show()

# Calculate profit and sales
df11['Total'] = df11['Price'] * df11['Quantity']
df_profit = df11.groupby('Country')['Price'].sum().reset_index()

df_positive = df11[df11['Quantity'] > 0]
country_sales = df_positive.groupby('Country')['Quantity'].sum().reset_index()

df_negative = df11[df11['Quantity'] < 0]
country_returns = df_negative.groupby('Country')['Quantity'].sum().reset_index()
country_returns['Quantity'] = abs(country_returns['Quantity'])

country_totals = pd.merge(country_sales, country_returns, on='Country', how='outer')
country_totals.fillna(0, inplace=True)
country_totals['returnrate'] = round((country_totals['Quantity_y'] / country_totals['Quantity_x']) * 100, 2)

# Load holiday data
df_hol = df11[['InvoiceDate', 'Country']]
df_hol = df_hol.drop_duplicates()
df_hol = df_hol.groupby('Country').size().reset_index(name='Working_Days')

# Merge all data
df16 = pd.merge(country_totals, df_profit, on='Country')
df16 = pd.merge(df16, df_hol, on='Country')

# Calculate holiday revenue share
df16['holidayrevenueshare'] = (df16['Holiday_revenue'] / df16['NonHoliday_revenue']) * 100

# Plot country by holiday revenue share
plt.figure(figsize=(10, 6))
sns.barplot(data=df16.sort_values(by='holidayrevenueshare', ascending=False),
            x='Country', y='holidayrevenueshare',
            palette={'United Kingdom': 'darkblue', 'Others': 'skyblue'})
plt.xticks(rotation=45, ha='right')
plt.ylabel('Holiday Revenue Share (%)')
plt.title('Country by Holiday Revenue Share')
plt.tight_layout()
plt.show()
