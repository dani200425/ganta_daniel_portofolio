use LENSA

---------------------------------punctul a
SELECT nume, prenume
FROM Clienti
UNION
SELECT nume, prenume
FROM Angajati;
--------------------
SELECT nume, prenume, 'Client' AS Tip
FROM Clienti
WHERE nume = 'Popescu' OR prenume = 'Maria'
UNION ALL
SELECT nume, prenume, 'Angajat' AS Tip
FROM Angajati
WHERE nume = 'Popescu' OR prenume = 'Maria';

SELECT nume, prenume, 'Client' as tip
FROM Clienti
UNION ALL
SELECT nume, prenume, 'Angajat' as tip
FROM Angajati
-------------------------------------------------punctul b
SELECT nume, prenume
FROM Clienti
INTERSECT
SELECT nume, prenume
FROM Angajati;
----------------------
SELECT nume, prenume    ---------------------afiseaza clientii care sunt si angajati
FROM Clienti
WHERE nume IN (
    SELECT nume
    FROM Angajati
);

-------------------------------------------------punctul c
SELECT nume, prenume
FROM Clienti
EXCEPT
SELECT nume, prenume
FROM Angajati;

select nume, prenume
from Clienti
except
select nume, prenume
from Clienti
intersect
select nume, prenume
from Angajati


select nume, prenume
from Clienti
union
select nume, prenume
from Angajati
except
select nume, prenume
from Clienti

select nume, prenume
from Clienti
union
select nume, prenume
from Angajati
except
select nume, prenume
from Angajati


----------------------
SELECT id_produs, nume_produs   ---produs care nu este detinut de nici un furnizor
FROM Produse
WHERE id_produs NOT IN (
    SELECT id_produs
    FROM Furnizori_Produse
);


------------------INNER JOIN-------------------------------punctul d
SELECT ------------se scriu coloanele tabelului
    c.id_comanda,
    cl.nume AS Nume_Client,
    a.nume AS Nume_Angajat,
    p.metoda_plata,
    dc.suma_totala
FROM Comenzi c  ----------------------pe tabelul de comenzi se face inner join, datele comenzii se leaga de celalte tabele
INNER JOIN Clienti cl ON c.id_client = cl.id_client
INNER JOIN Angajati a ON c.id_angajat = a.id_angajat
INNER JOIN Plati p ON c.id_comanda = p.id_comanda
INNER JOIN Detalii_Comenzi dc ON c.id_comanda = dc.id_comanda;
--------------------LEFT JOIN-----------------------------------
SELECT 
    pr.nume_produs,
    pr.pret,
    f.nume_furnizor
FROM Produse pr -------------------------------------pastreaza toate produsele, chiar daca nu exista în Furnizori_Produse
LEFT JOIN Furnizori_Produse fp ON pr.id_produs = fp.id_produs
LEFT JOIN Furnizori f ON fp.id_furnizor = f.id_furnizor;
-------------------RIGHT JOIN------------------------------------
SELECT 
    f.nume_furnizor,
    pr.nume_produs
FROM Produse pr -------------------------------------pastreaza toti furnizorii chit ca nu au aceste produse
RIGHT JOIN Furnizori_Produse fp ON pr.id_produs = fp.id_produs
RIGHT JOIN Furnizori f ON fp.id_furnizor = f.id_furnizor;
--------------------FULL JOIN-----------------------------------
SELECT 
    f.nume_furnizor,
    pr.nume_produs
FROM Produse pr ------------------------------------ ia toti furnizorii si produsele
FULL JOIN Furnizori_Produse fp ON pr.id_produs = fp.id_produs
FULL JOIN Furnizori f ON fp.id_furnizor = f.id_furnizor;

