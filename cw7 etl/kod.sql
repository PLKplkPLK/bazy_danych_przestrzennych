/*
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

select * from "Exports";

select st_union(rast)
from "Exports";
*/

select st_union(rast)
into United from "Exports";
