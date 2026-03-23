cmake_minimum_required(VERSION 3.30)
project(ATM_inteles)

set(CMAKE_CXX_STANDARD 20)

add_executable(ATM_inteles main.cpp
        Collection.h
        Collection.tpp
        Tranzactie.h
        tranzactie.tpp
        ATM.h
        Iterator.h
        ATM.tpp
        Node.h)
