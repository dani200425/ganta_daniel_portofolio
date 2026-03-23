#ifndef COLLECTION_H
#define COLLECTION_H
#include "Node.h"

template< typename T>
struct pereche {
    T elem;
    int frecv;
};
// template< typename T> definește o clasă sau un struct generic, ceea ce înseamnă că tipul T este un parametru de tip
// care poate fi înlocuit cu orice tip specific atunci când structura pereche este instanțiată.Astfel,T permite ca
// structura pereche să fie utilizată cu diferite tipuri de date fără a rescrie codul pentru fiecare tip.


template< typename T>
class Collection {
private:
    pereche<T>* elems;
    int len;
    int capacity;
    void resize(int new_size);
    Node<T>* head;
public:
    Collection();
    ~Collection();

    void destroy();

    void add(T elem);
    bool remove(T elem);
    bool search(T elem) const;
    int size() const;
    int nrOccurences(T elem) const;
    void setAt(int position, T newValue);
    T getAt(int position) const;
    void print_all() const;
    int getTotalCount() const;
    void sortDescending();
    Iterator<T>* iterator() const;

    bool removeMultiple(T elem, int count);

    friend class Iterator<T>;

};

#include "Collection.tpp"
#endif //COLLECTION_H
