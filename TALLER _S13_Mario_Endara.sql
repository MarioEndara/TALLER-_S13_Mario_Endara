create database tienda2;
use tienda2;
-- 2. Crear la tabla Clientes
CREATE TABLE Clientes (
    ClienteID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100),
    Correoelectrónico VARCHAR(150),
    CerrarRegistrarse TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Clientes (Nombre, Apellido, Correoelectrónico)
VALUES ('Juan', 'Perez', 'juan.perez@email.com'),
	   ('Ana', 'Gómez', 'ana.gomez@email.com'),
	   ('Carlos', 'López', 'carlos.lopez@email.com');

       
-- 3. Crear la tabla Clientes_Auditoria
create table Clientes_Auditoria (
    ID_Auditoria INT AUTO_INCREMENT PRIMARY KEY,  
    ClienteID INT,  
    Accion VARCHAR(100),  
    Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP  
);
-- Trigger(Insertar)
DELIMITER $$
CREATE TRIGGER after_insert_cliente
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Clientes_Auditoria (ClienteID, Accion)
    VALUES (NEW.ClienteID, 'Cliente Insertado');
END $$
DELIMITER ;

INSERT INTO Clientes (Nombre, Apellido, Correoelectrónico)
VALUES ('Mario', 'Endara', 'me@gmail.com'),
	   ('Sofi', 'Guzman', 'sg@gmail.com');

select * from clientes;
select * from clientes_auditoria;

-- Trigger(Actualizar)

DELIMITER $$

CREATE TRIGGER after_update_cliente
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Clientes_Auditoria (ClienteID, Accion)
    VALUES (NEW.ClienteID, 'Datos de Cliente Actualizados');
END $$

DELIMITER ;

UPDATE Clientes
SET Nombre = 'Julio', Apellido = 'Salas'
WHERE ClienteID = 3;

select * from clientes;
select * from clientes_auditoria;

-- Trigger(Eliminar)
DELIMITER $$

CREATE TRIGGER after_delete_cliente
AFTER DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Clientes_Auditoria (ClienteID, Accion)
    VALUES (OLD.ClienteID, 'Cliente Eliminado');
END $$

DELIMITER ;

select * from clientes_auditoria;

-- Procedimiento almacenado
DELIMITER $$
CREATE PROCEDURE InsertarCliente(IN p_nombre VARCHAR(100), 
								 IN p_apellido VARCHAR(100), 
                                 IN p_email VARCHAR(150))
BEGIN
    INSERT INTO Clientes (Nombre, Apellido, Email)
    VALUES (p_nombre, p_apellido, p_email);
END $$
DELIMITER ;

CALL InsertarCliente('Pedro', 'Martínez', 'pedro.martinez@gmail.com');
select * from clientes;

-- Crear una transacción

START TRANSACTION;
-- Insertar un nuevo cliente
INSERT INTO Clientes (Nombre, Apellido, Email) 
VALUES ('José', 'Fernández', 'jose.fernandez@gmail.com');
-- Registrar la acción en la tabla de auditoría
INSERT INTO Clientes_Auditoria (ClienteID, Accion)
VALUES (LAST_INSERT_ID(), 'Cliente Insertado');

-- Si todo fue bien, hacer commit
COMMIT;
-- Crear una función

DELIMITER $$
CREATE FUNCTION CalcularAntiguedad_(P_ClienteID INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE antiguedad INT DEFAULT 0;  -- Definir un valor predeterminado para antigüedad en caso de error.
    -- Asegurarse de que la consulta devuelve un único valor.
    SELECT TIMESTAMPDIFF(YEAR, CerrarRegistrarse, NOW()) 
    INTO antiguedad
    FROM Clientes
    WHERE ClienteID = P_ClienteID
    -- LIMIT 1 asegura que se seleccione solo una fila en caso de que haya coincidencias.
    LIMIT 1;  
    -- Si no se encuentra el cliente, antigüedad será 0.
    IF antiguedad IS NULL THEN
        SET antiguedad = 0;
    END IF;
    RETURN antiguedad;
END $$
DELIMITER ;

-- Hacer una consulta
SELECT Nombre, Apellido, CalcularAntiguedad_(1) AS Antiguedad
FROM Clientes
WHERE ClienteID = 1;
-- Verificar el funcionamiento de los Triggers
SHOW TRIGGERS;







     
