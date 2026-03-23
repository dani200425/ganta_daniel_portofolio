#ifndef COLLECTION_TPP
#define COLLECTION_TPP
#include <iostream>
#include "Collection.h"
#include <stdexcept>

template<typename T>
Collection<T>::Collection() : head(nullptr), capacity(5), len(0) {
    elems = new pereche<T>[capacity];
}

template<typename T>
Collection<T>::~Collection() {
    destroy();
}

template<typename T>
void Collection<T>::destroy() {
    Node<T>* current = head;
    while (current != nullptr) {
        Node<T>* next = current->next;
        delete current;
        current = next;
    }
    head = nullptr;
}

template<typename T>
void Collection<T>::resize(int new_capacity) {
    if (new_capacity < len) return;
    pereche<T>* new_elems = new pereche<T>[new_capacity];
    for (int i = 0; i < len; i++) {
        new_elems[i] = elems[i];
    }
    delete[] elems;
    elems = new_elems;
    capacity = new_capacity;
}

template<typename T>
void Collection<T>::add(T elem) {
    // Add to linked list
    Node<T>* newNode = new Node<T>(elem, head);
    head = newNode;

    // Update frequency array
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem) {
            elems[i].frecv++;
            return;
        }
    }

    // New element
    if (len == capacity) {
        resize(2 * capacity);
    }
    elems[len].elem = elem;
    elems[len].frecv = 1;
    len++;
}
template<typename T>
bool Collection<T>::remove(T elem) {
    // First check if element exists
    bool exists = false;
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem && elems[i].frecv > 0) {
            exists = true;
            break;
        }
    }
    if (!exists) return false;

    // Remove all occurrences from linked list
    Node<T>* current = head;
    Node<T>* prev = nullptr;
    while (current != nullptr) {
        if (current->info == elem) {
            Node<T>* toDelete = current;
            if (prev == nullptr) {
                head = current->next;
            } else {
                prev->next = current->next;
            }
            current = current->next;
            delete toDelete;
        } else {
            prev = current;
            current = current->next;
        }
    }

    // Update frequency array
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem) {
            elems[i].frecv--;
            if (elems[i].frecv == 0) {
                // Remove element completely
                for (int j = i; j < len - 1; j++) {
                    elems[j] = elems[j + 1];
                }
                len--;
            }
            return true;
        }
    }
    return false;
}

template<typename T>
bool Collection<T>::search(T elem) const {
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem && elems[i].frecv > 0) {
            return true;
        }
    }
    return false;
}

template<typename T>
int Collection<T>::size() const {
    return len;
}

template<typename T>
int Collection<T>::nrOccurences(T elem) const {
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem) {
            return elems[i].frecv;
        }
    }
    return 0;
}

template<typename T>
T Collection<T>::getAt(int position) const {
    if (position < 0 || position >= len) {
        throw std::out_of_range("Invalid position");
    }
    return elems[position].elem;
}

template<typename T>
void Collection<T>::setAt(int position, T newValue) {
    if (position < 0 || position >= len) {
        throw std::out_of_range("Invalid position");
    }
    elems[position].elem = newValue;
}

template<typename T>
void Collection<T>::print_all() const {
    for (int i = 0; i < len; i++) {
        std::cout << "Bancnota: " << elems[i].elem
                  << "   -->   Frecventa: " << elems[i].frecv << std::endl;
    }
}

template<typename T>
int Collection<T>::getTotalCount() const {
    int total = 0;
    for (int i = 0; i < len; i++) {
        total += elems[i].frecv;
    }
    return total;
}

template<typename T>
void Collection<T>::sortDescending() {
    for (int i = 0; i < len - 1; i++) {
        for (int j = i + 1; j < len; j++) {
            if (elems[i].elem < elems[j].elem) {
                pereche<T> temp = elems[i];
                elems[i] = elems[j];
                elems[j] = temp;
            }
        }
    }
}

template<typename T>
Iterator<T>* Collection<T>::iterator() const {
    return new Iterator<T>(head);
}
template<typename T>
bool Collection<T>::removeMultiple(T elem, int count) {
    // Verifică dacă există suficiente apariții
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem) {
            if (elems[i].frecv < count) {
                return false; // Nu sunt suficiente
            }
            break;
        }
    }

    // Elimină din lista înlănțuită
    int removed = 0;
    Node<T>* current = head;
    Node<T>* prev = nullptr;
    while (current != nullptr && removed < count) {
        if (current->info == elem) {
            Node<T>* toDelete = current;
            if (prev == nullptr) {
                head = current->next;
            } else {
                prev->next = current->next;
            }
            current = current->next;
            delete toDelete;
            removed++;
        } else {
            prev = current;
            current = current->next;
        }
    }

    // Actualizează frecvența
    for (int i = 0; i < len; i++) {
        if (elems[i].elem == elem) {
            elems[i].frecv -= count;
            if (elems[i].frecv == 0) {
                // Șterge elementul dacă frecvența ajunge la 0
                for (int j = i; j < len - 1; j++) {
                    elems[j] = elems[j + 1];
                }
                len--;
            }
            return true;
        }
    }
    return false;
}
#endif //COLLECTION_TPP