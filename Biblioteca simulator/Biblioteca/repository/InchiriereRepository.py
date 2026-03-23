from lab79.repository.Repository import Repository


class InchiriereRepository(Repository):

    def __init__(self, carti_repository, clienti_repository):
        super().__init__()
        # in InchiriereRepository pastram referinte spre CartiRepository si ClientiRepository
        self.__carti_repository = carti_repository
        self.__client_repository = clienti_repository

    def adauga(self, inchiriere):
        id = inchiriere.get_id()
        if self.gaseste_inchiriere_dupa_id(id) is not None:
            # nu adaugam inchiriere daca exista deja o inchiriere cu acest id
            raise KeyError("Inchirierea cu acest id exista deja!")
        else:
            carte_id = inchiriere.get_carte_id()
            client_id = inchiriere.get_client_id()
            # aici vom folosi faptul ca am initializat si referinte spre clientiRepository si cartiRepository
            # verificam ca client_id sa fie id-ul unui client existent in clientiRepository
            # de aceea avem nevoie de referinta spre clientiRepository, ca sa putem avea acces la lista de clienti, sa facem verificarea
            # procedam la fel si pentru carte_id
            # daca oricare dintre carte_id si client_id nu sunt id-urile unui client/carte din repository-urile corespunzatoare, nu facem adaugarea
            if self.__carti_repository.gaseste_dupa_id(carte_id) is None:
                raise KeyError("Cartea cu acest ID nu exista!")
            elif self.__client_repository.gaseste_dupa_id(client_id) is None:
                raise KeyError("Clientul cu acest ID nu exista!")
            elif self.gaseste_inchiriere_dupa_carte_id_si_client_id(carte_id, client_id) is not None:
                # daca exista deja in lista de inchirieri o ichiriere cu aceeasi carte_id si client_id, nu facem adaugarea
                raise KeyError("Aceasta inchiriere deja exista!")
            # daca totul e in regula, adaugam inchirierea in lista
            super().adauga(inchiriere)

    def gaseste_inchiriere_dupa_id(self, id):
        """
        Metoda care gaseste o inchiriere in lista de inchirieri, dupa id inchirieri
        :param: id: id-ul inchiriere cautate
        :return: pozitia obiectului de tip inchiriere cu id-ul dat in self.__lista_inchirieri;
                None daca nu exista
        """
        for i in range(0, len(self._lista)):
            inchiriere_curenta = self._lista[i]
            if inchiriere_curenta.get_id() == id:
                return i

    def gaseste_inchiriere_dupa_carte_id_si_client_id(self, carte_id, client_id):
        """
        Metoda care gaseste o inchiriere in lista de inchirieri, dupa id carte si id client
        :param: carte_id:
        :param: client_id:
        :return: pozitia unui obiect de tip inchiriere cu id carte si id client date in self.__lista_inchirieri;
                None daca nu exista
        """
        for i in range(0, len(self._lista)):
            inchiriere_curenta = self._lista[i]
            if inchiriere_curenta.get_carte_id() == carte_id and inchiriere_curenta.get_client_id() == client_id:
                return i

