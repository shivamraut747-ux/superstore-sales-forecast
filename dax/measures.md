# Key DAX Measures & Calculations

This document details the core DAX measures created for the **SuperStore Sales & Forecasting Analytics** dashboard.

---

### 1. Core KPIs

#### Total Sales
Calculates the aggregate gross revenue across selected dimensions.
```dax
Total Sales = SUM(Orders[Sales])
```

#### Total Profit
Calculates the total profit generated across transactions.
```dax
Total Profit = SUM(Orders[Profit])
```

#### Total Quantity
Calculates the total units of items sold.
```dax
Total Quantity = SUM(Orders[Quantity])
```

#### Average Delivery Days
Computes the mean turnaround time between order placement and fulfillment.
```dax
Avg Delivery Days = 
AVERAGEX(
    Orders,
    DATEDIFF(Orders[Order Date], Orders[Ship Date], DAY)
)
```

---

### 2. Time Intelligence & YoY Comparisons

#### Sales Prior Year (SPLY)
Retrieves sales from the identical period in the preceding calendar year.
```dax
Sales SPLY = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR('Calendar'[Date])
)
```

#### Sales YoY Growth %
Calculates percentage change in revenue year-over-year.
```dax
YoY Sales Growth % = 
VAR _CurrentYear = [Total Sales]
VAR _PriorYear = [Sales SPLY]
RETURN
    DIVIDE(_CurrentYear - _PriorYear, _PriorYear, 0)
```

#### Profit Prior Year (SPLY)
Retrieves profit for the identical period in the preceding year.
```dax
Profit SPLY = 
CALCULATE(
    [Total Profit],
    SAMEPERIODLASTYEAR('Calendar'[Date])
)
```

#### YoY Profit Growth %
Calculates YoY percentage change in net profit.
```dax
YoY Profit Growth % = 
VAR _CurrentProfit = [Total Profit]
VAR _PriorProfit = [Profit SPLY]
RETURN
    DIVIDE(_CurrentProfit - _PriorProfit, ABS(_PriorProfit), 0)
```

---

### 3. State & Regional Rankings

#### Max of Sales by State
Computes the maximum single order or aggregated daily sales peak per state for ranking analyses.
```dax
Max of Sales = 
MAXX(
    KEEPFILTERS(VALUES(Orders[State])),
    [Total Sales]
)
```

#### Top N States Ranking
Enables dynamic ranking of states by sales volume.
```dax
State Rank by Sales = 
RANKX(
    ALL(Orders[State]),
    [Total Sales],
    ,
    DESC,
    Dense
)
```

---

### 4. Forecasting Methodology (Page 2)
The **15-Day Sales Forecast** on Page 2 leverages Power BI's built-in time series forecasting engine based on **Exponential Smoothing (ETS)** models:
- **Forecast Length**: 15 Days
- **Confidence Interval**: 95%
- **Seasonality**: Auto-detected (Weekly / Monthly sales cycles)
- **Granularity**: Daily (`Order Date`)
