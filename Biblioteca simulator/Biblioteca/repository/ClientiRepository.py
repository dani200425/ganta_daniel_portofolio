from lab79.repository.Repository import Repository

class ClientiRepository(Repository):

    def __init__(self):
        super().__init__()

    def get_client_by_id(self, id_client_introdus_din_tastatura):
        """
        Metoda care returneaza un student dupa id
        :param id_client_introdus_din_tastatura: id-ul studentului pe care il cautam
        :return: clientul, daca el exista in lista de clienti: None, altfel
        """
        if self.gaseste_dupa_id(id_client_introdus_din_tastatura) is None:
            raise KeyError("Clientul cu acest ID nu exista!")
        for i in range(0, len(self.get_all())):
            client_curent = self.get_all()[i]
            if client_curent.get_id() == id_client_introdus_din_tastatura:
                return client_curent
