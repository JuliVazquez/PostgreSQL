DROP DATABASE Tp_vazquez;  --nos aseguramos que si existia otra base de datos con el mismo nombre, sea eliminada, pues no nos interesa.

CREATE DATABASE Tp_vazquez;
/*
A partir de este punto es necesario conectar a la base de datos.
Para ello dependiendo de donde se este ejercutando el script es necesario tomar uno de dos posibles caminos:

/c Tp_vazquez              (OPCION SHELL)

En caso de la interfaz grafica es necesario introducir contraseña de usuario y poner como nombre de la base de datos Tp_vazquez para que se conecte
*/

--CREAMOS LAS TABLAS DE LA BASE DE DATOS:
/*Es muy importante que las tablas sean creadas en este orden, dado que alterarlo produciria un error, el cual se debe a las CONSTRAINT FOREIGN KEY. Si se dice que una tabla tiene como clave foranea el atributo
 de una tabla que aun no existe, daría un error. Por ello es importante respetar el orden
 */

CREATE TABLE feria (
	id int PRIMARY KEY,
	nombre varchar(255) NOT NULL,	
	cuit varchar(13) NOT NULL,
	cantidad_puestos int DEFAULT NULL,
	localidad varchar(255) DEFAULT NULL,
	domicilio varchar(255) DEFAULT NULL,
    zona varchar(255)
);

CREATE TABLE producto_tipo (
id int PRIMARY KEY,
nombre varchar(255) NOT NULL,
descripcion varchar(255) DEFAULT NULL
);

CREATE TABLE "user" (           -- user no es aceptado como nombre por ser palabra reservada, pero si "user"
id SERIAL PRIMARY KEY,			-- elijo tipo SERIAL para que cada vez que ingrese un nuevo usuario, le asigne el siguiente id
email varchar(180) NOT NULL,
password varchar(25) NOT NULL,
nombre varchar(255) DEFAULT NULL,
apellido varchar(255) DEFAULT NULL
);

CREATE TABLE producto (
id SERIAL PRIMARY KEY,					--elijo tipo SERIAL para que cada vez que ingrese un nuevo producto, le asigne el siguiente id
tipo_id integer NOT NULL,
especie varchar(255) NOT NULL,
variedad varchar(255) DEFAULT NULL,
activo bool NOT NULL,
CONSTRAINT fk_producto_tipo_id FOREIGN KEY (tipo_id) REFERENCES producto_tipo(id)
);

CREATE TABLE declaracion (
id int PRIMARY KEY,
fechageneracion date NOT NULL,		--datetime no es un tipo de dato para postgre, reemplazo por DATE ya que solo nos interesa saber el d/m/a
feria_id integer NOT NULL,
user_autor_id integer DEFAULT NULL,
CONSTRAINT fk_declaracion_feria_id FOREIGN KEY (feria_id) REFERENCES feria(id),
CONSTRAINT fk_declaracion_user_autor FOREIGN KEY (user_autor_id) REFERENCES "user"(id)
);

CREATE TABLE declaracion_individual (
id int PRIMARY KEY,
producto_declarado_id integer NOT NULL,
declaracion_id integer NOT NULL,
fecha date NOT NULL,
precio_por_bulto decimal(12,2) DEFAULT NULL,
comercializado bool NOT NULL DEFAULT True,
peso_por_bulto decimal(5,2) DEFAULT NULL,
CONSTRAINT fk_producto_declarado_id FOREIGN KEY (producto_declarado_id) REFERENCES producto(id),
CONSTRAINT fk_declaracion_individual_id FOREIGN KEY (declaracion_id) REFERENCES declaracion(id)
);

CREATE TABLE user_feria (
user_id integer NOT NULL,
feria_id integer NOT NULL,
CONSTRAINT user_feria_pk PRIMARY KEY (user_id, feria_id),
CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES "user"(id),
CONSTRAINT fk_feria_id FOREIGN KEY (feria_id) REFERENCES feria(id)
);

------------------------------------------------------------------------------------------------------------------------------------------------
--EJERCICIO 2
--algunos de ellos era DDL y no DML

--13) En la tabla de productos conocemos su PK, pero es necesario impedir que pueda repetirse especie y variedad. Explique cómo lo haría e impleméntelo.
/*
La parte anterior de este ejercicio está en el archivo Vazquez_DiegoJulian_DML.sql, dado que son eliminacion de tuplás (DML) que no cumplen con la restricciones que se establece
a continuacion, y para asegurar la integridad de la base de datos, antes de establecer la restriccion, eliminamos aquellos datos que no la cumplen.

ES IMPORTANTE HABER BORRADO LAS TUPLAS REPEDIDAS, TAL COMO SE HIZO EN EL SCRIPT DML PARA QUE SE ESTABLEZCA LA RESTRICCION!
*/
ALTER TABLE producto 
ADD CONSTRAINT unique_especie_variedad UNIQUE (especie,variedad);

--14) Cree una vista (view) con la información de correo del usuario, nombre, ubicación de todas las ferias con las que está relacionado. Dicho listado debe incluir a los usuarios que no tienen ferias asociadas.

CREATE VIEW view_locacion_de_feria_de_usuario AS(
	SELECT u.nombre, u.email, f.nombre AS nombre_feria, f.localidad AS localidad_feria, f.zona AS zona_feria
	FROM "user" u 
	LEFT JOIN user_feria uf
		ON u.id = uf.user_id
	LEFT JOIN feria f
		ON uf.feria_id = f.id 
);

--17) Con el uso del sistema se identificaron muchísimas consultas buscando productos por su especie y variedad en la condición, cree un índice adecuado para dicha búsqueda.
CREATE INDEX indice_especie_variedad ON producto(especie,variedad);
