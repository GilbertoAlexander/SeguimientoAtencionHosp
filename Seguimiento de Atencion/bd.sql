DROP DATABASE IF EXISTS  seguimiento;
CREATE DATABASE seguimiento;
USE seguimiento;

CREATE TABLE personal
(
idpersona INT AUTO_INCREMENT NOT NULL,
nombres VARCHAR(50) NOT NULL,
apellidos VARCHAR(50)NOT NULL,
correo VARCHAR(50) NOT NULL,
tel INT(11) NOT NULL,
sexo VARCHAR(1) NOT NULL,
dni INT(8) NOT NULL,
nacionalidad VARCHAR (20),
CONSTRAINT pk_idpersona PRIMARY KEY(idpersona)
);

CREATE TABLE usuario
(
idpersona INT NOT NULL,
nombre VARCHAR(50) NOT NULL,
contrasenia VARCHAR(100) NOT NULL,
CONSTRAINT pk_usuario PRIMARY KEY(idpersona)
);

CREATE TABLE registro
(
idregistro INT AUTO_INCREMENT NOT NULL,
idpersona INT NOT NULL,
tipo CHAR(1) NOT NULL,
dia VARCHAR(12) NOT NULL,
hora TIME NOT NULL,
fecha_creacion DATETIME NOT NULL,
CONSTRAINT pk_registro PRIMARY KEY(idregistro)
);

###############ESTABLECEMOS LA RELACION ENTRE LA TABLA USUARIO Y LA TABLA PERSONAL#########################
ALTER TABLE usuario ADD CONSTRAINT fk_usuario_persona FOREIGN KEY(idpersona) REFERENCES personal(idpersona);

###############ESTABLECEMOS LA RELACION ENTRE LA TABLA REGISTRO Y LA TABLA PERSONA#########################
ALTER TABLE registro ADD CONSTRAINT fk_registro_persona FOREIGN KEY(idpersona) REFERENCES personal(idpersona);


INSERT INTO personal VALUES (NULL,'Gilberto','De La Cruz','alexander_96.05@outlook.com', '937040520', 'H', '75850297', 'peruana');


INSERT INTO usuario VALUES (1,'gds','321');

######################PROCEDIMIENTO ALMACENADO PARA VALIDAR USUARIO ######################################
DELIMITER $$
CREATE PROCEDURE up_usuario
(
IN _nombre VARCHAR(50),
IN _contrasenia VARCHAR(100)
)
BEGIN
SELECT * FROM usuario WHERE nombre=_nombre AND contrasenia=_contrasenia;
END
$$

################PROCEDIMIENTO ALMACENADO DE PERSONAL##########################################
DELIMITER $$
CREATE PROCEDURE up_persona_insertar
(
IN _nombres VARCHAR(50),
IN _apellidos VARCHAR(50),
IN _correo VARCHAR(50),
IN _tel INT (11),
IN _dni INT (8),
IN _sexo VARCHAR (1),
IN _nacionalidad VARCHAR(20)
)
BEGIN
INSERT INTO personal (nombres, apellidos, correo, tel, dni, sexo, nacionalidad) VALUES(_nombres, _apellidos, _correo, _tel, _dni, _sexo, _nacionalidad);
END
$$


################PROCEDIMIENTO ALMACENADO PARA LISTAR PERSONAL##########################################
DELIMITER $$
CREATE PROCEDURE up_persona_listar
(
)
BEGIN
SELECT idpersona, nombres, apellidos, correo, tel, dni, sexo, nacionalidad FROM personal ORDER BY apellidos ASC;
END
$$

DELIMITER $$
CREATE PROCEDURE up_datos_registro(
 IN _codigo INT
)
BEGIN
	SELECT CONCAT(per.apellidos,', ',per.nombres) AS 'APELLIDOS Y NOMBRES',
	IF(reg.tipo='I','INGRESO','SALIDA')AS 'TIPO',reg.dia,reg.hora
	FROM personal per INNER JOIN registro reg ON per.idpersona = reg.idpersona
	WHERE reg.idpersona = _codigo ORDER BY reg.idregistro DESC LIMIT 1;
END
$$

DELIMITER $$
CREATE PROCEDURE up_registro(
IN _dni INT
)
BEGIN
DECLARE _codigo BIGINT DEFAULT '';
DECLARE _tipo_registro CHAR(1) DEFAULT '';

	    SELECT per.idpersona INTO _codigo FROM personal per WHERE dni = _dni;
	    IF _codigo>0 THEN
	      SELECT reg.tipo INTO _tipo_registro FROM registro reg WHERE reg.idpersona = _codigo ORDER BY reg.idregistro DESC LIMIT 1;
	      CASE _tipo_registro

		WHEN 'I' THEN
		INSERT INTO registro VALUES (NULL,_codigo,'S',DAYNAME(NOW()),TIME(NOW()),NOW());
		CALL up_datos_registro(_codigo);

		WHEN 'S' THEN
		INSERT INTO registro VALUES (NULL,_codigo,'I',DAYNAME(NOW()),TIME(NOW()),NOW());
		CALL up_datos_registro(_codigo);

		ELSE
		INSERT INTO registro VALUES (NULL,_codigo,'I',DAYNAME(NOW()),TIME(NOW()),NOW());
		CALL up_datos_registro(_codigo);

	      END CASE;
	    END IF;
END
$$
