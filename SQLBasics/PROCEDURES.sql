---------------------------SCENARIUSZ 1 ---------------------------------------------------

--utworzy� tabel� ArchivedOrders z tym samym zestawem kolumn, co tabela Orders
SELECT * 
INTO ArchievedOrders
FROM Orders
WHERE 0=1

--zdefiniowa� klucz podstawowy i klucze obce odnosz�ce si� do klient�w i pracownik�w
ALTER TABLE ArchievedOrders
ADD CONSTRAINT PK_OrderID PRIMARY KEY (OrderID)

ALTER TABLE ArchievedOrders
ADD CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)

ALTER TABLE ArchievedOrders
ADD CONSTRAINT FK_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)

--doda� kolumn� ArchiveDate datetime (ustawiona default na dzis)
ALTER TABLE ArchievedOrders
ADD ArchievedDate datetime DEFAULT getdate()


--utworzy� tabel� ArchivedOrderDetails z tym samym zestawem kolumn, jak tabela [Order Details]
SELECT * 
INTO ArchievedOrderDetails
FROM [Order Details]
WHERE 0=1

--ustawi� klucze podstawowe i obce
ALTER TABLE ArchievedOrderDetails
ADD CONSTRAINT PK_OrderID_ProductID PRIMARY KEY (OrderID,ProductID)

ALTER TABLE ArchievedOrderDetails
ADD CONSTRAINT FK_orderID FOREIGN KEY (OrderID) REFERENCES ArchievedOrders(OrderID)

ALTER TABLE ArchievedOrderDetails
ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Products(ProductID)

--przygotowa� procedur� sk�adowan�, kt�ra wykonuje przeniesienie wszystkich zam�wie� starszych ni� N lat tzn:
--usuni�cie danych tych zam�wie� z Orders i [Orders Details],
--wstawienie danych w/w zam�wie� do ArchivedOrders oraz ArchivedOrderDetails,
--ustawienie ArchiveDate na bie��c� dat�

SELECT * FROM Orders --zam�wienia z 96,97,98

CREATE PROCEDURE ArchieveOrders
@years int
AS
BEGIN
	BEGIN TRANSACTION
	SET IDENTITY_INSERT ArchievedOrders ON;
	--wstawianie do ArchievedOrders
	INSERT INTO ArchievedOrders (OrderID,CustomerID,EmployeeID,OrderDate,RequiredDate,ShippedDate,ShipVia,Freight,ShipName,ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry,ArchievedDate)
	SELECT OrderID,CustomerID,EmployeeID,OrderDate,RequiredDate,ShippedDate,ShipVia,Freight,ShipName,ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry, getdate()
	FROM Orders 
	WHERE datediff(yy, OrderDate, getdate())>@years

	--wstawianie do ArchievedOrderDetails
	INSERT INTO ArchievedOrderDetails(OrderID,ProductID,UnitPrice,Quantity,Discount)
	SELECT OrderID,ProductID,UnitPrice,Quantity,Discount
	FROM [Order Details] od
	WHERE od.OrderID IN (SELECT OrderID FROM Orders WHERE datediff(yy, OrderDate, getdate())>@years)

	--usuwanie z OrderDetails
	DELETE FROM [Order Details] WHERE OrderID IN (SELECT OrderID FROM Orders WHERE datediff(yy, OrderDate, getdate())>@years)

	--usuwanie z Orders 
	DELETE FROM Orders WHERE datediff(yy, OrderDate, getdate())>@years

	COMMIT
END

EXEC ArchieveOrders @years=7

SELECT * FROM ArchievedOrders --wida� przeniesione wszystkie zam�wienia
SELECT * FROM Orders


------------------------------------------SCENARIUSZ 2----------------------------------------------------------
--Celem jest przygotowanie procedury sk�adowanej parametryzowanej identyfikatorem klienta (CustomerId)
--Procedura dla ka�dego zam�wienia tego klienta sprawdza liczb� zam�wie� z�o�onych wcze�niej przez klienta na dany produkt
--Warto�� rabatu w procentach jest zapisywana przez procedur� w kolumnie discount w tabeli [Order details]

CREATE PROCEDURE CalculateDiscount2 @CustomerId VARCHAR(5)
AS
BEGIN
    -- Aktualizacja rabatu dla ka�dego zam�wienia klienta
    UPDATE od
    SET od.discount = CASE
        WHEN (SELECT COUNT(*) FROM [Order details] WHERE CustomerId = @CustomerId AND ProductId = od.ProductId) BETWEEN 1 AND 2 THEN 0.05
        WHEN (SELECT COUNT(*) FROM [Order details] WHERE CustomerId = @CustomerId AND ProductId = od.ProductId) = 3 THEN 0.1
        WHEN (SELECT COUNT(*) FROM [Order details] WHERE CustomerId = @CustomerId AND ProductId = od.ProductId) > 3 THEN 0.2
        ELSE 0
        END
    FROM [Order details] od
	JOIN Orders o ON od.OrderID=o.OrderID
    WHERE o.CustomerId = @CustomerId;
END

EXEC CalculateDiscount2 @CustomerID = 'ALFKI'

	