class Inchiriere:

    def __init__(self, id, carte_id, client_id):
        self.__id = id
        self.__carte_id = carte_id
        self.__client_id = client_id

    def get_id(self):
        return self.__id

    def get_carte_id(self):
        return self.__carte_id

    def get_client_id(self):
        return self.__client_id

    def set_id(self, id_nou):
        self.__id = id_nou

    def set_carte_id(self, carte_id_nou):
        self.__carte_id = carte_id_nou

    def set_client_id(self, client_id_nou):
        self.__client_id = client_id_nou

    def __str__(self):
        return f"ID_inchiriere: {self.__id}, ID_carte:{self.__carte_id}, ID_client: {self.__client_id}"


