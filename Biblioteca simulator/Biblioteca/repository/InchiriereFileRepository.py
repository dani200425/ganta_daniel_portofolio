from lab79.domain.Inchiriere import Inchiriere
from lab79.repository.InchiriereRepository import InchiriereRepository


class InchiriereFileRepository(InchiriereRepository):
    def __init__(self, nume_fisier, inchiriere_repository, clienti_repository):
        super().__init__(inchiriere_repository, clienti_repository)
        self.__nume_fisier = nume_fisier
        self.citeste_din_fisier()

    def adauga(self, inchiriere):
        super().adauga(inchiriere)  # cerem metodei adauga din clasa parinte sa adauge inchirierea in lista de inchirieri
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def sterge(self, id):
        super().sterge(id)  # cerem metodei adauga din clasa parinte sa adauge inscrierea cu acel id din lista de inscrieri
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def citeste_din_fisier(self):
        try:
            f = open(self.__nume_fisier, "r")  # deschidem fisierul in modul CITIRE: "read" (de acolo vine "r")
            linie = f.readline().strip("\n")  # citim o prima linie din fisier si scoatem din ea caracterul "\n" (enter)
            while linie != "":  # daca linia nu e goala (adica: daca nu am ajuns la finalul fisierului)
                lista_atribute = linie.split("   ")  # despartim linia citita folosind separatorul ,
                # lista_atribute va fi o lista ce contine, ca elemente, valorile regasite pe linia curenta
                id = int(lista_atribute[0])  # primul element din lista_atribute e id-ul inchirierii
                carte_id = int(lista_atribute[1])  # al doilea element din lista_atribute e id-ul cartii
                client_id = int(lista_atribute[2])  # al treilea element din lista_atribute e id-ul clientului
                inchiriere = Inchiriere(id, carte_id, client_id)  # cream inchirierea folosind valorile citite din fisier
                super().adauga(inchiriere)  # apelam metoda adauga din clasa parinte (adica din clasa InscriereRepository)
                linie = f.readline().strip("\n")  # citim linia urmatoare pe care o vom verifica si prelucra cand intram din nou in while
            f.close()  # la final, inchidem fisierul deschis
        except IOError:
            print("Eroare la deschiderea fisierului " + self.__nume_fisier)  # mesaj de eroare daca nu s-a putut deschide fisierul

    def scrie_in_fisier(self):
        try:
            f = open(self.__nume_fisier, "w")  # deschidem fisierul in modul SCRIERE: "write" (de acolo vine "w")
            lista_inchirieri = super().get_all()  # din lista noastra de inchirieri, aducem toate inchirierile
            for inchiriere in lista_inchirieri:  # parcurgem fiecare inchiriere din lista de inchirieri
                id = inchiriere.get_id()
                carte_id = inchiriere.get_carte_id()
                client_id = inchiriere.get_client_id()
                linie = str(id) + "   " + str(carte_id) + "   " + str(client_id) + "\n"  # cream o linie de tipul liniilor pe care le-am citit din fisier (atributele separate prin virgula si \n la final de rand)
                f.write(linie)  # scriem acea linie in fisier
            f.close()  # la final, inchidem fisierul
        except IOError:
            print("Eroare la deschiderea fisierului " + self.__nume_fisier)  # mesaj de eroare daca nu s-a putut deschide fisierul