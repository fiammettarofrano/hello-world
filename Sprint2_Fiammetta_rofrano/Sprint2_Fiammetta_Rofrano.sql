USE transactions;
#Nivel 1
#Ejercicio 1 Muestra las principales características del esquema creado y explica las diferentes tablas y variables que existen. Asegúrate de incluir un diagrama que ilustre la relación entre las distintas tablas y variables.

-- El esquema consta de dos tablas; la tabla company que proporciona los datos de distintas impresas (nombre, telefono, email, pais y website), donde la llave primaria es el id.
-- La tabla transaction es descriptiva de distintas transacciones y se conecta a la tabla company mediante la clave foranea company_id. En este caso la tabla company (dimention table) 
-- representa una tabla de dimension de transactions (fact table) ya que una empresa puede tener muchas transacciones (relaccion de uno a muchos)


#Ejercicio 2 Utilizando JOIN realizarás las siguientes consultas:
# 2.1 Listado de los países que están generando ventas.

SELECT DISTINCT country
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = 0
ORDER BY country;

# 2.2 Desde cuántos países se generan las ventas.

SELECT COUNT(DISTINCT country) AS Paises_Generando_Ventas
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = 0;



# 2.3 Identifica a la compañía con la mayor media de ventas.

SELECT c.id,  c.company_name, ROUND(AVG(amount),2) AS media_de_ventas
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.company_name
ORDER BY AVG(amount) desc  #  Mira el round en order by
LIMIT 1;

# Ejercicio 3: Utilizando sólo subconsultas (sin utilizar JOIN): 
#3.1 Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT *
FROM transaction AS t 
WHERE t.declined = 0 AND company_id IN (SELECT id
										FROM company
										WHERE country = "Germany");


# 3.2 Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT company_name
FROM company c
WHERE (SELECT AVG(amount)
		FROM transaction t
		WHERE t.declined = 0 AND t.company_id = c.id) > (SELECT ROUND(AVG(amount), 2)  
														FROM transaction AS t
														WHERE t.declined = 0 );


# 3.3 Las empresas que no tengan transacciones registradas serán retiradas del sistema, entregando la lista de estas empresas.

#Lista empresas
SELECT c.id, c.company_name
FROM company AS c
WHERE c.id NOT IN (SELECT DISTINCT t.company_id
					FROM transaction AS t
					WHERE t.declined = 0);

    
# Nivel 2
#Ejercicio 1
#Identifica los cinco días que la mayor cantidad de ingresos en la empresa fue generada por las ventas. 
#Muestra la fecha de cada transacción junto con el total de ventas.


SELECT DATE(t.timestamp) AS fecha, 
		SUM(t.amount) AS importe_total
FROM transaction AS t
WHERE t.declined = 0
GROUP BY fecha
ORDER BY importe_total DESC
LIMIT 5;

# Ejercicio 2 ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT c.country, ROUND(AVG(t.amount), 2) AS media_ventas_pais
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY AVG(t.amount) DESC;


# Ejercicio 3 En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. 
# Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.


# 3.1 Muestra el listado aplicando JOIN y subconsultas.

SELECT *
FROM transaction AS t
JOIN company AS c
ON c.id = t.company_id
WHERE t.declined = 0 AND c.company_name != "Non Institute" AND c.country IN (SELECT country
																			FROM company
																			WHERE company_name = "Non Institute");



# 3.2 Muestra el listado aplicando solo subconsultas.

SELECT *
FROM transaction AS t
WHERE company_id IN (
    SELECT id
    FROM company AS c
    WHERE t.declined = 0 AND c.company_name != "Non Institute" AND country = (SELECT country 
																			FROM company
																			WHERE company_name = "Non Institute")
																			);


#Nivel 3 Ejercicio 1
# Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas: 
# 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.

SELECT c.id, c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM company AS c
JOIN transaction AS t
ON c.id = t.company_id
WHERE  t.declined = 0 AND t.amount BETWEEN 350 AND 400 AND DATE(t.timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY t.amount DESC;


# Ejercicio 2 Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información
# sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.


SELECT t.company_id, c.company_name, COUNT(*) AS transacciones_totales,
CASE 
    WHEN COUNT(*) > 400 THEN "> 400 transacciones"
    ELSE "< 400 transacciones"
END AS rating
FROM transaction AS t
JOIN company AS c
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY t.company_id, c.company_name;
