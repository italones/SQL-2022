	-- Создание базы данных
CREATE DATABASE HomeworkDB;
GO
USE HomeworkDB;
GO

-- Создание файловых групп
ALTER DATABASE HomeworkDB ADD FILEGROUP FG_Data;
GO
ALTER DATABASE HomeworkDB ADD FILEGROUP FG_Index;
GO

-- Создание таблиц в файловых группах
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL
) ON FG_Data;
GO

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    CategoryID INT NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
) ON FG_Data;
GO

-- Вычисляемый столбец
ALTER TABLE Products 
ADD TotalPrice AS (Price * Quantity);
GO

-- Индексы
CREATE NONCLUSTERED INDEX IX_Products_ProductName 
ON Products(ProductName) ON FG_Index;
GO

-- Хранимая процедура
CREATE PROCEDURE usp_AddProduct
    @Name NVARCHAR(100),
    @Price DECIMAL(10, 2),
    @Quantity INT,
    @CategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Products (ProductName, Price, Quantity, CategoryID)
    VALUES (@Name, @Price, @Quantity, @CategoryID);
END;
GO

-- Тестирование
INSERT INTO Categories (CategoryName) VALUES ('Электроника');
EXEC usp_AddProduct @Name = 'Ноутбук', @Price = 1200.00, @Quantity = 5, @CategoryID = 1;
EXEC usp_AddProduct @Name = 'Мышь', @Price = 25.50, @Quantity = 10, @CategoryID = 1;

SELECT * FROM Products;
GO

-- Проверка индексов
SELECT name, type_desc FROM sys.indexes WHERE object_id = OBJECT_ID('Products');
GO