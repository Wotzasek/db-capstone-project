# Little Lemon Database & Data Analysis Capstone Project

Este repositório contém todos os artefatos desenvolvidos para o projeto final (**Database Engineer Capstone**):

## Arquivos Incluídos
1. **`LittleLemonDB.sql`**: Script completo de criação do banco de dados normalizado (`Customers`, `Staff`, `Bookings`, `MenuItems`, `Menus`, `Orders`, `OrderDeliveryStatus`), dados de exemplo e os 5 procedimentos armazenados obrigatórios:
   - `GetMaxQuantity()`
   - `ManageBooking(BookingDate, TableNumber)`
   - `AddBooking(BookingID, CustomerID, BookingDate, TableNumber)`
   - `UpdateBooking(BookingID, BookingDate)`
   - `CancelBooking(BookingID)`
2. **`little_lemon_client.py`**: Cliente Python utilizando `mysql-connector-python` para conexão com o banco, execução de consultas e chamada dos procedimentos armazenados.
3. **`LittleLemon_ER_Diagram.png`**: Diagrama Entidade-Relacionamento (ER) ilustrando todas as tabelas, chaves primárias (`PK`), chaves estrangeiras (`FK`) e cardinalidades.
4. **`Tableau_Analysis_Charts.png`**: Captura das visualizações e painel analítico construídos a partir da planilha `LittleLemon_data.xlsx`.
