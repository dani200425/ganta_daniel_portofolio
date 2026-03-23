#ifndef ATM_TPP
#define ATM_TPP
#include <algorithm>
#include <functional>
#include <vector>

#include "ATM.h"
#include "Iterator.h"
# include "Collection.h"

template<typename T>
ATM<T>::ATM() {
    last_id = 0;
    tranzactii = nullptr;
}

template<typename T>
void ATM<T>::adauga_bancnote(T valoare_bancnota, int frecventa) {
    for (int i = 0; i < frecventa; i++) {
        bancnote_disponibile.add(valoare_bancnota);
    }
    adauga_tranzactie(valoare_bancnota * frecventa, bancnote_disponibile);
}

template<typename T>
void ATM<T>::retragere(int suma) {
    if (suma <= 0) {
        std::cout << "Suma invalida.\n";
        return;
    }

    // Calculează suma totală disponibilă
    int suma_totala = 0;
    for (int i = 0; i < bancnote_disponibile.size(); i++) {
        T bancnota = bancnote_disponibile.getAt(i);
        suma_totala += bancnota * bancnote_disponibile.nrOccurences(bancnota);
    }

    if (suma > suma_totala) {
        std::cout << "Fonduri insuficiente.\n";
        return;
    }

    // Creează o copie sortată a bancnotelor disponibile
    Collection<T> sorted_bancnote;
    for (int i = 0; i < bancnote_disponibile.size(); i++) {
        T bancnota = bancnote_disponibile.getAt(i);
        int frecventa = bancnote_disponibile.nrOccurences(bancnota);
        for (int j = 0; j < frecventa; j++) {
            sorted_bancnote.add(bancnota);
        }
    }
    sorted_bancnote.sortDescending();

    Collection<T> bancnote_retrase;
    int suma_ramasa = suma;

    // Încearcă să retragă suma exactă
    for (int i = 0; i < sorted_bancnote.size() && suma_ramasa > 0; i++) {
        T bancnota = sorted_bancnote.getAt(i);
        if (bancnota <= suma_ramasa) {
            int nr_necesar = suma_ramasa / bancnota;
            int nr_disponibil = sorted_bancnote.nrOccurences(bancnota);
            int nr_retrase = std::min(nr_necesar, nr_disponibil);

            if (nr_retrase > 0) {
                for (int j = 0; j < nr_retrase; j++) {
                    bancnote_retrase.add(bancnota);
                }
                suma_ramasa -= bancnota * nr_retrase;
                sorted_bancnote.removeMultiple(bancnota, nr_retrase);
            }
        }
    }

    if (suma_ramasa == 0) {
        // Actualizează bancnotele din ATM folosind removeMultiple
        for (int i = 0; i < bancnote_retrase.size(); i++) {
            T bancnota = bancnote_retrase.getAt(i);
            int frecventa = bancnote_retrase.nrOccurences(bancnota);
            bancnote_disponibile.removeMultiple(bancnota, frecventa);
            i += frecventa - 1; // Sari peste aparițiile aceleiași bancnote
        }
        std::cout << "Retragere reusita. Bancnote retrase:\n";
        bancnote_retrase.print_all();
        adauga_tranzactie(suma, bancnote_retrase);
    } else {
        std::cout << "Nu se poate retrage suma exacta cu bancnotele disponibile.\n";
    }
}

template<typename T>
void ATM<T>::adauga_tranzactie(int suma, const Collection<T>& bancnote_folosite) {
    Tranzactie<T>* noua_tranzactie = new Tranzactie<T>(++last_id, suma, bancnote_folosite);
    noua_tranzactie->urmator = tranzactii;
    tranzactii = noua_tranzactie;
}

template<typename T>
void ATM<T>::afiseaza_bancnote_disponibile() {
    std::cout << "Bancnotele disponibile in ATM sunt:\n";
    std::cout << "Debug: Bancnote disponibile - Size: " << bancnote_disponibile.size() << "\n";

    bancnote_disponibile.print_all();
}

template<typename T>
void ATM<T>::afiseaza_tranzactiile() {
    if (!tranzactii) {
        std::cout << "Nu exista tranzactii de afisat.\n";
        return;
    }
    Iterator<T> it(tranzactii);
    while (it.isValid()) {
        const Tranzactie<T>& tranz = it.getCurrent();
        std::time_t timestamp = tranz.getTimestamp(); // Salvează valoarea

        std::cout << "ID: " << tranz.getId()
                  << " | Suma: " << tranz.getSuma()
                  << " | Data: " << std::ctime(&timestamp); // Folosește adresa variabilei locale
        it.next();
    }
}


template<typename T>
void ATM<T>::printTranzactiiSortate() {
    std::cout << "Tranzactiile sortate sunt:\n";
    Tranzactie<T>* current = tranzactii;
    while (current) {
        current->print();
        current = current->urmator;
    }
}

template<typename T>
void ATM<T>::bubbleSortATM() {
    Tranzactie<T>::bubbleSort(tranzactii);
    std::cout << "Tranzactii sortate dupa data, suma si bancnote:\n";
    afiseaza_tranzactiile();
}

template<typename T>
void ATM<T>::sortByID() {
    Tranzactie<T>::bubbleSortID(tranzactii);
    std::cout << "Tranzactii sortate dupa ID:\n";
    afiseaza_tranzactiile();
}

template<typename T>
void ATM<T>::sortByTimestamp() {
    bubbleSort1(tranzactii, comparatorByTimestamp<T>);
    std::cout << "Tranzactii sortate dupa data:\n";
    afiseaza_tranzactiile();
}

template<typename T>
void ATM<T>::sortBySuma() {
    bubbleSort1(tranzactii, comparatorBySuma<T>);
    std::cout << "Tranzactii sortate dupa suma:\n";
    afiseaza_tranzactiile();
}

template<typename T>
void ATM<T>::sortByBancnote() {
    bubbleSort1(tranzactii, comparatorByBancnote<T>);
    std::cout << "Tranzactii sortate dupa numar bancnote:\n";
    afiseaza_tranzactiile();
}
#endif //ATM_TPP
