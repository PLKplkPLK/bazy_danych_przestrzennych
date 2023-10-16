-- zad 3
-- create extension postgis;


-- zad 4
/*
create table buildings (id int, geometry geometry, name varchar(10));
create table roads (id int, geometry geometry, name varchar(10));
create table poi (id int, geometry geometry, name varchar(10));

insert into buildings values
	(1, 'POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))','BuildingA'),
	(2, 'POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))','BuildingB'),
	(3, 'POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))','BuildingC'),
	(4, 'POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))','BuildingD'),
	(5, 'POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))','BuildingF');

insert into roads values
	(1, 'LINESTRING(0 4.5, 12 4.5)', 'RoadX'),
	(2, 'LINESTRING(7.5 0, 7.5 10.5)', 'RoadY');

insert into poi values
	(1, 'POINT(1 3.5)', 'G'),
	(2, 'POINT(5.5 1.5)', 'H'),
	(3, 'POINT(9.5 6)', 'I'),
	(4, 'POINT(6.5 6)', 'J'),
	(5, 'POINT(6 9.5)', 'K');
*/


-- zad 6
-- a
-- select sum(st_length(geometry)) from roads;

-- b
-- select st_astext(geometry) as "Geometria", st_area(geometry) as "Pole powierzchni", st_perimeter(geometry) as "Obówd"
-- 	from buildings where name='BuildingA';

-- c
-- select name as "Nazwa", st_area(geometry) as "Pole powierzchni"
-- from buildings order by name;

-- d
-- select name as "Nazwa", st_perimeter(geometry) as "Obwód" from buildings
-- order by st_area(geometry) desc limit 2;

-- e
/*
with buildingC as (
select name, geometry as geom1 from buildings where name='BuildingC'
), pointK as (
select name, geometry as geom2 from poi where name='K'
)
select st_distance(geom1, geom2) as "Odległość" from buildingC, pointK
*/

-- f
/*
with buildingB as (
select name, geometry as geom1 from buildings where name='BuildingB'
), buildingCbuff as (
select name, st_buffer(geometry, 0.5) as geom2 from buildings where name='BuildingC'
)
select st_area(st_difference(geom1, geom2)) as "Pole powierzchni" from buildingB, buildingCbuff
-- tutaj raczej dobrze wychodzi, trzeba też uwzględnić 1/4 koła
*/

-- g
/*
with crossSec as (
select buildings.name as name, buildings.geometry as geomB, roads.geometry as geomR
	from buildings, roads
)
select name from crossSec where st_y(st_centroid(geomB)) > st_y(geomR)*/
-- inaczej:
--select name from buildings where st_y(st_centroid(geometry)) > 4.5;

-- h
-- select st_area(st_difference(geometry, 'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')) as "Pole powierzchni różnicy"
-- from buildings where name='BuildingC'