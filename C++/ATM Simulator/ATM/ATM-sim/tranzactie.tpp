#ifndef TRANZACTIE_TPP
#define TRANZACTIE_TPP

template<typename T>    //functie/constructor pentru tranzactie
Tranzactie<T>::Tranzactie(int id, int suma, const Collection<T> &bancnote)
        : id(id), suma(suma), bancnote(bancnote), urmator(nullptr) {timestamp = std::time(nullptr);}

template<typename T>    //functie de printare
void Tranzactie<T>::print() const {
    std::cout << "Tranzactie ID: " << id << " | Suma: " << suma << " | Data: " <<std::ctime(&timestamp)<<"\n";
}

template<typename T>
bool Tranzactie<T>::comparator(const Tranzactie<T> &t1, const Tranzactie<T> &t2) {
    if (t1.getTimestamp() != t2.getTimestamp()) {
        return t1.getTimestamp() < t2.getTimestamp();
    }
    if (t1.getSuma() != t2.getSuma()) {
        return t1.getSuma() < t2.getSuma();
    }
    return t1.getBancnote().size() < t2.getBancnote().size();
}

template<typename T>
void Tranzactie<T>::bubbleSort(Tranzactie<T>*& head) {
    if (!head || !head->urmator) {
        return;
    }

    bool swapped;
    Tranzactie<T>** ptr;

    do {
        swapped = false;
        ptr = &head;

        while ((*ptr)->urmator) {
            Tranzactie<T>* current = *ptr;
            Tranzactie<T>* next = current->urmator;

            if (!Tranzactie<T>::comparator(*current, *next)) {
                // Swap the nodes
                current->urmator = next->urmator;
                next->urmator = current;
                *ptr = next;
                swapped = true;
            }
            ptr = &(*ptr)->urmator;
        }
    } while (swapped);
}

template<typename T>
void Tranzactie<T>::bubbleSortID(Tranzactie<T>*& head) {
    if (!head || !head->urmator) {
        return;
    }

    bool swapped;
    Tranzactie<T>** ptr;

    do {
        swapped = false;
        ptr = &head;

        while ((*ptr)->urmator) {
            Tranzactie<T>* current = *ptr;
            Tranzactie<T>* next = current->urmator;

            if (current->getId() > next->getId()) {
                // Swap the nodes
                current->urmator = next->urmator;
                next->urmator = current;
                *ptr = next;
                swapped = true;
            }
            ptr = &(*ptr)->urmator;
        }
    } while (swapped);
}

template<typename T>
bool comparatorByTimestamp(const Tranzactie<T>& t1, const Tranzactie<T>& t2) {
    return t1.getTimestamp() < t2.getTimestamp();
}

template<typename T>
bool comparatorBySuma(const Tranzactie<T>& t1, const Tranzactie<T>& t2) {
    return t1.getSuma() < t2.getSuma();
}

template<typename T>
bool comparatorByBancnote(const Tranzactie<T>& t1, const Tranzactie<T>& t2) {
    return t1.getBancnote().size() < t2.getBancnote().size();
}

// ===================================================================bubble sort pentru sortare de 1 criteriu data/suma/bancnote
template<typename T>
void bubbleSort1(Tranzactie<T>*& head, bool (*comparator)(const Tranzactie<T>&, const Tranzactie<T>&)) {
    if (!head || !head->urmator) {
        return;
    }

    bool swapped;
    Tranzactie<T>** ptr;

    do {
        swapped = false;
        ptr = &head;

        while ((*ptr)->urmator) {
            Tranzactie<T>* current = *ptr;
            Tranzactie<T>* next = current->urmator;

            if (!comparator(*current, *next)) {
                // Swap the nodes
                current->urmator = next->urmator;
                next->urmator = current;
                *ptr = next;
                swapped = true;
            }
            ptr = &(*ptr)->urmator;
        }
    } while (swapped);
}
#endif //TRANZACTIE_TPP