-------------------------------------------------punctul e
SELECT nume, prenume    --------------se afiseaza doar cleintii cu comenzi efectuate
FROM Clienti
WHERE id_client IN (
    SELECT id_client FROM Comenzi
);
-------------------------------------------------------
SELECT nume_produs  -------------------produse care au fost comandate în comenzi platite cu metoda „Card”.
FROM Produse
WHERE id_produs IN (
    SELECT id_produs
    FROM Detalii_Comenzi
    WHERE id_comanda IN (
        SELECT id_comanda
        FROM Plati
        WHERE metoda_plata = 'Card'
    )
);
-------------------------------------------------punctul f
SELECT c.nume, c.prenume
FROM Clienti c
WHERE EXISTS (
    SELECT 1    ---------------verifica ca macar o inregistrare sa existe
    FROM Comenzi co
    WHERE co.id_client = c.id_client
);
-----------------------------------------------------
SELECT p.nume_produs
FROM Produse p
WHERE EXISTS (
    SELECT 1    ------------------produse care au fost livrate de un furnizor dintr-o anumita tara
    FROM Furnizori_Produse fp
    JOIN Furnizori f ON fp.id_furnizor = f.id_furnizor
    WHERE fp.id_produs = p.id_produs
      AND f.tara = 'Romania'
);

-------------------------------------------------punctul g  SUBQUERY        
SELECT rezultat.id_categorie, rezultat.nr_produse
FROM (
    SELECT id_categorie, COUNT(*) AS nr_produse    -- GROUP BY grupeaza produsele în funcție de id_categorie.
                                                   --COUNT(*) calculeaza numarul de randuri (produse) din fiecare grup (adica cate
    FROM Produse
    GROUP BY id_categorie   --------group by vine la pachet cu aggregate function cum e sum,avg,min,max
) AS rezultat
ORDER BY rezultat.nr_produse DESC;
----------------------------------------
SELECT rezultat.nume_produs, rezultat.nr_produse
FROM (
    SELECT nume_produs, stoc AS nr_produse
    FROM Produse
) AS rezultat
ORDER BY rezultat.nr_produse DESC;
-------------------------------------------------punctul h

SELECT id_categorie, COUNT(*) AS nr_produse
FROM Produse
GROUP BY id_categorie;
--------------------
SELECT id_categorie, COUNT(*) AS nr_produse
FROM Produse
GROUP BY id_categorie
HAVING COUNT(*) >= 2;
--------------------
SELECT id_categorie, SUM(stoc) AS total_stoc
FROM Produse
GROUP BY id_categorie
HAVING SUM(stoc) > (
    SELECT AVG(stoc) FROM Produse   ----pastreaza doar acele categorii al caror total_stoc este mai mare decat AVG(stoc) calculat la nivelul intregii tabele Produse
);
-------------------
SELECT id_categorie, AVG(pret) AS pret_mediu
FROM Produse
GROUP BY id_categorie
HAVING AVG(pret) > (
    SELECT AVG(pret) FROM Produse       --pret mediu în categorie
);      --pastrează doar categoriile al caror pret mediu e mai mare decat pretul mediu calculat pe intreaga masa

-------------------------------------------------punctul i
SELECT id_produs, nume_produs, pret
FROM Produse
WHERE pret > ANY (
    SELECT pret FROM Produse WHERE id_categorie = 1 --genereaza o lista de preturi pentru produsele din categoria 1.
    --pret > ANY (lista) inseamna: pastreaza produsele al caror pret este mai mare decat cel putin unul dintre preturile din lista subquery-ului
);
------------------
SELECT id_produs, nume_produs, pret
FROM Produse
WHERE pret > (
    SELECT AVG(pret) FROM Produse WHERE id_categorie = 1    --returnează prețul mediu al produselor din categoria 1
);
------------------
SELECT id_produs, nume_produs, pret
FROM Produse
WHERE pret > ALL (
    SELECT pret FROM Produse WHERE id_categorie = 2     --pastreaza categoriile cu produse cu pret mai mare decat cele din cat.2
);
-----------------
SELECT id_produs, nume_produs, pret
FROM Produse
WHERE pret > (
    SELECT MAX(pret) FROM Produse WHERE id_categorie = 2    -- --pastreaza categoriile cu produse cu pret mai mare decat cele din cat.2
);

