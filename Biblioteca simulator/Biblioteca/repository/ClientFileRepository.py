from lab79.domain.Client import Client
from lab79.repository.ClientiRepository import ClientiRepository


class ClientFileRepository(ClientiRepository):
    def __init__(self, nume_fisier):
        super().__init__()
        self.__nume_fisier = nume_fisier
        self.citeste_din_fisier()

    def adauga(self, client):
        super().adauga(client)  # cerem metodei adauga din clasa parinte sa adauge clientul in lista de clienti
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def modifica(self, client):
        super().modifica(client)  # cerem metodei adauga din clasa parinte sa modifice clientul in lista de clienti
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def sterge(self, id_client):
        super().sterge(id_client)  # cerem metodei adauga din clasa parinte sa adauge clientul cu acel id din lista de clienti
        self.scrie_in_fisier()  # aceasta lista modificata noi o salvam in fisier

    def citeste_din_fisier(self):
        try:
            f = open(self.__nume_fisier, "r")  # deschidem fisierul in modul CITIRE: "read" (de acolo vine "r")
            linie = f.readline().strip("\n")  # citim o prima linie din fisier si scoatem din ea caracterul "\n" (enter)
            while linie != "":  # daca linia nu e goala (adica: daca nu am ajuns la finalul fisierului)
                lista_atribute = linie.split("   ")  # despartim linia citita folosind separatorul ,
                # lista_atribute va fi o lista ce contine, ca elemente, valorile regasite pe linia curenta
                id = int(lista_atribute[0])  # primul element din lista_atribute e id-ul
                nume = lista_atribute[1]  # al doilea element din lista_atribute e numele clientului
                CNP = int(lista_atribute[2])
                client = Client(id, nume, CNP)  # cream clientul folosind valorile citite din fisier
                super().adauga(client)  # apelam metoda adauga din clasa parinte (adica din clasa ClientiRepository)
                linie = f.readline().strip("\n")  # citim linia urmatoare pe care o vom verifica si prelucra cand intram din nou in while
            f.close()  # la final, inchidem fisierul deschis
        except IOError:
            print("Eroare la deschiderea fisierului " + self.__nume_fisier)  # mesaj de eroare daca nu s-a putut deschide fisierul

    def scrie_in_fisier(self):
        try:
            f = open(self.__nume_fisier, "w")  # deschidem fisierul in modul SCRIERE: "write" (de acolo vine "w")
            lista_clienti = super().get_all()  # din lista noastra de clienti, aducem toti clientii
            for client in lista_clienti:  # parcurgem fiecare student din lista de studenti
                id = client.get_id()
                nume = client.get_nume()
                CNP = client.get_CNP()
                linie = str(id) + "   " + nume + "   " + str(CNP) + "\n" # cream o linie de tipul liniilor pe care le-am citit din fisier (atributele separate prin virgula si \n la final de rand)
                f.write(linie)  # scriem acea linie in fisier
            f.close()  # la final, inchidem fisierul
        except IOError:
            print("Eroare la deschiderea fisierului " + self.__nume_fisier)  # mesaj de eroare daca nu s-a putut deschide fisierul