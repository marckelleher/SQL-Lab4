/*
*************************************************************************************
CIS275, SQL Lab4, 
five questions provided by Vicki Jonathan, Instructor
modified by Jeff fried
PCC using Microsoft SQL Server 2008
date-you-begin-lab your-name-goes-here 
10 June 2012 DUE DATE
-------------------------------------------------------------------------------------
You need to know how to interpret story problems, translate their requirements into 
queries, write queries to class standards, and identify whether output is correct.
-------------------------------------------------------------------------------------
SELECT clause contains formatted projection items one to a line separated by commas
and aliased with user-friendly names in single quotes.
CAST(column_name AS CHAR(#)) for character data where # is best-fit field length.
STR(column_name, precision, scale) for numbers where precision is best-fit field 
    length which includes the decimal point and optional scale is the number of 
    decimal places (use 2 for money, omit for whole numbers).
CONVERT(CHAR(12), column_name, #) for dates where # is the style number for date.
SQL keywords and table names are uppercase. Every query to end with a semi-colon.
*************************************************************************************
*/

USE FiredUp    -- ensures correct database is active


GO
PRINT 'CIS2275, Lab4, question 1, twenty (20) points possible
What types of stoves have sold in at least three different states and
somewhere in Canada? Display the stove type.' + CHAR(10);
GO

SELECT		DISTINCT CAST(S.Type AS CHAR(15)) AS 'Stove Type'
FROM		CUSTOMER AS C JOIN INVOICE AS I ON C.CustomerID = I.FK_CustomerID
			JOIN INV_LINE_ITEM AS ILI ON I.InvoiceNbr = ILI.FK_InvoiceNbr
			JOIN STOVE AS S ON ILI.FK_StoveNbr = S.SerialNumber
WHERE		C.Country IN (SELECT C.Country FROM CUSTOMER AS C WHERE C.Country = 'CAN')
GROUP BY	S.Type
HAVING		COUNT(C.StateProvince) >= 3;		

GO
PRINT 'CIS275, Lab4, question 2, twenty (20) points possible
Out of all the invoices containing FiredAlways stoves, show those with the three 
highest total price. Display the invoice number, invoice date, and totalprice. ' + CHAR(10);
GO

SELECT		TOP 3 WITH TIES STR(I.InvoiceNbr,18,0) AS 'Invoice Number', 
			CONVERT(CHAR(12),I.InvoiceDt,101) AS 'Invoice Date', STR(I.TotalPrice,18,2) AS 'Total Price'
FROM		INVOICE AS I JOIN INV_LINE_ITEM AS ILI ON I.InvoiceNbr = ILI.FK_InvoiceNbr
			JOIN STOVE AS S ON ILI.FK_StoveNbr = S.SerialNumber
WHERE		S.Type = 'FiredAlways'
GROUP BY	I.TotalPrice, I.InvoiceNbr, I.InvoiceDt
ORDER BY	I.TotalPrice DESC;

GO
PRINT 'CIS275, Lab4, question 3, twenty (20) points possible
Who has sold stoves in the two most popular states?
Display the employee number, employee name, the name of the two most popular states, 
and the number of stoves sold by the employees in those states.  (''Most popular 
state'' means the state or states for customers who purchased the most stoves, 
regardless of the stove type and version. Do not hardcode a specific state into your 
query.)' + CHAR(10);
GO

SELECT		STR(E.EmpID,18,0) AS 'Employee #', CAST(E.Name AS CHAR(50)) AS 'Employee Name',
			CAST(C.StateProvince AS CHAR(2)) AS 'State', COUNT(I.FK_EmpID) AS '# Sold'
FROM		EMPLOYEE AS E JOIN INVOICE AS I ON E.EmpID = I.FK_EmpID
			JOIN CUSTOMER AS C ON I.FK_CustomerID = C.CustomerID
WHERE		C.StateProvince IN	(SELECT TOP 2 WITH TIES C.StateProvince, COUNT(*) AS 'Count'
								FROM		INVOICE AS I, CUSTOMER AS C
								WHERE		I.FK_CustomerID = C.CustomerID
								GROUP BY	C.StateProvince
								ORDER BY	'Count' DESC)
GROUP BY	E.EmpID, E.Name, C.StateProvince


