-- Zad1: Ustalenie ��cznej ilo�ci ka�dego produktu dostarczonej do poszczeg�lnych kraj�w
--przez pracownika nr 2. Wynik powinien zawiera� nast�puj�ce kolumny:
-- ProductId, ShipCountry, TotalQuantity

SELECT od.ProductID, o.ShipCountry, SUM(od.Quantity) AS TotalQuantity
FROM Orders o
JOIN [Order Details] od ON o.OrderID=od.OrderID
WHERE o.EmployeeID=2
GROUP BY od.ProductID, o.ShipCountry

--Zad2: Ustalenie listy pracownik�w, z kt�rych ka�dy sprzeda� ��cznie
--co najmniej100 sztuk produktu Chocolade w roku 1998
--Wynik powinien zawiera� nast�puj�ce kolumny:
--EmployeeName, EmployeeSurname, TotalQuantity

SELECT e.FirstName AS EmployeeName, e.LastName AS EmployeeSurname, SUM(od.Quantity) AS TotalQuantity
FROM Orders o 
JOIN Employees e ON o.EmployeeID=e.EmployeeID
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p On od.ProductID=p.ProductID
WHERE year(o.OrderDate)=1998
AND p.ProductName='Chocolade'
GROUP BY e.FirstName, e.LastName
HAVING SUM(od.Quantity)>=100


--Zad3: Wymie� wszystkie produkty, kt�re zosta�y zam�wione przez klient�w z W�och, 
--takie, �e �rednio co najmniej 20 sztuk tegoproduktu zosta�o zam�wionych 
--w pojedynczym zam�wieniuz�o�onym przez danego klienta. U�� wyniki w kolejno�ci
--malej�cej sumarycznej liczby zam�wie� z�o�onej przez klienta na dany produkt.
SELECT p.ProductID, AVG(od.Quantity) as AverageAmount
FROM Orders o 
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country='Italy'
GROUP BY o.OrderID, p.ProductID
HAVING AVG(od.Quantity)>=20
ORDER BY COUNT(o.OrderID) DESC


--Zad4: Wymie� wszystkich klient�w z Berlina i zam�wione przez nich produkty.
--Wynik zapytania powinien zawiera� nast�puj�ce kolumny:
--CustomerName, ProductName, OrderDate, Quantity.
--Posortuj wynik w kolejno�ci CustomerName, ProductName, OrderDate

SELECT c.CompanyName AS CustomerName, p.ProductName, o.OrderDate, SUM(od.Quantity) as Quantity
FROM Orders o
JOIN Customers c On o.CustomerID=c.CustomerID
JOIN [Order Details] od ON od.OrderID=o.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE c.City='Berlin' 
GROUP BY c.CompanyName, p.ProductName, o.OrderDate

--Zad5: Wymie� wszystkie produkty, kt�re zosta�y dostarczone do Francji w 1998 roku
SELECT DISTINCT p.ProductName
FROM Products p 
JOIN [Order Details] od ON p.ProductID=od.ProductID
JOIN Orders o ON od.OrderID=o.OrderID
WHERE o.ShipCountry='France' AND year(o.ShippedDate)=1998

--Zad6: Wymie� wszystkich klient�w, kt�rzy z�o�yli co najmniej dwa
--zam�wienia, ale nigdy nie zam�wili produkt�w o nazwachzaczynaj�cych si� od �Ravioli'
SELECT c.CompanyName, COUNT(o.OrderID) as OrderNumber
FROM Customers c
JOIN Orders o ON c.CustomerID=o.CustomerID
WHERE c.CustomerID NOT IN (SELECT o.CustomerID FROM Orders o
							JOIN [Order Details] od ON o.OrderID=od.OrderID
							JOIN Products p ON od.ProductID=p.ProductID
							WHERE p.ProductName LIKE 'Ravioli%')
GROUP BY c.CompanyName
HAVING COUNT(o.OrderID)>=2


--Zad7: najd� wszystkie zam�wienia zawieraj�ce co najmniej 4 r�neprodukty
--i z�o�one przez klient�w z Francji. Wynik powinien zawiera� nast�puj�ce kolumny:
--CompanyName, OrderId, ProductCount

SELECT c.CompanyName, o.OrderID, COUNT(p.ProductID) as ProductCount
FROM Orders o 
JOIN Customers c ON o.CustomerID=c.CustomerID
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE c.Country='France'
GROUP BY c.CompanyName, o.OrderID
HAVING COUNT(p.ProductID)>=4


-- Zad8: Wymie� wszystkich klient�w, kt�rzy z�o�yli co najmniej pi��
--zam�wie� wys�anych do Francji, ale nie wi�cej ni� 2zam�wienia wys�ane do Belgii.
--Wynik powinien zawiera� jedn� kolumn�: CompanyName
SELECT c.CompanyName 
FROM Customers c
JOIN Orders o On c.CustomerID=o.CustomerID
WHERE o.ShipCountry='France'
AND c.CustomerID IN (SELECT c1.CustomerID FROM Customers c1
					JOIN Orders o1 ON o1.CustomerID=c1.CustomerID
					WHERE o1.ShipCountry='Belgium' 
					GROUP BY c1.CustomerID
					HAVING COUNT(o1.OrderID)<2)
GROUP BY c.CustomerID, c.CompanyName
HAVING COUNT(o.OrderID)>=5

