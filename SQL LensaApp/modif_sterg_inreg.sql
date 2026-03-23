use LENSA

update Angajati
set salariu=salariu*1.5 --majorare cu 50%
where functie='Vanzator' OR NOT (functie = 'Manager');
select * from Angajati

UPDATE Produse
SET pret = pret * 0.95 --reducere cu 5%
WHERE id_brand = 1 AND stoc > 40;
select * from Produse

update Clienti
set email=NULL
where data_inregistrare between '2024-08-08' and '2024-08-10';
select * from Clienti

DELETE FROM Angajati
WHERE salariu <= 4000 AND nume LIKE '%u'
select * from Angajati

delete from Furnizori
where tara !='Romania'
select * from Furnizori

delete from Furnizori
where not (tara='Romania') and email is null
select * from Furnizori


--cross product
Select *
from Clienti, Angajati