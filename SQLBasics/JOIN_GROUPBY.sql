-- Zad1: Ustalenie ³¹cznej iloœci ka¿dego produktu dostarczonej do poszczególnych krajów
--przez pracownika nr 2. Wynik powinien zawieraæ nastêpuj¹ce kolumny:
-- ProductId, ShipCountry, TotalQuantity

SELECT od.ProductID, o.ShipCountry, SUM(od.Quantity) AS TotalQuantity
FROM Orders o
JOIN [Order Details] od ON o.OrderID=od.OrderID
WHERE o.EmployeeID=2
GROUP BY od.ProductID, o.ShipCountry

--Zad2: Ustalenie listy pracowników, z których ka¿dy sprzeda³ ³¹cznie
--co najmniej100 sztuk produktu Chocolade w roku 1998
--Wynik powinien zawieraæ nastêpuj¹ce kolumny:
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


--Zad3: Wymieñ wszystkie produkty, które zosta³y zamówione przez klientów z W³och, 
--takie, ¿e œrednio co najmniej 20 sztuk tegoproduktu zosta³o zamówionych 
--w pojedynczym zamówieniuz³o¿onym przez danego klienta. U³ó¿ wyniki w kolejnoœci
--malej¹cej sumarycznej liczby zamówieñ z³o¿onej przez klienta na dany produkt.
SELECT p.ProductID, AVG(od.Quantity) as AverageAmount
FROM Orders o 
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
JOIN Customers c ON o.CustomerID=c.CustomerID
WHERE c.Country='Italy'
GROUP BY o.OrderID, p.ProductID
HAVING AVG(od.Quantity)>=20
ORDER BY COUNT(o.OrderID) DESC


--Zad4: Wymieñ wszystkich klientów z Berlina i zamówione przez nich produkty.
--Wynik zapytania powinien zawieraæ nastêpuj¹ce kolumny:
--CustomerName, ProductName, OrderDate, Quantity.
--Posortuj wynik w kolejnoœci CustomerName, ProductName, OrderDate

SELECT c.CompanyName AS CustomerName, p.ProductName, o.OrderDate, SUM(od.Quantity) as Quantity
FROM Orders o
JOIN Customers c On o.CustomerID=c.CustomerID
JOIN [Order Details] od ON od.OrderID=o.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE c.City='Berlin' 
GROUP BY c.CompanyName, p.ProductName, o.OrderDate

--Zad5: Wymieñ wszystkie produkty, które zosta³y dostarczone do Francji w 1998 roku
SELECT DISTINCT p.ProductName
FROM Products p 
JOIN [Order Details] od ON p.ProductID=od.ProductID
JOIN Orders o ON od.OrderID=o.OrderID
WHERE o.ShipCountry='France' AND year(o.ShippedDate)=1998

--Zad6: Wymieñ wszystkich klientów, którzy z³o¿yli co najmniej dwa
--zamówienia, ale nigdy nie zamówili produktów o nazwachzaczynaj¹cych siê od „Ravioli'
SELECT c.CompanyName, COUNT(o.OrderID) as OrderNumber
FROM Customers c
JOIN Orders o ON c.CustomerID=o.CustomerID
WHERE c.CustomerID NOT IN (SELECT o.CustomerID FROM Orders o
							JOIN [Order Details] od ON o.OrderID=od.OrderID
							JOIN Products p ON od.ProductID=p.ProductID
							WHERE p.ProductName LIKE 'Ravioli%')
GROUP BY c.CompanyName
HAVING COUNT(o.OrderID)>=2


--Zad7: najdŸ wszystkie zamówienia zawieraj¹ce co najmniej 4 ró¿neprodukty
--i z³o¿one przez klientów z Francji. Wynik powinien zawieraæ nastêpuj¹ce kolumny:
--CompanyName, OrderId, ProductCount

SELECT c.CompanyName, o.OrderID, COUNT(p.ProductID) as ProductCount
FROM Orders o 
JOIN Customers c ON o.CustomerID=c.CustomerID
JOIN [Order Details] od ON o.OrderID=od.OrderID
JOIN Products p ON od.ProductID=p.ProductID
WHERE c.Country='France'
GROUP BY c.CompanyName, o.OrderID
HAVING COUNT(p.ProductID)>=4


-- Zad8: Wymieñ wszystkich klientów, którzy z³o¿yli co najmniej piêæ
--zamówieñ wys³anych do Francji, ale nie wiêcej ni¿ 2zamówienia wys³ane do Belgii.
--Wynik powinien zawieraæ jedn¹ kolumnê: CompanyName
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

