/*
create extension postgis;
create extension postgis_raster;

select * from rasters.dem;
select * from rasters.landsat8;


-- Tworzenie rastrów z istniejących rastrów i interakcja z wektorami

CREATE TABLE muller.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

alter table muller.intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON muller.intersects
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('muller'::name, 'intersects'::name,'rast'::name);


CREATE TABLE muller.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';


CREATE TABLE muller.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);


-- Tworzenie rastrów z wektorów (rastrowanie)

CREATE TABLE muller.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';


DROP TABLE muller.porto_parishes;
CREATE TABLE muller.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

select * from muller.porto_parishes

DROP TABLE muller.porto_parishes;
CREATE TABLE muller.porto_parishes AS
WITH r AS (
	SELECT rast FROM rasters.dem
	LIMIT 1
)
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

select * from muller.porto_parishes


-- Konwertowanie rastrów na wektory (wektoryzowanie)

create table muller.intersection as
SELECT a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

select * from muller.intersection

CREATE TABLE muller.dumppolygons AS
SELECT a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

select * from muller.dumppolygons


-- Analiza rastrów

CREATE TABLE muller.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

select * from muller.landsat_nir


CREATE TABLE muller.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);


CREATE TABLE muller.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM muller.paranhos_dem AS a;

CREATE TABLE muller.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM muller.paranhos_slope AS a;


SELECT st_summarystats(rast) AS stats
FROM muller.paranhos_dem;

SELECT st_summarystats(st_union(rast))
FROM muller.paranhos_dem;

WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM muller.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean,(stats).count FROM t;

WITH t AS (
	SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
	FROM rasters.dem AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
	group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;



-- Topographic Position Index (TPI)

create table muller.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON muller.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('muller'::name, 'tpi30'::name,'rast'::name);


-- Zadanie
drop table if exists muller.porto_tpi;
create table muller.porto_tpi as
with porto as (
	SELECT a.rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'
)
select st_tpi(st_union(rast)) from porto;

select * from muller.porto_tpi


-- Algebra Map
CREATE TABLE muller.porto_ndvi AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT r.rid,ST_MapAlgebra(r.rast, 1, r.rast, 4, '([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF') AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON muller.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('muller'::name, 'porto_ndvi'::name,'rast'::name);



create or replace function muller.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;


CREATE TABLE muller.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid, ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
	r.rast, ARRAY[1,4],
	'muller.ndvi(double precision[], integer[],text[])'::regprocedure, --> This is the function!
	'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON muller.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('muller'::name, 'porto_ndvi2'::name,'rast'::name);


-- Eksport danych
SELECT ST_AsTiff(ST_Union(rast))
FROM muller.porto_ndvi; -- no i to odczytać z bazy

SELECT ST_GDALDrivers();
SELECT ST_AsGDALRaster(ST_Union(rast), 'JPEG',
					   ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM muller.porto_ndvi;

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM muller.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'D:\OneDrive\studia\BDPrzestrzennych\bazy_danych_przestrzennych\cw6 raster\11_sql_export.tiff')
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.
drop table tmp_out;
*/