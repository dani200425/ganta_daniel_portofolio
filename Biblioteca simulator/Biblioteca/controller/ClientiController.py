from lab79.domain.Client import Client


class ClientiController:

    def __init__(self, repository):
        self.__repository = repository

    def get_all(self):
        """
        Metoda care returneaza lista din repository
        :return: lista din repository
        """
        return self.__repository.get_all()

    def adauga(self, id_client, nume, CNP):
        """
        Metoda prin care adaugam un client in lista (din repository)
        :param id_client:
        :param nume:
        :param CNP:
        :return:
        """
        client = Client(id_client, nume, CNP)
        self.__repository.adauga(client)

    def modifica(self, id_client, nume_nou, CNP_nou):
        """
        Metoda prin care modificam datele clientilor in functie de id:
        :param id_client:
        :param nume_nou:
        :param CNP_nou:
        :return:
        """
        client_nou = Client(id_client, nume_nou, CNP_nou)
        self.__repository.modifica(client_nou)

    def sterge(self, id_client):
        """
        Metoda prin care stergem un client din lista (din repository)
        :param id_client:
        :return:
        """
        self.__repository.sterge(id_client)



