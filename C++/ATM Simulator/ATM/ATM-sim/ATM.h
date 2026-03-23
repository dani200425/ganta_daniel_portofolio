#ifndef ATM_H
#define ATM_H

#include "Collection.h"
#include "Tranzactie.h"

template<typename T>
class ATM {
private:
    int last_id;
    Tranzactie<T>* tranzactii;
    Collection<T> bancnote_disponibile;

public:
    ATM();
    void adauga_bancnote(T valoare_bancnota, int frecventa);
    void retragere(int suma);


    void adauga_tranzactie(int suma, const Collection<T>& bancnote);

    void afiseaza_bancnote_disponibile();
    void bubbleSortATM();

    void sortByID();

    void afiseaza_tranzactiile();

    void printTranzactiiSortate();

    void sortByTimestamp();

    void sortBySuma();

    void sortByBancnote();
};

#include "ATM.tpp"
#endif //ATM_H
