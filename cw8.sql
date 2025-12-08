/* 1. Przycięcie rastra UK do granic parku */
CREATE TABLE uk_lake_district AS
SELECT
    ST_Clip(r.rast, p.geom, TRUE) AS rast
FROM uk_250k_2 AS r
INNER JOIN national_parks_cliped AS p
    ON p.id = 1
    AND ST_Intersects(r.rast, p.geom);

/* 2. Przycięcie kanału zielonego (Green) */
CREATE TABLE sentinel_green_clip AS
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), TRUE) AS rast
FROM sentinel_green AS r
INNER JOIN national_parks AS p
    ON p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));

SELECT AddRasterConstraints('sentinel_green_clip', 'rast');
CREATE INDEX sentinel_green_clip_idx ON sentinel_green_clip USING GIST (ST_ConvexHull(rast));

/* 3. Przycięcie kanału podczerwieni (NIR) */
CREATE TABLE sentinel_nir_clip AS
SELECT
    ST_Clip(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)), TRUE) AS rast
FROM sentinel_nir AS r
INNER JOIN national_parks AS p
    ON p.id = 1
    AND ST_Intersects(r.rast, ST_Transform(p.geom, ST_SRID(r.rast)));

SELECT AddRasterConstraints('sentinel_nir_clip', 'rast');
CREATE INDEX sentinel_nir_clip_idx ON sentinel_nir_clip USING GIST (ST_ConvexHull(rast));

/* 4. Obliczenie wskaźnika NDWI (Algebra map) */
CREATE TABLE lake_district_ndwi_v2 AS
SELECT
    ST_SetSRID(
        ST_MapAlgebra(
            a.rast,
            b.rast,
            '([rast1] - [rast2]) / NULLIF([rast1] + [rast2], 0)::float'
        ),
        ST_SRID(a.rast)
    ) AS rast
FROM sentinel_green_clip AS a
INNER JOIN sentinel_nir AS b
    ON ST_Intersects(a.rast, b.rast);

SELECT AddRasterConstraints('lake_district_ndwi_v2', 'rast');

/* Sprawdzenie wyników */
SELECT COUNT(*) FROM lake_district_ndwi_v2;
