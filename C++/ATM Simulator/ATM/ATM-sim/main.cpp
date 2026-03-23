#include "ATM.h"
#include <iostream>

using namespace std;
int main() {
    ATM<int> atm;
    atm.adauga_bancnote(500, 5);//1
    atm.adauga_bancnote(10, 30);//2
    atm.adauga_bancnote(50, 6);//3
    atm.adauga_bancnote(100, 3);//4
    atm.adauga_bancnote(20, 3);//5
    atm.adauga_bancnote(5, 3);//6
    int optiune;
    do {
        cout << "1. Afisare bancnote\n2. Adauga bancnote\n3. Retrage numerar\n4. Afisare istoric tranzactii\n5. Sorteaza tranzactiile\n0. Iesire\nAlege o optiune: ";
        // cout << "1. Afisare bancnote\n2. Adauga bancnote\n3. Retrage numerar\n4. Afisare istoric tranzactii\n5. Sorteaza tranzactiile\n6. Sorteaza tranzactiile dupa data\n7. Sorteaza tranzactiile dupa suma\n8. Sorteaza tranzactiile dupa bancnote\n0. Iesire\nAlege o optiune: ";
//SORTAREA SE FACE DUPA DATA, APOI DUPA SUMA, APOI DUPA BANCNOTE( E O SINGURA SORTARE)->BUBBLE SORT. ACEASTA SE FACE IN ORDINE CRESCATOARE
        cin >> optiune;
        if (optiune == 1) {
            atm.afiseaza_bancnote_disponibile();
        } else if (optiune == 2) {
            int valoare_bancnota, frecventa;
            cout << "Introdu valoarea bancnotei: ";
            cin >> valoare_bancnota;
            // Validare valoare bancnota
            while (valoare_bancnota != 5 && valoare_bancnota != 10 && valoare_bancnota != 20 &&
                   valoare_bancnota != 50 && valoare_bancnota != 100 &&
                   valoare_bancnota != 200 && valoare_bancnota != 500) {
                cout << "Valoare invalida. Reintrodu valoarea bancnotei: ";
                cin >> valoare_bancnota;
                   }
            cout << "Introdu frecventa bancnotei: ";
            cin >> frecventa;
            atm.adauga_bancnote(valoare_bancnota, frecventa);
        } else if (optiune == 3) {
            int suma;
            cout << "Introdu suma de retras:\n";
            cin >> suma;
            atm.retragere(suma);
        } else if (optiune == 4) {
            cout << "Istoric tranzactii:\n";
            // atm.afiseaza_tranzactiile();
            atm.sortByID();
        } else if (optiune == 5) {
            atm.bubbleSortATM();
            // atm.printTranzactiiSortate();
            cout << "Tranzactiile au fost sortate dupa data, suma si numar de bancnote folosite.\n";
        }else if (optiune == 6) {
            atm.sortByTimestamp();
            cout << "Tranzactiile au fost sortate dupa data.\n";
            atm.afiseaza_tranzactiile();
        } else if (optiune == 7) {
            atm.sortBySuma();
            cout << "Tranzactiile au fost sortate dupa suma.\n";
            atm.afiseaza_tranzactiile();
        } else if (optiune == 8) {
            atm.sortByBancnote();
            cout << "Tranzactiile au fost sortate dupa numarul de bancnote folosite.\n";
            atm.afiseaza_tranzactiile();
        }
    } while (optiune != 0);

    cout << "Program terminat.\n";
    return 0;
}
