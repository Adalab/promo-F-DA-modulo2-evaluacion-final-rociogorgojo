USE sakila;

-- la tabla film_text no tiene relacion con otra tabla. 
-- Establezco relación con la tabla film porque el film_id de ambas tablas contienen la misma información. 
-- Para esto, añado la restricción de FK en la tabla film_text, llamando a los film_id de ambas tablas.
-- ### Sé que se puede trabajar sin que esté relacionada, pero pudiendo hacerlo, me resulta más claro para el resto de consultas ###

ALTER TABLE `film_text`
ADD CONSTRAINT `fk_film_text_film_id`
FOREIGN KEY (`film_id`)
REFERENCES `film`(`film_id`);

-- la siguiente consulta muestra que no hay id_pelicula duplicadas, lo tengo en cuenta para el resto de consultas.
SELECT `title`, `film_id`, COUNT(`film_id`)
FROM `film`
GROUP BY `film_id`
HAVING COUNT(`film_id`) > 1;

-- la siguiente consulta muestra que no hay títulos de películas duplicados, lo tengo en cuenta para el resto de consultas.

SELECT `title`, COUNT(`title`)
FROM `film`
GROUP BY `film_id`
HAVING COUNT(`title`) > 1;

-- 01_Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT `title`
FROM `film`;

-- 02_Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT `title`
FROM `film`
WHERE `rating` = 'PG-13';

-- 03_Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.

SELECT `title`, `description`
FROM `film`
WHERE `description` LIKE '%amazing%';

-- 04_Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT `title`
FROM `film`
WHERE `length` > 120;

-- 05_Recupera los nombres de todos los actores.

SELECT DISTINCT CONCAT(`first_name`, " ", `last_name`) AS `artista_nombre_completo`
FROM `actor`;

-- 06_Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

SELECT `first_name`, `last_name`
FROM `actor`
WHERE `last_name` LIKE '%gibson%';

-- 07_Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

SELECT CONCAT(`first_name`, " ", `last_name`) AS `artista_nombre_completo`
FROM `actor`
WHERE `actor_id` BETWEEN 10 AND 20;

-- 08_Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT `title` AS `peliculas_no_R_ni_PG-13`
FROM `film`
WHERE `rating` NOT IN ('R', 'PG-13');

-- 09_Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.

SELECT `rating` AS `clasificacion`, COUNT(*) AS `recuento_peliculas`
FROM `film`
GROUP BY `clasificacion`;

-- 10_Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

SELECT `c`.`customer_id`, `c`.`first_name`, `c`.`last_name`, COUNT(`r`.`rental_id`) AS `cantidad_peliculas_alquiladas`
FROM `customer` AS `c`
LEFT JOIN `rental` AS `r` ON `c`.`customer_id` = `r`.`customer_id`
LEFT JOIN `inventory` AS `i` ON `r`.`inventory_id` = `i`.`inventory_id`
GROUP BY `c`.`customer_id`, `c`.`first_name`, `c`.`last_name`;

-- 11_Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

SELECT `c`.`name` AS `nombre_categoria`, COUNT(`r`.`rental_id`) AS `recuento_alquileres`
FROM `category` AS `c`
INNER JOIN `film_category` AS `fc` ON `c`.`category_id` = `fc`.`category_id`
INNER JOIN `inventory` AS `i` ON `fc`.`film_id` = `i`.`film_id`
INNER JOIN `rental` AS `r` ON `i`.`inventory_id` = `r`.`inventory_id`
GROUP BY `c`.`name`;


-- 12_Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.
-- he quitado decimales del promedio_duración_minutos.

SELECT `rating` AS `clasificacion`, ROUND(AVG(`length`), 0) AS `promedio_duracion_minutos`
FROM `film`
GROUP BY `clasificacion`;

-- 13_Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT `a`.`first_name`, `a`.`last_name`
FROM `actor` AS `a`
INNER JOIN `film_actor` AS `fa` ON `a`.`actor_id` = `fa`.`actor_id`
INNER JOIN `film` AS `f` ON `fa`.`film_id` = `f`.`film_id`
WHERE `f`.`title` = 'Indian Love';

-- 14_Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.

SELECT `title` AS `titulo`
FROM `film`
WHERE `description` LIKE '%dog%' OR `description` LIKE '%cat%';

-- 15_Hay algún actor que no aparecen en ninguna película en la tabla film_actor.

-- No, no hay ningún actor, tal y como muestra la query:

SELECT `actor_id`, `first_name`, `last_name`
FROM `actor`
WHERE `actor_id` NOT IN (
	SELECT DISTINCT `actor_id`
	FROM `film_actor`);
            
