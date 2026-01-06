CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_raster;

DROP TABLE IF EXISTS "raster_scal";

CREATE TABLE "raster_scal" AS
SELECT
    1 as id,
    ST_Union(
        ST_SnapToGrid("rast", 0, 0),
        'MAX'
    ) AS rast
FROM "Export";

SELECT AddRasterConstraints('raster_scal'::name, 'rast'::name);
CREATE INDEX raster_scal_idx ON "raster_scal" USING gist (ST_ConvexHull(rast));
