from lab79.domain.ClientiValidator import ClientiValidator
from lab79.domain.ValidatorException import ValidatorException
from lab79.repository.RepositoryException import DuplicateIDException, InexistentIDException


class UI:

    def __init__(self, carte_controller, client_controller, inchiriere_controller, repository_carte, repository_client):
        self.__carte_controller = carte_controller
        self.__client_controller = client_controller
        self.__inchiriere_controller = inchiriere_controller
        self.__repository_carte = repository_carte
        self.__repository_client = repository_client
        self.__clienti_validator = ClientiValidator()

    @staticmethod
    def meniu():
        meniu = ""
        meniu += "1. Tipareste toate cartile.\n"
        meniu += "2. Adauga carte.\n"
        meniu += "3. Sterge carte.\n"
        meniu += "4. Modifica carte.\n"
        meniu += "5. Cauta carte folosind ID.\n"
        meniu += "6. Tipareste toti clientii.\n"
        meniu += "7. Adauga client.\n"
        meniu += "8. Sterge client.\n"
        meniu += "9. Modifica client.\n"
        meniu += "10. Cauta client folosind ID.\n"
        meniu += "11. Tipareste toate inchirierile.\n"
        meniu += "12. Adauga inchiriere.\n"
        meniu += "0. Iesire\n"
        return meniu

    def program(self):
        ruleaza = True
        while ruleaza is True:
            meniul_meu = self.meniu()
            print(meniul_meu)
            comanda = input("Introduceti comanda:")
            if comanda == "1":
                self.ui_tipareste_carti()
            elif comanda == "2":
                self.ui_adauga_carte()
            elif comanda == "3":
                self.ui_sterge_carte()
            elif comanda == "4":
                self.ui_modifica_carte()
            elif comanda == "5":
                self.ui_get_carte_by_id()
            elif comanda == "6":
                self.ui_tipareste_clienti()
            elif comanda == "7":
                self.ui_adauga_client()
            elif comanda == "8":
                self.ui_sterge_client()
            elif comanda == "9":
                self.ui_modifica_client()
            elif comanda == "10":
                self.ui_get_client_by_id()
            elif comanda == "11":
                self.ui_tipareste_inchirieri()
            elif comanda == "12":
                self.ui_adauga_inchiriere()
            elif comanda == "0":
                ruleaza = False
            else:
                print("Comanda gresita! Reincercati!")

    def ui_tipareste_carti(self):
        carti = self.__carte_controller.get_all()
        if len(carti) == 0:
            print("Lista de carti e goala!")
        for carte in carti:
            print(carte)

    def ui_adauga_carte(self):
        try:
            id_carte = int(input("Introduceti id:"))
            titlu = str(input("Introduceti titlu:"))
            descriere = str(input("Introduceti descrierea:"))
            autor = str(input("Introduceti autor: "))
            self.__carte_controller.adauga(id_carte, titlu, descriere, autor)
        except ValueError:
            print("Date gresite! Reincercati!")
        except DuplicateIDException as de:
            print(de)

    def ui_sterge_carte(self):
        try:
            id_carte = int(input("Introduceti id-ul cartii pe care doriti sa o stergeti:"))
            self.__carte_controller.sterge(id_carte)
        except ValueError:
            print("Date gresite! Reincercati!")
        except InexistentIDException as ie:
            print(ie)

    def ui_modifica_carte(self):
        try:
            id_carte = int(input("Introduceti id-ul cartii pe care doriti sa o modificiati:"))
            titlu_nou = input("Introduceti titlul nou:")
            descriere_noua = input("Introduceti descrierea cartii noua:")
            autor_nou = input("Introduceti autorul nou:")
            self.__carte_controller.modifica(id_carte, titlu_nou, descriere_noua, autor_nou)
        except ValueError:
            print("Date gresite! Reincercati!")
        except InexistentIDException as ie:
            print(ie)

    def ui_get_carte_by_id(self):
        try:
            id_carte_introdus_din_tastatura = int(input("Introduceti id-ul cartii cautate: "))
            carte_cautata = self.__repository_carte.get_carte_by_id(id_carte_introdus_din_tastatura)
            print(carte_cautata)
        except ValueError:
            print("Date gresite! Reincercati!")
        except KeyError as ke:
            print(ke)

    def ui_tipareste_clienti(self):
        clienti = self.__client_controller.get_all()
        if len(clienti) == 0:
            print("Lista de clienti e goala!")
        for client in clienti:
            print(client)

    def ui_adauga_client(self):
        try:
            id_client = int(input("Introduceti id:"))
            nume = input("Introduceti nume:")
            self.__clienti_validator.valideaza_nume(nume)
            CNP = int(input("Introduceti CNP:"))
            self.__clienti_validator.valideaza_cnp(CNP)
            self.__client_controller.adauga(id_client, nume, CNP)
        except ValueError:
            print("Date gresite! Reincercati!")
        except DuplicateIDException as de:
            print(de)
        except ValidatorException as ve:
            print(ve)

    def ui_sterge_client(self):
        try:
            id_client = int(input("Introduceti id-ul clientului pe care doriti sa-l stergeti:"))
            self.__client_controller.sterge(id_client)
        except ValueError:
            print("Date gresite! Reincercati!")
        except InexistentIDException as ie:
            print(ie)

    def ui_modifica_client(self):
        try:
            id_client = int(input("Introduceti id-ul clientului pe care doriti sa o modificiati:"))
            nume_nou = input("Introduceti nume nou:")
            self.__clienti_validator.valideaza_nume(nume_nou)
            CNP_nou = int(input("Introduceti CNP nou:"))
            self.__clienti_validator.valideaza_cnp(CNP_nou)
            self.__client_controller.modifica(id_client, nume_nou, CNP_nou)
        except ValueError:
            print("Date gresite! Reincercati!")
        except InexistentIDException as ie:
            print(ie)
        except ValidatorException as ve:
            print(ve)

    def ui_get_client_by_id(self):
        try:
            id_client_introdus_din_tastatura = int(input("ID client cautat: "))
            client = self.__repository_client.get_client_by_id(id_client_introdus_din_tastatura)
            print(client)
        except ValueError:
            print("Date gresite! Reincercati!")
        except KeyError as ke:
            print(ke)

    def ui_tipareste_inchirieri(self):
        inchirieri = self.__inchiriere_controller.get_all()
        if len(inchirieri) == 0:
            print("Lista de inchirieri e goala!")
        for inchiriere in inchirieri:
            print(inchiriere)

    def ui_adauga_inchiriere(self):
        try:
            id = int(input("Introduceti id:"))
            carte_id = int(input("Introduceti id-ul cartii pe care a inchiriat-o:"))
            client_id = int(input("Introduceti id-ul clientului:"))
            self.__inchiriere_controller.adauga(id, carte_id, client_id)
        except ValueError:
            print("Date gresite! Reincercati!")
        except KeyError as ke:
            print(ke)
        except DuplicateIDException as de:
            print(de)
