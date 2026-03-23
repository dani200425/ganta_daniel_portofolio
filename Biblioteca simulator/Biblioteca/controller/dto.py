from dataclasses import dataclass


@dataclass
class ClientNumber:
    nume: str
    number: float


class ClientNumberDTOAssembler:
    @staticmethod
    def create_client_dto(client, client_inchirieri):
        nume = client.get_nume()
        n = len(client_inchirieri)

        return (nume, n)

