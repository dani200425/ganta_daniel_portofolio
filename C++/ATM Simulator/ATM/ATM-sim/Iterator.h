#ifndef ITERATOR_H
#define ITERATOR_H
#include "Tranzactie.h"

template<typename T>
class Iterator {
private:
    Tranzactie<T>* currentNode; // Use Tranzactie<T>* to match ATM's linked list

public:
    // Constructor accepting Tranzactie<T>*
    Iterator(Tranzactie<T>* start) : currentNode(start) {}

    // Check if the iterator is valid
    bool isValid() const { return currentNode != nullptr; }

    // Get the current transaction
    const Tranzactie<T>& getCurrent() const {
        if (!currentNode) {
            throw std::runtime_error("Invalid iterator access");
        }
        return *currentNode;
    }

    // Move to the next transaction
    void next() { currentNode = currentNode->urmator; }
};

#endif

























// #define ITERATOR_H
// #include "Tranzactie.h"
// #include "Node.h"
//
// template<typename T>
// class Iterator {
// private:
//     Tranzactie<T>* currentPtr;
//     Node<T>* currentNode;
//
// public:
//     // // Iterator(Tranzactie<T>* head) : currentPtr(head) {}
//     // Iterator(Node<T>* start) : currentNode(start) {}
//     // // Reset iterator to beginning
//     // void first() {
//     //     // Not needed for simple linked list
//     // }
//     //
//     // // Move to next element
//     // void next() {
//     //     if (currentNode) {
//     //         currentNode = currentNode->next;
//     //     }
//     // }
//     //
//     // // Check if iterator is valid
//     // bool isValid() const {
//     //     return currentNode != nullptr;
//     // }
//     //
//     // // Get current element
//     // const Tranzactie<T>& getCurrent() const {
//     //     if (!currentNode) {
//     //         throw std::runtime_error("Invalid iterator access");#ifndef ITERATOR_H

// #endif // ITERATOR_H
//     //     }
//     //     return currentNode->info;
//     // }
//     Iterator(Tranzactie<T>* start) : currentNode(start) {} // Accept Tranzactie<T>*
//     bool isValid() const { return currentNode != nullptr; }
//     const Tranzactie<T>& getCurrent() const { return *currentNode; }
//     void next() { currentNode = currentNode->urmator; }
// };
//
// #endif //ITERATOR_H
