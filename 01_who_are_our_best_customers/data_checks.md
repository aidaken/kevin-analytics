# Data checks

## 1) Join does not duplicate invoices
Expectation: joining Customer -> Invoice should not change invoice count

## 2) Customer IDs are unique in Customer
Expectation: Customer.CustomerId is unique, no duplicates and etc

## 3) No negative invoice totals
Expectation: Invoice.Total >= 0

## 4) Null checks on keys
Expectation: Customer.CustomerId and Invoice.CustomerId are not null.

## 5) Totals reconcile
Expectation: sum(invoice totals) == sum(customer totals) after aggregation
