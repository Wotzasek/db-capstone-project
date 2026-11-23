-- ============================================================================
-- Little Lemon Database Schema & Stored Procedures (Meta Database Engineer Capstone)
-- ============================================================================

DROP DATABASE IF EXISTS LittleLemonDB;
CREATE DATABASE LittleLemonDB;
USE LittleLemonDB;

-- ----------------------------------------------------------------------------
-- 1. Tabelas Principais (Modelo Relacional Normalizado)
-- ----------------------------------------------------------------------------

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(45) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL,
    Role VARCHAR(100) NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    TableNumber INT NOT NULL,
    CustomerID INT NOT NULL,
    StaffID INT NULL,
    CONSTRAINT fk_bookings_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bookings_staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE MenuItems (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    StarterName VARCHAR(100) NOT NULL,
    DesertName VARCHAR(100) NOT NULL,
    DrinkName VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Menus (
    MenuID INT AUTO_INCREMENT PRIMARY KEY,
    MenuName VARCHAR(100) NOT NULL,
    Cuisine VARCHAR(100) NOT NULL,
    MenuItemID INT NOT NULL,
    CONSTRAINT fk_menus_menuitem FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    Quantity INT NOT NULL,
    TotalCost DECIMAL(10, 2) NOT NULL,
    BookingID INT NULL,
    CustomerID INT NOT NULL,
    MenuID INT NOT NULL,
    CONSTRAINT fk_orders_booking FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orders_menu FOREIGN KEY (MenuID) REFERENCES Menus(MenuID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE OrderDeliveryStatus (
    DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
    DeliveryDate DATE NULL,
    Status VARCHAR(50) NOT NULL,
    OrderID INT NOT NULL,
    CONSTRAINT fk_delivery_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 2. Dados de Exemplo para Teste
-- ----------------------------------------------------------------------------

INSERT INTO Customers (FullName, ContactNumber, Email) VALUES
('Anna Iversen', '555-0101', 'anna.iversen@example.com'),
('Joakim Iversen', '555-0102', 'joakim.iversen@example.com'),
('Vanessa McCarthy', '555-0103', 'vanessa.mccarthy@example.com'),
('Marcos Romero', '555-0104', 'marcos.romero@example.com'),
('Hiroki Yamane', '555-0105', 'hiroki.yamane@example.com');

INSERT INTO Staff (FullName, Role, Salary) VALUES
('Mario Gollini', 'Manager', 70000.00),
('Adrian Gollini', 'Assistant Manager', 65000.00),
('Giorgos Dioudis', 'Head Chef', 50000.00),
('Fatma Kaya', 'Assistant Chef', 45000.00),
('Elena Salvai', 'Head Waiter', 40000.00);

INSERT INTO Bookings (BookingDate, TableNumber, CustomerID, StaffID) VALUES
('2022-10-10', 5, 1, 1),
('2022-11-12', 3, 3, 2),
('2022-10-11', 2, 2, 1),
('2022-10-13', 2, 1, 5);

INSERT INTO MenuItems (CourseName, StarterName, DesertName, DrinkName, Price) VALUES
('Greek Salad', 'Olives', 'Greek Yoghurt', 'Athens White Wine', 45.00),
('Bean Soup', 'Flatbread', 'Ice Cream', 'Corfu Red Wine', 40.00),
('Pizza', 'Minestrone', 'Cheesecake', 'Italian Coffee', 55.00),
('Carbonara', 'Tomato Bread', 'Affogato', 'Roma Red Wine', 60.00),
('Kabasa', 'Falafel', 'Baklava', 'Turkish Coffee', 50.00);

INSERT INTO Menus (MenuName, Cuisine, MenuItemID) VALUES
('Moussaka', 'Greek', 1),
('Manti', 'Turkish', 5),
('Aperitivo', 'Italian', 3),
('Trattoria', 'Italian', 4),
('Aegean', 'Greek', 2);

INSERT INTO Orders (OrderDate, Quantity, TotalCost, BookingID, CustomerID, MenuID) VALUES
('2022-10-10', 2, 90.00, 1, 1, 1),
('2022-11-12', 3, 165.00, 2, 3, 3),
('2022-10-11', 1, 50.00, 3, 2, 2),
('2022-10-13', 4, 240.00, 4, 1, 4),
('2022-10-14', 5, 225.00, 1, 5, 1);

INSERT INTO OrderDeliveryStatus (DeliveryDate, Status, OrderID) VALUES
('2022-10-10', 'Delivered', 1),
('2022-11-12', 'Delivered', 2),
('2022-10-11', 'Preparing', 3),
('2022-10-13', 'Delivered', 4),
('2022-10-14', 'Delivered', 5);

-- ----------------------------------------------------------------------------
-- 3. Stored Procedures Exigidos na Avaliação
-- ----------------------------------------------------------------------------

DELIMITER //

-- Procedimento 1: GetMaxQuantity()
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS `Max Quantity in Order`
    FROM Orders;
END //

-- Procedimento 2: ManageBooking()
CREATE PROCEDURE ManageBooking(IN p_BookingDate DATE, IN p_TableNumber INT)
BEGIN
    DECLARE v_BookingCount INT DEFAULT 0;

    SELECT COUNT(*) INTO v_BookingCount
    FROM Bookings
    WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;

    IF v_BookingCount > 0 THEN
        SELECT CONCAT('Table ', p_TableNumber, ' is already booked') AS `Booking Status`;
    ELSE
        SELECT CONCAT('Table ', p_TableNumber, ' is available') AS `Booking Status`;
    END IF;
END //

-- Procedimento 3: AddBooking()
CREATE PROCEDURE AddBooking(
    IN p_BookingID INT,
    IN p_CustomerID INT,
    IN p_BookingDate DATE,
    IN p_TableNumber INT
)
BEGIN
    INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNumber)
    VALUES (p_BookingID, p_CustomerID, p_BookingDate, p_TableNumber);

    SELECT 'New booking added' AS Confirmation;
END //

-- Procedimento 4: UpdateBooking()
CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_BookingDate DATE
)
BEGIN
    UPDATE Bookings
    SET BookingDate = p_BookingDate
    WHERE BookingID = p_BookingID;

    SELECT CONCAT('Booking ', p_BookingID, ' updated') AS Confirmation;
END //

-- Procedimento 5: CancelBooking()
CREATE PROCEDURE CancelBooking(
    IN p_BookingID INT
)
BEGIN
    DELETE FROM Bookings
    WHERE BookingID = p_BookingID;

    SELECT CONCAT('Booking ', p_BookingID, ' cancelled') AS Confirmation;
END //

DELIMITER ;

-- Testes rápidos dos procedimentos:
-- CALL GetMaxQuantity();
-- CALL ManageBooking('2022-10-10', 5);
-- CALL AddBooking(9, 3, '2022-12-30', 4);
-- CALL UpdateBooking(9, '2022-12-31');
-- CALL CancelBooking(9);
