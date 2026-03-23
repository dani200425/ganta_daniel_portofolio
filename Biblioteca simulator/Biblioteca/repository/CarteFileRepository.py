from lab79.domain.Carte import Carte
from lab79.repository.CartiRepository import CartiRepository


class CarteFileRepository(CartiRepository):

    def __init__(self, nume_fisier):
        super().__init__()
        self.__nume_fisier = nume_fisier
        self.citeste_din_fisier()

    def adauga(self, carte: Carte):
        super().adauga(carte)  # cerem metodei adauga din clasa parinte sa adauge cartea in lista de carti

        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def modifica(self, carte):
        super().modifica(carte)  # cerem metodei adauga din clasa parinte sa modifice cartea in lista de carti
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def sterge(self, id):
        super().sterge(id)  # cerem metodei adauga din clasa parinte sa adauge cartea cu acel id din lista de carti
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def citeste_din_fisier(self):
        try:
            f = open(self.__nume_fisier, "r")  # deschidem fisierul in modul CITIRE: "read" (de acolo vine "r")
            linie = f.readline().strip("\n")  # citim o prima linie din fisier si scoatem din ea caracterul "\n" (enter)
            while linie != "":  # daca linia nu e goala (adica: daca nu am ajuns la finalul fisierului)
                lista_atribute = linie.split("   ")  # despartim linia citita folosind separatorul ,
                # lista_atribute va fi o lista ce contine, ca elemente, valorile regasite pe linia curenta
                id_carte = int(lista_atribute[0])  # primul element din lista_atribute e id-ul
                titlu = lista_atribute[1]  # al doilea element din lista_atribute e titlul cartii
                descriere = lista_atribute[2]  # al treilea element din lista_atribute e descrierea cartii
                autor = lista_atribute[3]
                carte = Carte(id_carte, titlu, descriere, autor)  # cream cartea folosind valorile citite din fisier
                super().adauga(carte)  # apelam metoda adauga din clasa parinte (adica din clasa CartiRepository)
                linie = f.readline().strip("\n")  # citim linia urmatoare pe care o vom verifica si prelucra cand intram din nou in while
            f.close()  # la final, inchidem fisierul deschis
        except IOError:
            print("Eroare la deschiderea fisierului " + self.__nume_fisier)  # mesaj de eroare daca nu s-a putut deschide fisierul

    def scrie_in_fisier(self):
        try:
            f = open(self.__nume_fisier, "w")  # deschidem fisierul in modul SCRIERE: "write" (de acolo vine "w")
            lista_carti = super().get_all()  # din lista noastra de carti, aducem toate cartile
            for carte in lista_carti:  # parcurgem fiecare disciplina din lista de discipline
                id = carte.get_id()
                titlu = carte.get_titlu()
                descriere = carte.get_descriere()
                autor = carte.get_autor()
                linie = str(id) + "   " + titlu + "   " + descriere + "   " + autor + "\n"  # cream o linie de tipul liniilor pe care le-am citit din fisier (atributele separate prin virgula si \n la final de rand)
                f.write(linie)  # scriem acea linie in fisier
            f.close()  # la final, inchidem fisierul
        except IOError:
            print("Eroare la deschiderea fisierului " + self.__nume_fisier)  # mesaj de eroare daca nu s-a putut deschide fisierul

