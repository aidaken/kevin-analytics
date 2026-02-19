# Schema notes (tables used)

## Customer
- `Customer.CustomerId` (primary key)
- `FirstName`, `LastName`

## Invoice
- `Invoice.InvoiceId` (primary key)
- `Invoice.CustomerId` (FK → Customer)
- `Invoice.Total` (invoice amount)
