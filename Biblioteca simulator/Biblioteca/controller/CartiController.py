from lab79.domain.Carte import Carte


class CartiController:

    def __init__(self, repository):
        self.__repository = repository

    def get_all(self):
        """
        Metoda ce returneaza lista de obiecte din repository
        :return: lista de obiecte din repository
        """
        return self.__repository.get_all()

    def adauga(self, id_carte, titlu, descriere, autor):
        """
        Metoda prin care adaugam o carte in lista (din repository)
        :param id_carte: 
        :param titlu: 
        :param descriere: 
        :param autor: 
        :return: 
        """
        carte = Carte(id_carte, titlu, descriere, autor)
        self.__repository.adauga(carte)

    def modifica(self, id_carte, titlu_nou, descriere_noua, autor_nou):
        """
        Metoda prin care modificam datele unei carti dupa id:
        :param id_carte:
        :param titlu_nou:
        :param descriere_noua:
        :param autor_nou:
        :return:
        """
        carte_noua = Carte(id_carte, titlu_nou, descriere_noua, autor_nou)
        self.__repository.modifica(carte_noua)

    def sterge(self, id_carte):
        """
        Metoda care stergem o carte din lista (din repository)
        :param id_carte:
        :return:
        """
        self.__repository.sterge(id_carte)


