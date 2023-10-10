delete table if exists wynagrodzenie;
create table wynagrodzenie (id_wynagrodzenia int, data date,
						   id_pracownika int, id_godziny int,
						   id_pensji int, id_premii int,
						   primary key (id_wynagrodzenia),
						   foreign key (id_pracownika) references pracownicy(id_pracownika),
						   )