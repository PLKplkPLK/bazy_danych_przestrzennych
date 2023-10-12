/*
SET search_path TO ksiegowosc;

delete table if exists wynagrodzenie;
create table wynagrodzenie (id_wynagrodzenia int, data date,
						   id_pracownika int, id_godziny int,
						   id_pensji int, id_premii int,
						   primary key (id_wynagrodzenia),
						   foreign key (id_pracownika) references pracownicy(id_pracownika),
						   )

comment on table godziny is 'godziny przepracowane przez pracowników';
comment on table pensja is 'pensja pracowników';
comment on table pracownicy is 'zbiór pracowników';
comment on table premia is 'premie pracowników';
comment on table wynagrodzenie is 'łączne wynagrodzenie pracowników';

insert into pracownicy values
(1, 'Bob', 'Bob', 'adres1', 111111111),
(2, 'John', 'John', 'adres2', 222222222),
(3, 'Tod', 'Tod', 'adres3', 333333333),
(4, 'Hiob', 'Hiob', 'adres4', 444444444),
(5, 'Set', 'Set', 'adres5', 555555555),
(6, 'Mat', 'Mat', 'adres6', 666666666),
(7, 'Pat', 'Pat', 'adres7', 777777777),
(8, 'Brad', 'Brad', 'adres8', 888888888),
(9, 'Ra', 'Ra', 'adres9', 999999999),
(10, 'Kiki', 'Kiki', 'adres10', 111100000);
insert into godziny values
(1, '2023-05-05', 10, 1),
(2, '2023-05-05', 40, 2),
(3, '2023-05-05', 20, 3),
(4, '2023-05-05', 50, 4),
(5, '2023-05-05', 100, 5),
(6, '2023-05-05', 16, 6),
(7, '2023-05-05', 1, 7),
(8, '2023-05-05', 20, 8),
(9, '2023-05-05', 120, 9),
(10, '2023-05-05', 15, 10);

insert into pensja values
(1, 'szef', 10000),
(2, 'cto', 9000),
(3, 'manager', 8000),
(4, 'assisstant manager', 7000),
(5, 'senior', 6000),
(6, 'engineer', 5000),
(7, 'junior', 4000),
(8, 'intern', 3000),
(9, 'cleaner', 2000),
(10, 'me', 1000);
insert into premia values
(1, 'super', 500),
(2, 'super', 500),
(3, 'super', 500),
(4, 'super', 500),
(5, 'super', 500),
(6, 'standard', 200),
(7, 'standard', 200),
(8, 'standard', 200),
(9, 'standard', 200),
(10, 'none', 0);
insert into wynagrodzenie values
(1, '2023-05-15', 1, 1, 1, 1),
(2, '2023-05-15', 2, 2, 2, 2),
(3, '2023-05-15', 3, 3, 3, 3),
(4, '2023-05-15', 4, 4, 4, 4),
(5, '2023-05-15', 5, 5, 5, 5),
(6, '2023-05-15', 6, 6, 6, 6),
(7, '2023-05-15', 7, 7, 7, 7),
(8, '2023-05-15', 8, 8, 8, 8),
(9, '2023-05-15', 9, 9, 9, 9),
(10, '2023-05-15', 10, 10, 10, 10);

select id_pracownika, imie from pracownicy

select * from pracownicy where left(imie, 1)='T'

select * from pracownicy where (nazwisko like '%i%' or nazwisko like '%I%') and right(imie, 1)='b'

with sumy as (
select id_pracownika, sum(liczba_godzin) as suma from godziny group by id_pracownika order by suma desc
)

select * from sumy where suma>=100
*/
delete from pracownicy where id_pracownika=10;
select * from pracownicy