--This is what I tried to integrate into the query as a subquery but couldn't find a way to do it.  I need the ORDER BY clause for the COUNT aggregate, ,which can't appear in a subquery:
SELECT		TOP 2 WITH TIES C.StateProvince, COUNT(*) AS 'Count'
FROM		INVOICE AS I, CUSTOMER AS C
WHERE		I.FK_CustomerID = C.CustomerID
GROUP BY	C.StateProvince
ORDER BY	'Count' DESC

GO
PRINT 'CIS275, Lab4, question 4, twenty (20) points possible
Show employees having sold the type and version of stove that has been repaired the 
most? Display the employee name, stove type, stove version, and number of times 
repaired. If there is more than one employee then display them all. Do not hardcode 
a specific type or version into your query. (We are not asking for the person whose 
stoves get repaired the most. The employee who sold the most of the least reliable 
stove may have gotten lucky with their particular sales.)' + CHAR(10);
GO

SELECT		CAST(E.Name AS CHAR(50)) AS 'Employee Name', CAST(S.Type AS CHAR(15)) AS 'Stove Type',
			CAST(S.Version AS CHAR(15)) AS 'Stove Version', COUNT(DISTINCT SR.FK_StoveNbr) AS 'Times Repaired'
			--COUNT(DISTINCT SR.RepairNbr) AS 'Times Repaired'
FROM		STOVE_REPAIR AS SR, EMPLOYEE AS E JOIN INVOICE AS I ON E.EmpID = I.FK_EmpID
			INNER JOIN INV_LINE_ITEM AS ILI ON I.InvoiceNbr = ILI.FK_InvoiceNbr
			INNER JOIN STOVE AS S ON ILI.FK_StoveNbr = S.SerialNumber 
WHERE		S.Type IN	(SELECT	S.Type, S.Version, COUNT(SR.FK_StoveNbr) AS 'Times Repaired'
						FROM	STOVE AS S JOIN STOVE_REPAIR AS SR ON S.SerialNumber = SR.FK_StoveNbr
						GROUP BY S.Type, S.Version
						ORDER BY 'Times Repaired' DESC)
GROUP BY	E.Name, S.Type, S.Version

--This is what I tried to integrate into the query as a subquery but couldn't find a way to do it.  I need the ORDER BY clause for the COUNT aggregate, ,which can't appear in a subquery:
SET ROWCOUNT 1
SELECT	S.Type, S.Version, COUNT(SR.FK_StoveNbr) AS 'Times Repaired'
FROM	STOVE AS S JOIN STOVE_REPAIR AS SR ON S.SerialNumber = SR.FK_StoveNbr
GROUP BY S.Type, S.Version
ORDER BY 'Times Repaired' DESC


GO
PRINT 'CIS275, Lab4, question 5, twenty (20) points possible
Which invoice has the second-lowest total price among invoices that do not include a 
sale of a FiredAlways stove? Display the invoice number, invoice date, and invoice 
total price. If there is more than one invoice then display all of them. (Finding 
invoices that do not include a FiredAlways stove is NOT the same as finding invoices 
where a line item contains something other than a FiredAlways stove -- invoices have 
more than one line. Avoid a JOIN with STOVE since the lowest price may not involve 
any stove sales.)' + CHAR(10);
GO

SELECT		TOP 1 WITH TIES STR(InvoiceNbr,18,0) AS 'Invoice Number', CONVERT(CHAR(12),InvoiceDt,101) AS 'Invoice Date',
			STR(TotalPrice,18,2) AS 'Total Price'
FROM (SELECT TOP 2 WITH TIES
             InvoiceNbr ,
             InvoiceDT ,
             TotalPrice 
      FROM INVOICE
      WHERE InvoiceNbr NOT IN (SELECT FK_InvoiceNbr
                               FROM INV_LINE_ITEM
                               WHERE FK_StoveNbr IN (SELECT serialnumber
                                                     FROM STOVE
                                                    WHERE type = 'FiredAlways'))
      ORDER BY TotalPrice ASC) as TABLE1
ORDER BY 'Total Price' DESC;

GO
-------------------------------------------------------------------------------------
-- This is an anonymous program block. DO NOT CHANGE OR DELETE.
-------------------------------------------------------------------------------------
BEGIN
    PRINT '|---' + REPLICATE('+----',15) + '|';
    PRINT ' End of CIS275 Lab4' + REPLICATE(' ',50) + CONVERT(CHAR(12),GETDATE(),101);
    PRINT '|---' + REPLICATE('+----',15) + '|';
END;