-- con NOT EXISTS (SELECT 1 da al menos una fila q cumpla la condicion del NOT EXISTS)

SELECT `actor_id`, `first_name`, `last_name`
FROM `actor` AS `a`
WHERE NOT EXISTS (
    SELECT 1
    FROM `film_actor` AS `fa`
    WHERE `fa`.`actor_id` = `a`.`actor_id`
);

-- 16_Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
-- todas las peliculas de esta sakila se lanzaron en 2006 (los 1000 registros), muestro sólo el título

SELECT `title` AS `peliculas_entre_2005_y_2010`
FROM `film`
WHERE `release_year` BETWEEN 2005 AND 2010;

-- 17_Encuentra el título de todas las películas que son de la misma categoría que "Family".

SELECT DISTINCT `f`.`title`
FROM `film` AS `f`
WHERE `f`.`film_id` IN (
    SELECT `film_id`
    FROM `film_category`
    WHERE `category_id` = (
        SELECT `category_id`
        FROM `category`
        WHERE `name` = 'Family'
    )
);

-- 18_Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.

SELECT `first_name`, `last_name`
FROM `actor`
WHERE `actor_id` IN (
    SELECT `actor_id`
    FROM `film_actor`
    GROUP BY `actor_id`
    HAVING COUNT(`film_id`) > 10
);

-- 19_Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.
-- clasificación R, lenght viene en minutos

SELECT `title`
FROM `film`
WHERE `rating` = 'R' AND `length` > 120;

-- 20_Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.

SELECT `c`.`name` AS `nombre_categoria`, AVG(`f`.`length`) AS `promedio_duracion_minutos`
FROM `category` AS `c`
INNER JOIN `film_category` AS `fc` ON `c`.`category_id` = `fc`.`category_id`
INNER JOIN `film` AS `f` ON `fc`.`film_id` = `f`.`film_id`
GROUP BY `c`.`category_id`, `c`.`name`
HAVING AVG(`f`.`length`) > 120;

-- 21_Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.

SELECT CONCAT(`a`.`first_name`, ' ', `a`.`last_name`) AS `nombre_del_actor`, COUNT(`film_id`) AS `cantidad_peliculas`
FROM `actor` AS `a`
INNER JOIN `film_actor` AS `fa` ON `a`.`actor_id` = `fa`.`actor_id`
GROUP BY `a`.`actor_id`
HAVING `cantidad_peliculas` >= 5;

-- 22_Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. 
-- Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.

SELECT `f`.`title` AS `+_de_5_días_alquiladas`
FROM `film` AS `f`
WHERE `film_id` IN (
    SELECT `film_id`
    FROM `rental` AS `r`
    INNER JOIN `inventory` AS `i` ON `r`.`inventory_id` = `i`.`inventory_id`
    WHERE `f`.`rental_duration` > 5
	);

-- 23_Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". 
-- Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.

SELECT `a`.`first_name`, `a`.`last_name`
FROM `actor` AS `a`
WHERE `a`.`actor_id` NOT IN (
    SELECT DISTINCT `fa`.`actor_id`
    FROM `film_category` AS `fc`
    INNER JOIN `film_actor` AS `fa` ON `fc`.`film_id` = `fa`.`film_id`
    INNER JOIN `category` AS `c` ON `fc`.`category_id` = `c`.`category_id`
    WHERE `c`.`name` = 'Horror'
);

-- 24_BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.

SELECT `f`.`title`
FROM `film` AS `f`
INNER JOIN `film_category` AS `fc` ON `f`.`film_id` = `fc`.`film_id`
INNER JOIN `category` AS `c` ON `fc`.`category_id` = `c`.`category_id`
WHERE `c`.`name` = 'Comedy'
AND `f`.`length` > 180;

-- 25_BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. 
-- La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.

SELECT CONCAT(`a1`.`first_name`, ' ', `a1`.`last_name`) AS `actor1_nombre_apellido`,
       CONCAT(`a2`.`first_name`, ' ', `a2`.`last_name`) AS `actor2_nombre_apellido`,
       COUNT(DISTINCT `fa1`.`film_id`) AS `num_peliculas_en_comun`
FROM `film_actor` AS `fa1`
INNER JOIN `film_actor` AS `fa2` ON `fa1`.`film_id` = `fa2`.`film_id` AND `fa1`.`actor_id` < `fa2`.`actor_id`
INNER JOIN `actor` AS `a1` ON `fa1`.`actor_id` = `a1`.`actor_id`
INNER JOIN `actor` AS `a2` ON `fa2`.`actor_id` = `a2`.`actor_id`
GROUP BY `a1`.`actor_id`, `a2`.`actor_id`
HAVING `num_peliculas_en_comun` > 0;
