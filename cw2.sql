CREATE EXTENSION postgis;
DROP TABLE buildings;
CREATE TABLE buildings (
    id_budynku INT PRIMARY KEY,
    geometry GEOMETRY,
    name VARCHAR(40)
);

CREATE TABLE roads (
    id_drogi INT PRIMARY KEY,
    geometry GEOMETRY,
    name VARCHAR(40)
);

CREATE TABLE poi (
    id_poi INT PRIMARY KEY,
    geometry GEOMETRY,
    name VARCHAR(40)
);
select * from buildings;
select * from roads;
select * from poi;

INSERT INTO buildings (id_budynku, name, geometry) VALUES
(1, 'BuildingA', ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))', -1)),
(2, 'BuildingB', ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))', -1)),
(3, 'BuildingC', ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))', -1)),
(4, 'BuildingD', ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))', -1)),
(5, 'BuildingF', ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))', -1));

INSERT INTO roads (id_drogi, name, geometry) VALUES
(1, 'RoadX', ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', -1)),
(2, 'RoadY', ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)', -1));

INSERT INTO poi (id_poi, name, geometry) VALUES
(1, 'G', ST_GeomFromText('POINT(1 3.5)', -1)),
(2, 'H', ST_GeomFromText('POINT(5.5 1.5)', -1)),
(3, 'I', ST_GeomFromText('POINT(9.5 6)', -1)),
(4, 'J', ST_GeomFromText('POINT(6.5 6)', -1)),
(5, 'K', ST_GeomFromText('POINT(6 9.5)', -1));

-- zadanie 6.

--a
SELECT SUM(ST_Length(geometry)) AS calkowita_dlugosc_drog
FROM roads;

--b
SELECT
    ST_AsText(geometry) AS geometria_wkt,
    ST_Area(geometry) AS pole,
    ST_Perimeter(geometry) AS obwod
FROM buildings
WHERE name = 'BuildingA';

--c
SELECT
    name,
    ST_Area(geometry) AS pole
FROM buildings
ORDER BY name ASC;

--d
SELECT
    name,
    ST_Perimeter(geometry) AS obwod
FROM buildings
ORDER BY ST_Area(geometry) DESC
LIMIT 2;

--e
SELECT ST_Distance(b.geometry, p.geometry) AS najkrotsza_odleglosc
FROM buildings b, poi p
WHERE b.name = 'BuildingC' AND p.name = 'K';

--f
SELECT ST_Area(
    ST_Difference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        (SELECT ST_Buffer(geometry, 0.5) FROM buildings WHERE name = 'BuildingB')
    )
) AS pole_czesci_c;

--g
SELECT b.name
FROM buildings b, roads r
WHERE r.name = 'RoadX'
  AND ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_StartPoint(r.geometry));

--h
SELECT ST_Area(
    ST_SymDifference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', -1)
    )
) AS pole_czesci_niepolaczonych;




