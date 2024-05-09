-- Sprawdzenie ³¹cznej iloœci zamówionego produktu Chocolade w roku 1997
SELECT SUM(Quantity) FROM [Order Details] od
JOIN Products p ON od.ProductID=p.ProductID
JOIN Orders o ON o.OrderID=od.OrderID
WHERE p.ProductName='Chocolade'
AND year(o.OrderDate)=1997       --wynik: 130

--Dodanie nowego produktu o nazwie „Programming in Java” do tabeli produktów
INSERT INTO Products (ProductName) VALUES ('Programming in Java')
SELECT * FROM Products  -- dodano

--Zwiêkszenie iloœci zamówionego produktu Chocolade w zamówieniach z roku 1997
DECLARE @chocolade_id int
SELECT @chocolade_id= ProductID FROM Products WHERE ProductName='Chocolade'

BEGIN TRANSACTION
UPDATE [Order Details] SET Quantity = Quantity+1
WHERE OrderID IN (SELECT o.OrderID FROM Orders o 
					WHERE year(o.OrderDate)=1997)
AND ProductID=@chocolade_id

SELECT SUM(Quantity) FROM [Order Details] od --sprawdzenie : teraz suma = 135
JOIN Products p ON od.ProductID=p.ProductID
JOIN Orders o ON o.OrderID=od.OrderID
WHERE p.ProductName='Chocolade'
AND year(o.OrderDate)=1997

ROLLBACK

-- Dwukrotne zwiêkszenie iloœci produktu Chocolade w zamówieniach z³o¿onych w roku 1997
BEGIN TRANSACTION

UPDATE [Order Details] SET Quantity=2*Quantity
WHERE OrderID IN (SELECT OrderID FROM Orders WHERE year(OrderDate)=1997)
AND ProductID=@chocolade_id

SELECT SUM(Quantity) FROM [Order Details] od --sprawdzenie : teraz suma = 260 czyli 130*2 zgadza siê
JOIN Products p ON od.ProductID=p.ProductID
JOIN Orders o ON o.OrderID=od.OrderID
WHERE p.ProductName='Chocolade'
AND year(o.OrderDate)=1997
ROLLBACK

-- Sprawdzenie ³¹cznej iloœci zamówionego produktu Ikura
SELECT SUM(Quantity) FROM [Order Details] od
JOIN Products p ON od.ProductID=p.ProductID
WHERE p.ProductName='Ikura'  -- wynik: 1088

-- Usuniêcie zamówieñ nie zawieraj¹cych produktu Chocolade
BEGIN TRANSACTION
SELECT COUNT(OrderID) FROM [Order Details] od  -- liczba zamówieñ bez czekolady : 2115
WHERE od.OrderID NOT IN (SELECT OrderID FROM [Order Details] od
						JOIN Products p ON p.ProductID=od.ProductID
						WHERE p.ProductName='Chocolade')

DELETE FROM [Order Details] WHERE [Order Details].OrderID NOT IN (SELECT OrderID FROM [Order Details] od
						JOIN Products p ON p.ProductID=od.ProductID
						WHERE p.ProductName='Chocolade')

SELECT COUNT(OrderID) FROM [Order Details] od  -- liczba zamówieñ bez czekolady : 0 zgadza siê
WHERE od.OrderID NOT IN (SELECT OrderID FROM [Order Details] od
						JOIN Products p ON p.ProductID=od.ProductID
						WHERE p.ProductName='Chocolade')

ROLLBACK

-- Dodanie produktu Ikura do zamówieñ, które go nie zawieraj¹
DECLARE @Ikura_id int
SELECT @Ikura_id =ProductID FROM Products WHERE ProductName='Ikura'

DECLARE @Ikura_price money
SELECT @Ikura_price= UnitPrice FROM Products WHERE ProductName='Ikura'

BEGIN TRANSACTION
INSERT INTO [Order Details] SELECT OrderID, @Ikura_id, @Ikura_price,1,0  FROM Orders
WHERE OrderID NOT IN (SELECT OrderID FROM [Order Details] od
					JOIN Products p ON p.ProductID=od.ProductID
					WHERE p.ProductName='Ikura')

SELECT SUM(Quantity) FROM [Order Details] od
JOIN Products p ON od.ProductID=p.ProductID
WHERE p.ProductName='Ikura'  -- teraz mamy 1885, czyli wzros³o

ROLLBACK

-- Dwukrotne zwiêkszenie iloœci produktu Ikura w zamówieniach z³o¿onych w roku 1997
BEGIN TRANSACTION
UPDATE [Order Details] SET Quantity = 2*Quantity
WHERE OrderID IN (SELECT OrderID FROM Orders WHERE year(OrderDate)=1997)
AND ProductID = @Ikura_id
ROLLBACK

-- Istnieje potrzeba uaktualnienia modelu danych. W tym celu proszê:

--zmieniæ rozmiar kolumny CompanyName w tabeli Customers na 150 znaków
ALTER TABLE Customers ALTER COLUMN CompanyName nvarchar(150);

--dodaæ kolumnê TotalOrderCount do tabeli Customers i wype³niæ j¹ odpowiednimi wartoœciami tzn. liczb¹ zamówieñ z³o¿onych przez danego klienta
ALTER TABLE Customers ADD TotalOrderCount int;
BEGIN TRANSACTION
UPDATE Customers SET TotalOrderCount =( SELECT COUNT(OrderID) FROM Orders WHERE Orders.CustomerID=Customers.CustomerID)

SELECT * FROM Customers
ROLLBACK

--dodaæ kolumnê IsCancelled int do tabeli Products i ustawiæ w/w kolumnê na 1 dla wszystkich rekordów Products, które nie zosta³y zamówione od 01/01/1997
ALTER TABLE Products ADD IsCancelled int;

UPDATE Products SET IsCancelled = (SELECT CASE 
									WHEN NOT EXISTS (SELECT * FROM Orders o 
													JOIN [Order Details] od ON o.OrderID=od.OrderID
													WHERE o.OrderDate>'1997-01-01'
													AND od.ProductID=Products.ProductID)
									THEN 1
									ELSE 0
									END)
SELECT * FROM Products
							 
