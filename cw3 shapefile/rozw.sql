--create extension postgis;
/*
--dodanie:
shp2pgsql "D:\T2018_KAR_GERMANY\T2018_KAR_BUILDINGS.shp" public.buildings18 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_BUILDINGS.shp" public.buildings19 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_POI_TABLE.shp" public.poi19 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2018_KAR_GERMANY\T2018_KAR_POI_TABLE.shp" public.poi18 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_STREETS.shp" public.streets19 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_STREET_NODE.shp" public.nodes19 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_LAND_USE_A.shp" public.landusea19 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_RAILWAYS.shp" public.railways19 | psql -h localhost -p 5432 -U postgres -d cw3
shp2pgsql "D:\T2019_KAR_GERMANY\T2019_KAR_WATER_LINES.shp" public.waterlines19 | psql -h localhost -p 5432 -U postgres -d cw3
*/


-- zad 1.
/*
with nowe as (
	select gid, name, polygon_id from buildings19
	where polygon_id not in (select polygon_id from buildings18)
), remont as (
	select buildings18.gid, buildings18.name, buildings18.polygon_id from buildings18 join buildings19 on buildings18.polygon_id=buildings19.polygon_id
	where st_area(st_difference(buildings18.geom, buildings19.geom))>0
)
select * from nowe
union
select * from remont;
*/

-- zad 2.
/*
with nowe as (
	select gid, name, polygon_id, geom from buildings19
	where polygon_id not in (select polygon_id from buildings18)
), remont as (
	select buildings19.gid, buildings19.name, buildings19.polygon_id, buildings19.geom from buildings18 join buildings19 on buildings18.polygon_id=buildings19.polygon_id
	where st_area(st_difference(buildings18.geom, buildings19.geom))>0
), nr as (
	select * from nowe
	union
	select * from remont
), buffed as (
	select st_buffer(geom, 0.005) as geom from nr
), npunkty as ( -- nowe punkty, których nie było w 2018
	select * from poi19
	where poi_id not in (select poi_id from poi18)
), punkty as (
	select distinct poi_id, type from npunkty, buffed where st_intersects(npunkty.geom, buffed.geom)
)
select type, count(*) from punkty group by type order by count desc
*/

-- zad 3. 4326-WSG84, 3068-DHDN.Berlin
/*
drop table if exists streets_reprojected;
create table streets_reprojected as
select gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel,
st_transform(st_setsrid(geom, 4326), 3068) as geom
from streets19;
*/

-- zad 4.
/*
create table input_points (id int, geom geometry);
insert into input_points values
(0, 'POINT(8.36093 49.03174)'),
(1, 'POINT(8.39876 49.00644)');
*/

-- zad 5.
--update input_points set geom=st_transform(st_setsrid(geom, 4326), 3068);

-- zad 6.
/*
with nodes as (
	select gid, node_id, st_transform(st_setsrid(geom, 4326), 3068) as geom from nodes19
	where "intersect"='Y' -- musi być, żeby były skrzyżowaniem?
), liniab as (
	select st_buffer(st_makeline(geom), 0.002) as geoml from input_points
)
select * from nodes, liniab where st_intersects(geom, geoml)
*/

-- zad 7.
/*
with parkib as (
	select polygon_id, st_buffer(geom, 0.003) as geomp from landusea19 where type like 'Park (%' -- nie parking lot
), sklepy as (
	select * from poi19 where type='Sporting Goods Store'
), sklepy_blisko as (
	select distinct poi_id from parkib, sklepy where st_intersects(geomp, geom)
)
select count(*) from sklepy_blisko
*/

-- zad 8.
with scieki as (
	select * from waterlines19 where type='Can'
), punkty as (
	select distinct st_astext(st_intersection(scieki.geom, railways19.geom)) from scieki, railways19
)
select * from punkty where st_astext!='LINESTRING EMPTY'