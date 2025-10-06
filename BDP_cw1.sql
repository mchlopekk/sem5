create table ksiegowosc.pracownicy(
id_pracownika int primary key,
imie varchar(20),
nazwisko varchar(50),
adres text,
telefon varchar(12)
);
comment on table ksiegowosc.pracownicy is 'Tabela przechowuje dane pracowników firmy';

create table ksiegowosc.godziny(
id_godziny int primary key,
data_ date,
liczba_godzin decimal(5,2),
id_pracownika int,
foreign key (id_pracownika) references ksiegowosc.pracownicy(id_pracownika)
);
comment on table ksiegowosc.godziny is 'Tabela zawiera ewidencję przepracowanych godzin';

create table ksiegowosc.pensja(
id_pensji int primary key,
stanowisko text,
kwota decimal(10,2)
);
comment on table ksiegowosc.pensja is 'Tabela określa wysokość pensji dla poszczególnych stanowisk';


create table ksiegowosc.premia(
id_premii int primary key,
rodzaj varchar(30),
kwota decimal(10,2)
);
comment on table ksiegowosc.premia is 'Tabela przechowuje dane o premiach';

create table ksiegowosc.wynagrodzenie(
id_wynagrodzenia int primary key,
data_ date,
id_pracownika int,
id_godziny int,
id_pensji int,
id_premii int,
foreign key (id_pracownika) references ksiegowosc.pracownicy(id_pracownika),
foreign key (id_godziny) references ksiegowosc.godziny(id_godziny),
foreign key (id_pensji) references ksiegowosc.pensja(id_pensji),
foreign key (id_premii) references ksiegowosc.premia(id_premii)
);
comment on table ksiegowosc.wynagrodzenie is 'Tabela wiąże dane pracownika, jego godziny, pensję i premię';

select * from ksiegowosc.wynagrodzenie
select * from ksiegowosc.pracownicy
select * from ksiegowosc.godziny
select * from ksiegowosc.pensja
select * from ksiegowosc.premia

--rekordy do tabeli zostały wygenerowane przez AI, w taki sposób, aby jak najlepiej wykorzystać dane polecenia. 
INSERT INTO ksiegowosc.pracownicy(id_pracownika, imie, nazwisko, adres, telefon) VALUES
(1, 'Jan', 'Kowalski', 'Warszawa ul. Lipowa 5', '600123456'),
(2, 'Anna', 'Nowak', 'Kraków ul. Słoneczna 12', '601234567'),
(3, 'Piotr', 'Wiśniewski', 'Gdańsk ul. Morska 3', '602345678'),
(4, 'Katarzyna', 'Lewandowska', 'Wrocław ul. Dębowa 8', '603456789'),
(5, 'Marek', 'Zieliński', 'Poznań ul. Polna 10', '604567890'),
(6, 'Ewa', 'Kaczmarek', 'Łódź ul. Ogrodowa 2', '605678901'),
(7, 'Tomasz', 'Wójcik', 'Szczecin ul. Słowiańska 7', '606789012'),
(8, 'Agnieszka', 'Kamińska', 'Lublin ul. Krótka 4', '607890123'),
(9, 'Robert', 'Jankowski', 'Bydgoszcz ul. Zielona 9', '608901234'),
(10, 'Julia', 'Mazur', 'Katowice ul. Lipowa 15', '609012345');

INSERT INTO ksiegowosc.pensja(id_pensji, stanowisko, kwota) VALUES
(1, 'Programista', 2500),
(2, 'Analityk', 1200),
(3, 'Księgowa', 3500),
(4, 'Manager', 4000),
(5, 'HR', 1000),
(6, 'Sprzedawca', 800),
(7, 'Administrator', 3000),
(8, 'Projektant', 2800),
(9, 'Tester', 1500),
(10, 'Sekretarka', 1800);

INSERT INTO ksiegowosc.premia(id_premii, rodzaj, kwota) VALUES
(1, 'Świąteczna', 500),
(2, 'Motywacyjna', 300),
(3, 'Okolicznościowa', 200),
(4, 'Roczna', 1000),
(5, 'Projektowa', 400),
(6, 'Dodatkowa', 250),
(7, 'Lojalnościowa', 350),
(8, 'Specjalna', 450),
(9, 'Nagroda', 300),
(10, 'Brak', 0);

INSERT INTO ksiegowosc.godziny(id_godziny, data_, liczba_godzin, id_pracownika) VALUES
(1, '2025-09-01', 170, 1),
(2, '2025-09-02', 150, 2),
(3, '2025-09-03', 180, 3),
(4, '2025-09-04', 160, 4),
(5, '2025-09-05', 165, 5),
(6, '2025-09-06', 140, 6),
(7, '2025-09-07', 175, 7),
(8, '2025-09-08', 155, 8),
(9, '2025-09-09', 160, 9),
(10, '2025-09-10', 185, 10);

