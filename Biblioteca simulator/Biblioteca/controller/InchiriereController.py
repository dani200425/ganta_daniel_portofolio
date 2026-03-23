from lab79.domain.Inchiriere import Inchiriere
from lab79.controller.dto import ClientNumberDTOAssembler


class InchiriereController:

    def __init__(self, inchiriere_repository, carte_repository, client_repository):
        self.__inchiriere_repository = inchiriere_repository
        self.__carte_repository = carte_repository
        self.__client_repository = client_repository

    def get_all(self):
        return self.__inchiriere_repository.get_all()

    def adauga(self, id, carte_id, client_id):
        inchiriere = Inchiriere(id, carte_id, client_id)
        self.__inchiriere_repository.adauga(inchiriere)

    def sterge(self, id):
        """
        Metoda prin care stergem o inchiriere din lista (din repository)
        :param id:
        :return:
        """
        self.__inchiriere_repository.sterge(id)

    def __get_client_inchirieri(self, client):
        client_inchirieri = self.__inchiriere_repository.get_all()
        return list(filter(lambda inchiriere: inchiriere.get_client_id() == client.get_id(), client_inchirieri))

    def __create_clients_dtos(self):
        clients_dtos = []

        for client in self.__client_repository.get_all():
            client_inchirieri = self.__get_client_inchirieri(client)
            dto = ClientNumberDTOAssembler.create_client_dto(client, client_inchirieri)
            clients_dtos.append(dto)
        
        return clients_dtos

    def get_clienti_cu_nr_de_inchirieri(self):
        """Metoda ce returneaza un dictionar care mapeaza numele clientului si numarul de inchirieri realizate cu id-ul da
         :return: un dictionar care mapeaza numele clientului si inchirierile realizate cu id-ul dat
         """
        clients_dtos = self.__create_clients_dtos()

        return clients_dtos

    @staticmethod
    def sorted_clienti_in_functie_de_inchirieri(dictionar_client_inchirieri):
        dictionar_sortat = sorted(dictionar_client_inchirieri.items(), reverse=True, key=lambda d: (d[1]))
        return dictionar_sortat

    @staticmethod
    def cei_mai_activi_clienti(dictionar_client_inchirieri):
        dictionar_sortat = sorted(dictionar_client_inchirieri.items(), reverse=True, key=lambda d: (d[1]))[:len(dictionar_client_inchirieri) // 5]
        return dictionar_sortat

    def carti_si_nr_de_inchirieri(self):
        inchirieri = self.get_all()
        carti = self.__carte_repository.get_all()
        dictionar_cu_carti_si_inchirieri = {}
        for carte in carti:  # luam fiecare carte din biblioteca
            nr_de_inchirieri_carte = 0
            for inchiriere in inchirieri:  # pt a numara de cate ori este inchiriata atunci intram in baza de date: inchieriere
                id_carte = carte.get_id()
                carte_id_curent = inchiriere.get_carte_id()
                if carte_id_curent == id_carte:
                    nr_de_inchirieri_carte = nr_de_inchirieri_carte + 1
                    titlu_carte = carte.get_titlu()
                    dictionar_cu_carti_si_inchirieri[titlu_carte] = nr_de_inchirieri_carte
        return dictionar_cu_carti_si_inchirieri

    @staticmethod
    def cele_mai_inchiriate_carti(dictionar_carti_inchirieri, nr_maxim_carti_afisate):
        dictionar_sortat = sorted(dictionar_carti_inchirieri.items(), reverse=True, key=lambda d: (d[1]))[:nr_maxim_carti_afisate]
        return dictionar_sortat
