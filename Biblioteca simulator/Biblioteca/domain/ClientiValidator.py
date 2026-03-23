from lab79.domain.ValidatorException import ValidatorException


class ClientiValidator:

    def __init__(self):
        self.__erori = []

    def valideaza_nume(self, nume):
        self.__erori = []
        if len(nume) < 2:
            self.__erori.append("Eroare la validarea clientului: Nume invalid!")
        if len(self.__erori) > 0:
            raise ValidatorException(self.__erori)

    def valideaza_cnp(self, CNP):
        self.__erori = []
        if len(str(CNP)) < 13:
            self.__erori.append("Eroare la validarea clientului: CNP invalid! (are mai putin de 13 caractere)")
        if len(self.__erori) > 0:
            raise ValidatorException(self.__erori)