INSERT INTO ksiegowosc.wynagrodzenie(id_wynagrodzenia, data_, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
(1, '2025-09-01', 1, 1, 1, 1),
(2, '2025-09-02', 2, 2, 2, NULL),
(3, '2025-09-03', 3, 3, 3, 2),
(4, '2025-09-04', 4, 4, 4, 3),
(5, '2025-09-05', 5, 5, 5, NULL),
(6, '2025-09-06', 6, 6, 6, 4),
(7, '2025-09-07', 7, 7, 7, NULL),
(8, '2025-09-08', 8, 8, 8, 5),
(9, '2025-09-09', 9, 9, 9, 6),
(10, '2025-09-10', 10, 10, 10, NULL);

--a)
select nazwisko, id_pracownika from ksiegowosc.pracownicy
--b)
select id_pracownika from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
where p.kwota > 1000;
--c)
select w.id_pracownika from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
join ksiegowosc.premia pr on w.id_premii = pr.id_premii
where pr.kwota = 0 and p.kwota > 2000;
--d)
select * from ksiegowosc.pracownicy where imie like 'J%';
--e)
select * from ksiegowosc.pracownicy where nazwisko like '%n%' and imie like '%a';
--f)
select p.imie, p.nazwisko, (g.liczba_godzin - 160) as nadgodziny
from ksiegowosc.pracownicy p
join ksiegowosc.godziny g on p.id_pracownika = g.id_pracownika
where g.liczba_godzin > 160;
--g)
select pr.imie, pr.nazwisko from ksiegowosc.pracownicy pr
join ksiegowosc.wynagrodzenie w on pr.id_pracownika = w.id_pracownika
join ksiegowosc.pensja pe on w.id_pensji = pe.id_pensji
where pe.kwota between 1500 and 3000;
--h)
select distinct pr.imie, pr.nazwisko from ksiegowosc.pracownicy pr
join ksiegowosc.godziny g on pr.id_pracownika = g.id_pracownika
join ksiegowosc.wynagrodzenie w on pr.id_pracownika = w.id_pracownika
where g.liczba_godzin > 160 and w.id_premii is null;
--i)
select pr.imie, pr.nazwisko, pe.kwota from ksiegowosc.pracownicy pr
join ksiegowosc.wynagrodzenie w on pr.id_pracownika = w.id_pracownika
join ksiegowosc.pensja pe on w.id_pensji = pe.id_pensji
order by pe.kwota desc;
--j)
select pr.imie, pr.nazwisko, pe.kwota as pensja, coalesce(pre.kwota,0) as premia, (pe.kwota + coalesce(pre.kwota,0)) as suma 
from ksiegowosc.pracownicy pr
join ksiegowosc.wynagrodzenie w on pr.id_pracownika = w.id_pracownika
join ksiegowosc.pensja pe on w.id_pensji = pe.id_pensji
left join ksiegowosc.premia pre on w.id_premii = pre.id_premii
order by suma desc;
--k)
select stanowisko, count(*) as liczba_pracownikow from ksiegowosc.pensja p
join ksiegowosc.wynagrodzenie w on p.id_pensji = w.id_pensji
group by stanowisko;
--l)
select avg(kwota) as srednia, min(kwota) as minimalna, max(kwota) as maksymalna 
from ksiegowosc.pensja where stanowisko = 'Manager';
--m)
select sum(p.kwota + coalesce(pr.kwota, 0)) as suma from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
left join ksiegowosc.premia pr on w.id_premii = pr.id_premii;
--n)
select p.stanowisko, sum(p.kwota + coalesce(pr.kwota, 0)) as suma from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
left join ksiegowosc.premia pr on w.id_premii = pr.id_premii
group by p.stanowisko;
--o)
select p.stanowisko, count(w.id_premii) as liczba_premii from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
group by p.stanowisko;
--p)
--sprawdzenie kogo należy usunąć
select w.id_pracownika, p.imie, p.nazwisko, pe.kwota
from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja pe on w.id_pensji = pe.id_pensji
join ksiegowosc.pracownicy p on w.id_pracownika = p.id_pracownika
where pe.kwota < 1200;
--usuwanie z innych tabel
delete from ksiegowosc.wynagrodzenie
where id_pracownika in (
select w.id_pracownika
from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
where p.kwota < 1200
);


delete from ksiegowosc.godziny
where id_pracownika in (
select w.id_pracownika
from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
where p.kwota < 1200
);


delete from ksiegowosc.pracownicy
where id_pracownika in (
select w.id_pracownika
from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on w.id_pensji = p.id_pensji
where p.kwota < 1200
);
