"""
Little Lemon Database Client - Python MySQL Connector
Conecta ao banco LittleLemonDB, consulta clientes e executa os procedimentos armazenados.
"""

import mysql.connector as connector
from mysql.connector import Error


def create_connection():
    try:
        connection = connector.connect(
            host="localhost",
            user="root",
            password="your_password",
            database="LittleLemonDB"
        )
        if connection.is_connected():
            print("Conexão com LittleLemonDB estabelecida com sucesso.")
            return connection
    except Error as e:
        print(f"Erro ao conectar ao MySQL: {e}")
    return None


def setup_procedures(cursor):
    """Garante que os procedimentos armazenados existam no banco."""
    procedures = [
        "DROP PROCEDURE IF EXISTS GetMaxQuantity;",
        """
        CREATE PROCEDURE GetMaxQuantity()
        BEGIN
            SELECT MAX(Quantity) AS `Max Quantity in Order` FROM Orders;
        END
        """,
        "DROP PROCEDURE IF EXISTS ManageBooking;",
        """
        CREATE PROCEDURE ManageBooking(IN p_BookingDate DATE, IN p_TableNumber INT)
        BEGIN
            DECLARE v_Count INT DEFAULT 0;
            SELECT COUNT(*) INTO v_Count FROM Bookings
            WHERE BookingDate = p_BookingDate AND TableNumber = p_TableNumber;
            IF v_Count > 0 THEN
                SELECT CONCAT('Table ', p_TableNumber, ' is already booked') AS `Booking Status`;
            ELSE
                SELECT CONCAT('Table ', p_TableNumber, ' is available') AS `Booking Status`;
            END IF;
        END
        """,
        "DROP PROCEDURE IF EXISTS AddBooking;",
        """
        CREATE PROCEDURE AddBooking(IN p_BookingID INT, IN p_CustomerID INT, IN p_BookingDate DATE, IN p_TableNumber INT)
        BEGIN
            INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNumber)
            VALUES (p_BookingID, p_CustomerID, p_BookingDate, p_TableNumber);
            SELECT 'New booking added' AS Confirmation;
        END
        """,
        "DROP PROCEDURE IF EXISTS UpdateBooking;",
        """
        CREATE PROCEDURE UpdateBooking(IN p_BookingID INT, IN p_BookingDate DATE)
        BEGIN
            UPDATE Bookings SET BookingDate = p_BookingDate WHERE BookingID = p_BookingID;
            SELECT CONCAT('Booking ', p_BookingID, ' updated') AS Confirmation;
        END
        """,
        "DROP PROCEDURE IF EXISTS CancelBooking;",
        """
        CREATE PROCEDURE CancelBooking(IN p_BookingID INT)
        BEGIN
            DELETE FROM Bookings WHERE BookingID = p_BookingID;
            SELECT CONCAT('Booking ', p_BookingID, ' cancelled') AS Confirmation;
        END
        """
    ]
    for stmt in procedures:
        cursor.execute(stmt)


def run_demo():
    conn = create_connection()
    if not conn:
        return

    cursor = conn.cursor()

    # Exibir tabelas
    cursor.execute("SHOW TABLES;")
    print("Tabelas no banco:", [t[0] for t in cursor.fetchall()])

    # Consulta promocional: clientes com pedidos > $60
    promo_query = """
    SELECT c.FullName, c.ContactNumber, c.Email, o.TotalCost
    FROM Customers c
    INNER JOIN Orders o ON c.CustomerID = o.CustomerID
    WHERE o.TotalCost > 60;
    """
    cursor.execute(promo_query)
    print("\nClientes com pedidos acima de $60:")
    for row in cursor.fetchall():
        print(row)

    # Executar Stored Procedures
    print("\n--- Executando GetMaxQuantity() ---")
    cursor.callproc("GetMaxQuantity")
    for res in cursor.stored_results():
        print(res.fetchall())

    print("\n--- Executando ManageBooking('2022-10-10', 5) ---")
    cursor.callproc("ManageBooking", ("2022-10-10", 5))
    for res in cursor.stored_results():
        print(res.fetchall())

    print("\n--- Executando AddBooking(99, 1, '2022-12-25', 6) ---")
    cursor.callproc("AddBooking", (99, 1, "2022-12-25", 6))
    conn.commit()
    for res in cursor.stored_results():
        print(res.fetchall())

    print("\n--- Executando UpdateBooking(99, '2022-12-26') ---")
    cursor.callproc("UpdateBooking", (99, "2022-12-26"))
    conn.commit()
    for res in cursor.stored_results():
        print(res.fetchall())

    print("\n--- Executando CancelBooking(99) ---")
    cursor.callproc("CancelBooking", (99,))
    conn.commit()
    for res in cursor.stored_results():
        print(res.fetchall())

    cursor.close()
    conn.close()


if __name__ == "__main__":
    run_demo()
