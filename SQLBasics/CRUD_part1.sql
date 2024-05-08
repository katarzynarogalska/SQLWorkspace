-- utworzy� tabel� ArchivedOrders z tym samym zestawem kolumn, co tabela Orders, jak r�wnie� w tabeli tej:
--zdefiniowa� klucz podstawowy,
--zdefiniowa� klucze obce odnosz�ce si� do klient�w i pracownik�w,
--doda� kolumn� ArchiveDate datetime

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

--utworzy� tabel� ArchivedOrderDetails z tym samym zestawem kolumn co tabela [Order Details]
SELECT *
INTO ArchievedOrderDetails
FROM [Order Details]
WHERE 0=1;

--przenie�� wszystkie zam�wienia wykonane w 1996 roku do nowych tabel, tj.
-- usun�� dane tych zam�wie� z Orders i [Orders Details], (pominiemy, �eby nie modyfikowa� tabeli)
-- wstawi� dane w/w zam�wie� do ArchivedOrders oraz ArchivedOrderDetails,
-- ustawi� ArchiveDate na bie��c� dat�

INSERT INTO ArchievedOrders (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, IsCancelled)
SELECT CustomerID,EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry, IsCancelled FROM Orders WHERE year(OrderDate)=1996
UPDATE ArchievedOrders SET ArchieveDate = GETDATE()
SELECT * FROM ArchievedOrders

INSERT INTO ArchievedOrderDetails SELECT * FROM [Order Details] WHERE OrderID IN (SELECT OrderID FROM Orders o
																					WHERE year(OrderDate)=1996
																					AND o.OrderID = [Order Details].OrderID)
SELECT * FROM ArchievedOrderDetails

-- Przypisanie wszystkich zam�wie� nadzorowanych przez pracownika nr 1 pracownikowi nr 4
BEGIN TRANSACTION
SELECT OrderID,EmployeeID FROM Orders
UPDATE Orders SET EmployeeID = 4 WHERE EmployeeID=1
SELECT OrderID,EmployeeID FROM Orders
ROLLBACK;

-- Dla wszystkich zam�wie� z�o�onych po 15/05/1997 dla produktu Ikura nale�y zmniejszy� ilo��.
--Ilo�� nale�y zmniejszy� o 20% i zaokr�gli� do najbli�szej liczby ca�kowitej.
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

--Znajd� identyfikator ostatniego zam�wienia z�o�onego przez klienta ALFKI, kt�re nie obejmuje produktu Chocolade
--Znajd� identyfikator produktu Chocolade
DECLARE @Last_alfki_order int
DECLARE @chocolade_id int

SELECT @chocolade_id = ProductID FROM Products WHERE ProductName='Chocolade'

SELECT TOP 1 @Last_alfki_order = o.OrderID FROM Orders o 
WHERE o.OrderID NOT IN (SELECT OrderID FROM [Order Details] od
						WHERE od.ProductID=@chocolade_id)
AND o.CustomerID ='ALFKI'
ORDER BY o.OrderDate DESC

-- Dodaj Chocolade do listy produkt�w zam�wionych w ramach tego zam�wienia, z ilo�ci� r�wn� 1
DECLARE @chocolade_price money
SELECT @chocolade_price = UnitPrice FROM Products WHERE ProductID = @chocolade_id

BEGIN TRANSACTION
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount) VALUES (@Last_alfki_order, @chocolade_id, @chocolade_price,1,0)
ROLLBACK

--Dodaj produkt Chocolade do wszystkich zam�wie� z�o�onych przez klienta ALFKI, kt�re jeszcze nie zawieraj� tego produktu
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

--Usu� dane wszystkich kontrahent�w, kt�rzy nie z�o�yli �adnych zam�wie�
SELECT c.CustomerID FROM Customers c  -- klienci, kt�rzy nie z�o�yli �adnych zam�wie�
WHERE NOT EXISTS (SELECT * FROM Orders o WHERE o.CustomerID=c.CustomerID)

BEGIN TRANSACTION
SELECT CustomerID FROM Customers
DELETE FROM Customers WHERE NOT EXISTS (SELECT * FROM Orders o WHERE o.CustomerID=Customers.CustomerID)
SELECT CustomerID FROM Customers -- check for changes
ROLLBACK