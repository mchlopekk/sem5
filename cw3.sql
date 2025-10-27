
CREATE EXTENSION postgis;

--usuniecie tabeli potrzebne do ponownego uruchomienia skryptu
DROP TABLE IF EXISTS new_buildings;
DROP TABLE IF EXISTS new_pois;
DROP TABLE IF EXISTS streets_reprojected;
DROP TABLE IF EXISTS input_points;
DROP TABLE IF EXISTS nearby_nodes;
DROP TABLE IF EXISTS sport_shops_near_parks;
DROP TABLE IF EXISTS t2019_kar_bridges;

--#1
CREATE TABLE new_buildings AS
SELECT b19.* --wszystkie kolumny b19
FROM t2019_kar_buildings AS b19
LEFT JOIN t2018_kar_buildings AS b18
ON ST_Equals(b19.geom, b18.geom)
WHERE b18.geom IS NULL;

--#2
CREATE TABLE new_pois AS
SELECT
    p19.type,
    COUNT(DISTINCT p19.gid) AS ilosc_nowych_poi
FROM
    t2019_kar_poi_table AS p19
JOIN
    new_buildings AS b19 ON ST_DWithin(p19.geom, b19.geom, 500)
WHERE
    NOT EXISTS (
        SELECT 1 FROM t2018_kar_poi_table p18 WHERE ST_Equals(p19.geom, p18.geom)
    )
GROUP BY p19.type
ORDER BY ilosc_nowych_poi DESC;

--#3
CREATE TABLE streets_reprojected AS
SELECT
    gid,
    ST_Transform(geom, 3068) AS geom 
FROM t2019_kar_streets;

--#4
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geom geometry(Point, 4326)
);
INSERT INTO input_points (geom)
VALUES
(ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
(ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));

--#5
ALTER TABLE input_points
ALTER COLUMN geom TYPE geometry(Point, 3068)
USING ST_Transform(geom, 3068);

--#6

CREATE TABLE nearby_nodes AS
SELECT nodes.*
FROM t2019_kar_street_node AS nodes
WHERE ST_DWithin(
    nodes.geom,
    (SELECT ST_MakeLine(geom ORDER BY id) FROM input_points),
    200
);
SELECT COUNT(*) AS total_nearby_nodes FROM nearby_nodes;

--#7
CREATE TABLE sport_shops_near_parks AS
SELECT
    COUNT(DISTINCT poi.gid) AS total_sport_shops
FROM
    t2019_kar_poi_table AS poi
JOIN
    t2019_kar_land_use_a AS park ON ST_DWithin(poi.geom, park.geom, 300)
WHERE
    poi.type = 'Sporting Goods Store';

SELECT * FROM sport_shops_near_parks;

--#8
CREATE TABLE t2019_kar_bridges AS
SELECT 
    ST_Intersection(r.geom, w.geom) AS geom
FROM t2019_kar_railways AS r
JOIN t2019_kar_water_lines AS w
  ON ST_Intersects(r.geom, w.geom);

SELECT COUNT(*) AS total_bridges FROM t2019_kar_bridges;
