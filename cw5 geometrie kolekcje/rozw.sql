/*
create extension postgis;
create table obiekty (nazwa varchar(20), geom geometry);

-- zad a circularstring, st_collect
insert into obiekty values ('obiekt1', st_collect(array['linestring(0 1,1 1)',
														'circularstring(1 1,2 0,3 1)',
														'circularstring(3 1,4 2,5 1)',
														'linestring(5 1,6 1)']));

-- zad b to jeden obiekt: st_collect
insert into obiekty values ('obiekt2', st_collect(array['linestring(10 6,14 6)',
														'circularstring(14 6,16 4,14 2)',
														'circularstring(14 2,12 0,10 2)',
														'circularstring(11 2,12 3,13 2,12 1,11 2)',
														'linestring(10 2,10 6)']));

-- zad c obojętnie czy poligon czy linestring
insert into obiekty values ('obiekt3', 'polygon((7 15,10 17,12 13,7 15))');

-- zad d linestring lub multilinia
insert into obiekty values ('obiekt4', 'linestring(20 20,25 25,27 24,25 22,26 21,22 19,20.5 19.5)');

-- zad e to nie są dwa punkty, ale jeden jako punkty w przestrzeni: st_collect
insert into obiekty values ('obiekt5', 'multipoint(30 30 59,38 32 234)');

-- zad f to co wyżej
insert into obiekty values ('obiekt6', st_collect(array['linestring(1 1,3 2)',
													   'point(4 2)']));

-- zad 2 st_buffer, st_area, st_shortest_line
with obiekty as (
	select ob1.geom as g1, ob2.geom as g2 from obiekty as ob1, obiekty as ob2 where ob1.nazwa='obiekt3' and ob2.nazwa='obiekt4'
)
select st_area(st_buffer(st_shortestline(g1,g2), 5)) from obiekty

-- zad 3 zrobić update (nie delete i dodać znowu), st_makepolygon, st_linemerge
-- Poligon charakteryzuje się tym, że pierwszy i ostatni punkt w wkt muszą mieć takie same współrzędne
update obiekty
set geom=st_makepolygon(st_addpoint(geom, st_startpoint(geom)))
where nazwa='obiekt4'

-- zad 4 insert into obiekty select: st_collect (nie kopiować wkt, tylko odczytać w sql)
insert into obiekty values ('obiekt7', 
	st_collect(array(
		select geom from obiekty where nazwa='obiekt3' or nazwa='obiekt4'
	))
);

-- zad 5 where st_hasArc
select nazwa, st_area(st_buffer(geom,5)) from obiekty where st_hasArc(geom)=false;

-- chyba, że suma:
select sum(st_area(st_buffer(geom,5))) from obiekty where st_hasArc(geom)=false;

-- albo tak:
with geoms as (
	select geom from obiekty where st_hasArc(geom)=false
)

select st_area(st_buffer(st_collect(array[geom]),5)) from geoms
*/