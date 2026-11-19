create Database EcommerceCustomerAnalytics

USE EcommerceCustomerAnalytics

select * from dbo.[year 2009-2010]
select * from dbo.[year 2010-2011]

select COUNT(*) as Rows_2009_2010 from dbo.[year 2009-2010];
select COUNT(*) as Rows_2009_2010 from dbo.[year 2010-2011];

select Invoice,StockCode, Description, Quantity,
  coalesce(
       TRY_CONVERT(datetime2,InvoiceDate,120),
       TRY_CONVERT(datetime2,InvoiceDate,105)
       ) as InvoiceDate,
       TRY_CONVERT(decimal(10,2),Price) as Price,
       Customer_ID,Country ,'2009-2010' as SourceSheet
Into dbo.RetailCombined
from dbo.[year 2009-2010]

Union all

select Invoice,StockCode, Description, Quantity,
  coalesce(
       TRY_CONVERT(datetime2,InvoiceDate,120),
       TRY_CONVERT(datetime2,InvoiceDate,105)
       ) as InvoiceDate,
       TRY_CONVERT(decimal(10,2),Price) as Price,
       Customer_ID,Country ,'2010-2011' as SourceSheet
from dbo.[year 2010-2011]


select COUNT(*) as Total_Rows from RetailCombined
select COUNT(*) as Failed_dates from dbo.RetailCombined where InvoiceDate is NULL
select count(*) as Failed_Price from dbo.RetailCombined where Price is NULL

select COUNT(*) as Missing_Customer
from dbo.RetailCombined where Customer_ID is NULL

select count(*) as Negative_Qty
from dbo.RetailCombined where Quantity <= 0

select count(*) as Missing_Description
from dbo.RetailCombined where Description is NULL

select Invoice,StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,
count(*) as ExactDupeCount
from dbo.RetailCombined
group by Invoice,StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
Having COUNT(*) > 3

with Deduped as (
 select *,
 Row_number() over(
          PARTITION BY Invoice,StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country
          order by (SELECT NULL)
        ) AS Rownum
    from dbo.RetailCombined
)
select Invoice,StockCode, Description, Quantity, InvoiceDate, Price, Customer_ID, Country,SourceSheet
INTO dbo.RetailCleaned
from Deduped
where Rownum = 1

select * from dbo.RetailCleaned

