
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
CREATE SCHEMA IF NOT EXISTS chlopek;

--"C:\Program Files\PostgreSQL\17\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d "C:\Users\marce\Desktop\semestr 5\BDP\cw67\PostGIS raster - dane\srtm_1arc_v3.tif" chlopek.dem > "C:\Users\marce\Desktop\semestr 5\BDP\cw67\PostGIS raster - dane\dem.sql"
--"C:\Program Files\PostgreSQL\17\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 100x100 -I -C -M -d "C:\Users\marce\Desktop\semestr 5\BDP\cw67\PostGIS raster - dane\srtm_1arc_v3.tif" chlopek.dem | "C:\Program Files\PostgreSQL\17\bin\psql.exe" -d cw67 -h localhost -U postgres -p 5433
--"C:\Program Files\PostgreSQL\17\bin\raster2pgsql.exe" -s 3763 -N -32767 -t 128x128 -I -C -M -d "C:\Users\marce\Desktop\semestr 5\BDP\cw67\PostGIS raster - dane\Landsat8_L1TP_RGBN.tif" chlopek.landsat8 | "C:\Program Files\PostgreSQL\17\bin\psql.exe" -d cw67 -h localhost -U postgres -p 5433
SELECT count(*) FROM rasters.landsat8;
SELECT count(*) FROM rasters.dem;


-- P1
CREATE TABLE chlopek.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ILIKE 'porto'; 

ALTER TABLE chlopek.intersects
ADD COLUMN rid SERIAL PRIMARY KEY;



CREATE INDEX idx_intersects_rast_gist ON chlopek.intersects
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('chlopek'::name, 'intersects'::name,'rast'::name);


-- P2
CREATE TABLE chlopek.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality LIKE 'PORTO';



-- P3 
CREATE TABLE chlopek.union AS 
SELECT ST_Union (ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ILIKE 'porto' AND ST_Intersects(b.geom, a.rast);


-- RASTROWANIE

-- P1
CREATE TABLE chlopek.porto_parishes AS
WITH r AS (
    SELECT rast FROM rasters.dem
    LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ILIKE 'porto';


-- P2
DROP TABLE chlopek.porto_parishes; 
CREATE TABLE chlopek.porto_parishes AS
WITH r AS (
    SELECT rast FROM rasters.dem
    LIMIT 1
)
SELECT ST_Union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ILIKE 'porto';


-- P3
DROP TABLE chlopek.porto_parishes; 
CREATE TABLE chlopek.porto_parishes AS
WITH r AS (
    SELECT rast FROM rasters.dem
    LIMIT 1 
)
SELECT ST_Tile(ST_Union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ILIKE 'porto';


-- WEKTORYZOWANIE

-- P1
CREATE TABLE chlopek.intersection AS
SELECT a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ILIKE 'paranhos' AND ST_Intersects(b.geom,a.rast);


-- P2
CREATE TABLE chlopek.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ILIKE 'paranhos' AND ST_Intersects(b.geom,a.rast);


-- ANALIZA RASTRÓW

-- P1
CREATE TABLE chlopek.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;


-- P2
CREATE TABLE chlopek.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ILIKE 'paranhos' AND ST_Intersects(b.geom,a.rast);


-- P3
CREATE TABLE chlopek.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') AS rast
FROM chlopek.paranhos_dem AS a;


-- P4
CREATE TABLE chlopek.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM chlopek.paranhos_slope AS a;


-- P5
SELECT st_summarystats(a.rast) AS stats
FROM chlopek.paranhos_dem AS a;


-- P6
SELECT st_summarystats(ST_Union(a.rast))
FROM chlopek.paranhos_dem AS a;


-- P7
WITH t AS (
    SELECT st_summarystats(ST_Union(a.rast)) AS stats
    FROM chlopek.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;


-- P8
WITH t AS (
    SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
    FROM rasters.dem AS a, vectors.porto_parishes AS b
    WHERE b.municipality ILIKE 'porto' AND ST_Intersects(b.geom,a.rast)
    GROUP BY b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;


-- P9
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;


-- P10
CREATE TABLE chlopek.tpi30 AS
SELECT ST_TPI(a.rast,1) AS rast
FROM rasters.dem a;

CREATE TABLE chlopek.tpi30_porto AS
SELECT ST_TPI(ST_Union(ST_Clip(a.rast, b.geom, true),1)) AS rast
FROM rasters.dem a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast,b.geom) AND b.municipality ILIKE 'porto';


-- ALGEBRA MAP

-- P1
CREATE TABLE chlopek.porto_ndvi AS
WITH r AS (
    SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
    FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
    WHERE b.municipality ILIKE 'porto' AND ST_Intersects(b.geom,a.rast)
)
SELECT
    r.rid,ST_MapAlgebra(
    r.rast, 1,
    r.rast, 4,
    '([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON chlopek.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('chlopek'::name, 'porto_ndvi'::name,'rast'::name);


-- P2
CREATE OR REPLACE FUNCTION chlopek.ndvi(
    VALUE double precision [] [] [],
    pos integer [][],
    VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
RETURN (VALUE [2][1][1] - VALUE [1][1][1])/(VALUE [2][1][1]+VALUE [1][1][1]); 
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE chlopek.porto_ndvi2 AS
WITH r AS (
    SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
    FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
    WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
    r.rid,ST_MapAlgebra(
    r.rast, ARRAY[1,4],
    'chlopek.ndvi(double precision[], integer[],text[])'::regprocedure, 
    '32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON chlopek.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('chlopek'::name, 'porto_ndvi2'::name,'rast'::name);


-- EKSPORT DANYCH

-- P1
SELECT ST_AsTiff(ST_Union(rast))
FROM chlopek.porto_ndvi;

-- P2
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM chlopek.porto_ndvi;

SELECT ST_GDALDrivers();

-- P3
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
    ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM chlopek.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'C:\Users\marce\Desktop\semestr 5\BDP\cw67\PostGIS raster - dane\raster_eksport.tiff') 
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out;

-- gdal_translate -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 PG:"host=localhost port=5432 dbname=cw67 user=postgres password=postgis schema=chlopek table=porto_ndvi mode=2" "C:\Users\marce\Desktop\semestr 5\BDP\cw67\PostGIS raster - dane\porto_ndvi.tiff"
