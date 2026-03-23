class Client:

    def __init__(self, id, nume, CNP):
        """
        Metoda ce initializeaza un Client cu valorile dorite pentru atributele id_client, nume si cnp
        :param id: id-ul clientului (unic)
        :param nume: numele clientului
        :param CNP: cnp-ul clientului (unic)
        """
        self.__id = id
        self.__nume = nume
        self.__CNP = CNP

    def get_id(self):
        return self.__id

    def get_nume(self):
        return self.__nume

    def get_CNP(self):
        return self.__CNP

    def set_id(self, id_nou):
        self.__id = id_nou

    def set_nume(self, nume_nou):
        self.__nume = nume_nou

    def set_CNP(self, CNP_nou):
        self.__CNP = CNP_nou

    def __str__(self):
        return f"id_client: {self.__id}, nume:{self.__nume}, CNP: {self.__CNP}"

