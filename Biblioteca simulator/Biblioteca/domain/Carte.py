# Varianta 1
class Carte:

    def __init__(self, id, titlu, descriere, autor):
        self.__id = id
        self.__titlu = titlu
        self.__descriere = descriere
        self.__autor = autor

    def get_id(self):
        return self.__id

    def get_titlu(self):
        return self.__titlu

    def get_descriere(self):
        return self.__descriere

    def get_autor(self):
        return self.__autor

    def set_id(self, id_nou):
        self.__id = id_nou

    def set_titlu(self, titlu_nou):
        self.__titlu = titlu_nou

    def set_descriere(self, descriere_noua):
        self.__descriere = descriere_noua

    def set_autor(self, autor_nou):
        self.__autor = autor_nou

    def __str__(self):
        return f"id_carte: {self.__id}, titlu:{self.__titlu}, descriere: {self.__descriere}, autor: {self.__autor}"


# Varianta 2
"""class Carte:
    def __init__(self, id_carte, titlu, descriere, autor):
        self.__id_carte = id_carte
        self.__titlu = titlu
        self.__descriere = descriere
        self.__autor = autor

    @property
    def id_carte(self):
        return self.__id_carte

    @id_carte.setter
    def id_carte(self, value):
        self.__id_carte = value

    @property
    def titlu(self):
        return self.__titlu

    @titlu.setter
    def titlu(self, value):
        self.__titlu = value

    @property
    def descriere(self):
        return self.__descriere

    @descriere.setter
    def descriere(self, value):
        self.__descriere = value

    @property
    def autor(self):
        return self.__autor

    @autor.setter
    def autor(self, value):
        self.__autor = value

    def __str__(self):
        return f"id_carte: {self.__id_carte}, titlu: {self.__titlu}, descriere: {self.__descriere}, autor: {self.__autor}"
"""


