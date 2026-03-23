#ifndef TRANZACTIE_H
#define TRANZACTIE_H
#include "Collection.h"
#include <ctime>
#include <iostream>
template<typename T>
class Tranzactie {
private:
    int id;
    int suma;
    Collection<T> bancnote;
    std::time_t timestamp;
public:
    Tranzactie* urmator;
    Tranzactie(int id, int suma, const Collection<T>& bancnote);
    void print() const;
    int getSuma() const {
        return suma;
    }
    int getId() const {
        return id;
    }
    const Collection<T>& getBancnote() const {
        return bancnote;
    }
    T getTranz(int poz) const {
        return poz;
    };
    std::time_t getTimestamp() const {
        return timestamp;
    };
    static bool comparator(const Tranzactie<T>& t1, const Tranzactie<T>& t2);
    static void bubbleSort(Tranzactie<T>*& head);

    static void bubbleSortID(Tranzactie<T>*& head);

};
#include "Tranzactie.tpp"
#endif //TRANZACTIE_H
