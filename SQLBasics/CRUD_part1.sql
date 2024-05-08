-- utworzyæ tabelê ArchivedOrders z tym samym zestawem kolumn, co tabela Orders, jak równie¿ w tabeli tej:
--zdefiniowaæ klucz podstawowy,
--zdefiniowaæ klucze obce odnosz¹ce siê do klientów i pracowników,
--dodaæ kolumnê ArchiveDate datetime

SELECT * 
INTO ArchievedOrders
FROM Orders 
WHERE 0=1;

ALTER TABLE ArchievedOrders -- set primary key
ADD CONSTRAINT pk PRIMARY KEY (OrderID)

ALTER TABLE ArchievedOrders --set foreign keys
ADD CONSTRAINT fk1 FOREIGN KEY (CustomerID)
REFERENCES Customers(CustomerID)

ALTER TABLE ArchievedOrders
ADD CONSTRAINT fk2 FOREIGN KEY (EmployeeID)
REFERENCES Employees(EmployeeID)

ALTER TABLE ArchievedOrders --add new column
ADD ArchieveDate datetime

SELECT * FROM ArchievedOrders --check

--utworzyæ tabelê ArchivedOrderDetails z tym samym zestawem kolumn co tabela [Order Details]
SELECT *
INTO ArchievedOrderDetails
FROM [Order Details]
WHERE 0=1;

--przenieœæ wszystkie zamówienia wykonane w 1996 roku do nowych tabel, tj.
-- usun¹æ dane tych zamówieñ z Orders i [Orders Details], (pominiemy, ¿eby nie modyfikowaæ tabeli)
-- wstawiæ dane w/w zamówieñ do ArchivedOrders oraz ArchivedOrderDetails,
-- ustawiæ ArchiveDate na bie¿¹c¹ datê

INSERT INTO ArchievedOrders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, IsCancelled)
SELECT CustomerID,EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, IsCancelled FROM Orders WHERE year(OrderDate)=1996
UPDATE ArchievedOrders SET ArchieveDate = GETDATE()
SELECT * FROM ArchievedOrders

INSERT INTO ArchievedOrderDetails SELECT * FROM [Order Details] WHERE OrderID IN (SELECT OrderID FROM Orders o
																					WHERE year(OrderDate)=1996
																					AND o.OrderID = [Order Details].OrderID)
SELECT * FROM ArchievedOrderDetails

-- Przypisanie wszystkich zamówieñ nadzorowanych przez pracownika nr 1 pracownikowi nr 4
BEGIN TRANSACTION
SELECT OrderID,EmployeeID FROM Orders
UPDATE Orders SET EmployeeID = 4 WHERE EmployeeID=1
SELECT OrderID,EmployeeID FROM Orders
ROLLBACK;

-- Dla wszystkich zamówieñ z³o¿onych po 15/05/1997 dla produktu Ikura nale¿y zmniejszyæ iloœæ.
--Iloœæ nale¿y zmniejszyæ o 20% i zaokr¹gliæ do najbli¿szej liczby ca³kowitej.
BEGIN TRANSACTION
SELECT Quantity FROM [Order Details] WHERE OrderID IN (SELECT OrderID FROM Orders o 
					WHERE OrderDate>'1997-05-15')
AND ProductID IN (SELECT ProductID FROM Products
					WHERE ProductName='Ikura')

UPDATE [Order Details] SET Quantity = round(0.8*Quantity,0)
WHERE OrderID IN (SELECT OrderID FROM Orders o 
					WHERE OrderDate>'1997-05-15')
AND ProductID IN (SELECT ProductID FROM Products
					WHERE ProductName='Ikura')

SELECT Quantity FROM [Order Details] WHERE OrderID IN (SELECT OrderID FROM Orders o --checking the change
					WHERE OrderDate>'1997-05-15')
AND ProductID IN (SELECT ProductID FROM Products
					WHERE ProductName='Ikura')
ROLLBACK;

--ZnajdŸ identyfikator ostatniego zamówienia z³o¿onego przez klienta ALFKI, które nie obejmuje produktu Chocolade
--ZnajdŸ identyfikator produktu Chocolade
DECLARE @Last_alfki_order int
DECLARE @chocolade_id int

SELECT @chocolade_id = ProductID FROM Products WHERE ProductName='Chocolade'

SELECT TOP 1 @Last_alfki_order = o.OrderID FROM Orders o 
WHERE o.OrderID NOT IN (SELECT OrderID FROM [Order Details] od
						WHERE od.ProductID=@chocolade_id)
AND o.CustomerID ='ALFKI'
ORDER BY o.OrderDate DESC

-- Dodaj Chocolade do listy produktów zamówionych w ramach tego zamówienia, z iloœci¹ równ¹ 1
DECLARE @chocolade_price money
SELECT @chocolade_price = UnitPrice FROM Products WHERE ProductID = @chocolade_id

BEGIN TRANSACTION
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount) VALUES (@Last_alfki_order, @chocolade_id, @chocolade_price,1,0)
ROLLBACK

--Dodaj produkt Chocolade do wszystkich zamówieñ z³o¿onych przez klienta ALFKI, które jeszcze nie zawieraj¹ tego produktu
--gdzie nie ma czekolady
SELECT o.OrderID FROM Orders o 
WHERE o.CustomerID='ALFKI'
AND o.OrderID NOT IN (SELECT od.OrderID FROM [Order Details] od
						WHERE od.ProductID = @chocolade_id)

BEGIN TRANSACTION  -- dodanie do tych Orders czekolade
INSERT INTO [Order Details] SELECT o.OrderID,@chocolade_id,@chocolade_price,1,0 FROM Orders o 
WHERE o.CustomerID='ALFKI'
AND o.OrderID NOT IN (SELECT od.OrderID FROM [Order Details] od
						WHERE od.ProductID = @chocolade_id) 
ROLLBACK

--Usuñ dane wszystkich kontrahentów, którzy nie z³o¿yli ¿adnych zamówieñ
SELECT c.CustomerID FROM Customers c  -- klienci, którzy nie z³o¿yli ¿adnych zamówieñ
WHERE NOT EXISTS (SELECT * FROM Orders o WHERE o.CustomerID=c.CustomerID)

BEGIN TRANSACTION
SELECT CustomerID FROM Customers
DELETE FROM Customers WHERE NOT EXISTS (SELECT * FROM Orders o WHERE o.CustomerID=Customers.CustomerID)
SELECT CustomerID FROM Customers -- check for changes
ROLLBACK