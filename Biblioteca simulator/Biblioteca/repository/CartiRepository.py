from lab79.repository.Repository import Repository


class CartiRepository(Repository):

    def __init__(self):
        super().__init__()

    def get_carte_by_id(self, id_carte_introdus_din_tastatura):
        """
        Metoda care afiseaza o carte cautata doar cu id-ul
        :param id_carte_introdus_din_tastatura:
        :return: carte
        """
        if self.gaseste_dupa_id(id_carte_introdus_din_tastatura) is None:
            raise KeyError("Cartea cu acest id nu există!")
        for i in range(0, len(self.get_all())):
            carte_curenta = self.get_all()[i]
            if carte_curenta.get_id() == id_carte_introdus_din_tastatura:
                return carte_curenta

