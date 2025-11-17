DROP TABLE IF EXISTS geometrie;

-- 1)
CREATE TABLE geometrie
(
	opis varchar(255),
	geom geometry
);

TRUNCATE TABLE geometrie;

INSERT INTO geometrie(opis, geom)
VALUES ('obiekt1',
		ST_CurveToLine(
			ST_GeomFromText(
				'COMPOUNDCURVE(
					LINESTRING(0 1, 1 1),
					CIRCULARSTRING(1 1, 2 0, 3 1),
					CIRCULARSTRING(3 1, 4 2, 5 1),
					LINESTRING(5 1, 6 1)
				)', 0))),

	('obiekt2', ST_GeomFromText(
		'GEOMETRYCOLLECTION(
		LINESTRING(10 6, 14 6),
		CIRCULARSTRING(14 6, 16 4,14 2),
		CIRCULARSTRING(14 2, 12 0, 12 2),
		LINESTRING(10 2, 10 6),
		CIRCULARSTRING(11 2, 12 3, 12 2),
		CIRCULARSTRING(13 2, 12 1, 11 2))',
		0)),

	('obiekt3', ST_GeomFromText(
		'LINESTRING(10 17,12 13, 7 15, 10 17)',
		0)),
	('obiekt4', ST_GeomFromText(
		'LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)', 0)),

	('obiekt5', ST_GeomFromText('MULTIPOINT Z(38 32 234, 30 30 59)', 0)),

	('obiekt6', ST_GeomFromText(
		'GEOMETRYCOLLECTION(
		LINESTRING(1 1,3 2),
		POINT(4 2))',
		0));

-- 2)
SELECT ST_Area(ST_Buffer(ST_ShortestLine(g1.geom, g2.geom), 5.0)) AS pole_bufora
FROM geometrie AS g1
CROSS JOIN geometrie AS g2
WHERE g1.opis = 'obiekt3' AND g2.opis = 'obiekt4';

-- 3)
SELECT ST_MakePolygon(ST_AddPoint(g.geom, ST_StartPoint(g.geom)))
FROM
	(SELECT geom FROM geometrie WHERE opis = 'obiekt4') AS g;

-- 4)
INSERT INTO geometrie(opis, geom)
SELECT 'obiekt7', ST_Collect(t1.geom, t2.geom)
FROM geometrie AS t1, geometrie AS t2
WHERE t1.opis = 'obiekt3' AND t2.opis = 'obiekt4';

-- 5)
SELECT no_arcs.opis, ST_Area(ST_Buffer(no_arcs.geom, 5.0)) AS powierzchnia_bufora
FROM (
	SELECT *
	FROM geometrie
	WHERE ST_HasArc(geometrie.geom) = false
	) AS no_arcs
GROUP BY no_arcs.opis, no_arcs.geom
ORDER BY no_arcs.opis;

--
SELECT *
FROM geometrie
WHERE ST_HasArc(geometrie.geom) = false;
