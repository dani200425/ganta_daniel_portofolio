//
// Created by user on 4/20/2025.
//

#ifndef NODE_H
#define NODE_H
template <typename T>
class Collection;

template <typename T>
class Iterator;


template <class T>
class Node {
    T info;
    Node<T>* next;
public:
    Node(T info, Node<T>* next = nullptr) : info(info), next(next) {}
    friend class Collection<T>;
    friend class Iterator<T>;
};

#endif //NODE_H
