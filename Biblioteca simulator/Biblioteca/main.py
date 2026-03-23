from lab79.controller.InchiriereController import InchiriereController
from lab79.controller.CartiController import CartiController
from lab79.controller.ClientiController import ClientiController
from lab79.repository.CarteFileRepository import CarteFileRepository
from lab79.repository.ClientFileRepository import ClientFileRepository
from lab79.repository.InchiriereFileRepository import InchiriereFileRepository
from lab79.ui.UI import UI


def main():
    carte_repository = CarteFileRepository("carte.txt")
    client_repository = ClientFileRepository("clienti.txt")
    inchiriere_repository = InchiriereFileRepository("inchiriere.txt", carte_repository, client_repository)

    carte_controller = CartiController(carte_repository)
    client_controller = ClientiController(client_repository)
    inchiriere_controller = InchiriereController(inchiriere_repository, carte_repository, client_repository)

    ui = UI(carte_controller, client_controller, inchiriere_controller, carte_repository, client_repository)

    ui.program()


if __name__ == '__main__':
    main()
