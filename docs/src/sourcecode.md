---
title: "Projekt MOW - dokumentacja kodu źródłowego"
author:
  - Kamila Lis
  - Przemysław Kopański
lang: pl

header-includes:
  - \usepackage{indentfirst}
indent: true

colorlinks: true
urlcolor: blue

---


# Struktura plików

Projekt został podzielony w następujący sposób:

- _data/_ - w tym katalogu znajdują się dane używane przez kod źródłowy.
            Znajduje się w nim skrypt _getdata.sh_, który pobiera
            wszystkie wykorzystywane zbiory danych.
- _docs/_ - folder zawierający dokumentację projektu i kodu źródłowego
            w formacie _Markdown_.
- _src/_ -  katalog zawierający kod źródłowy algorytmów.
- _installDeps.R_ - skrypt pomocniczy instalujący wszystkie wymagane
                    dodatkowe biblioteki z repozytorium CRAN.
- _main.R_ - skrypt startujący badanie algorytmów.
- _mow-projekt.Rproj_ - plik konfiguracyjny do _IDE_ R-studio.


# Dokumentacja kodu

Kod źródłowy został podzielony na względnie samodzielne moduły.
Na każdy badany algorytm klasyfikacji przypada osobny plik.
Znajdują się w nich funkcje pomocnicze, służące do wykonania badań
z pomocą rozpatrywanych zbiorów danych.

## Semantyka nazw funkcji

W każdym module z algorytmem znajduje się:

- funkcja _main_, która generuje wszystkie raporty wykorzystane w dokumentacji projektu,
- funkcja _evaluate_, która przyjmuje zbiory danych oraz parametry danego modelu, i dodaje
  do wykresu krzywą ROC bądź zwraca parametry _sensitivity_ oraz _specificity_ dla wygenerowanego
  modelu oraz korzystając z podanych danych testowych.
- funkcja _generateRaport_ tworząca wykres z krzywymi ROC; na podstawie zadanych parametrów modelu,
  tworzy je, bada jakość oraz tworzy wykres.


## Opis modułów

### src/load.R
Skrypt odpowiada za wczytanie i wstępne przetworzenie danych (m.in. podział na zbiory treningowy i testowy, rozłożenie na czynniki danych nienumerycznych).

### src/utils.R
Moduł zawierający pomocnicze funkcje, w tym funkcje rysującą wykres ROC.

### src/knn.R
Program realizuje algorytm k-najbliższych sąsiadów przy wykorzystaniu biblioteki _class_. W ramach skryptu algorytm testowany jest z różnymi wartościami parametru _k_ na wszystkich zbiorach danych. 

### src/svm.R
Program realizuje jednoklasową klasyfikację przy pomocy maszyny wektorów nośnych _SVM_ przy wykorzystaniu biblioteki _e1071_.

### src/rf.R
Program realizuje klasyfikację przy pomocy lasu losowego z wykorzystaniem biblioteki _randomForest_.

### main.R
Moduł uruchamiający badania dla wszystkich wykorzystywanych algorytmów.

### src/iforest.R
Moduł zawierający implementację lasu izolacji.
Do implementacji została wykorzystana biblioteka _data.tree_
zawierająca strukturę danych reprezentującą drzewo.
Funkcja _iforestModelGen_ przyjmuje zbiór trenujący oraz parametry algorytmu - liczbę drzew oraz _chi_
i zwraca wygenerowany model, który może być później użyty korzystając z funkcji _predict_.

Generacja modelu polega na stworzeniu drzew losowych, do tworzenia których
zostanie użyte _chi_ przykładów. Przykłady te są losowane bez zwracania na pierwotnym zbiorze trenującym.

Funkcja _iTree_ generuje drzewo losowe, losując zbiór trenujący oraz ograniczając jego głębokość
do $log2(chi)$. Drzewo tworzone jest zstępująco, a funkcja wykonuje się rekurencyjnie.
Na aktualnym poziomie tworzony jest podział aktualnie rozpatrywanego podzbioru trenującego
na podstawie losowo wybranego atrybutu. Próg podziału jest również wybierany losowo.
Jeżeli dany podzbiór został już wyczerpany, to tworzony jest węzeł. Jeżeli
algorytm doszedł do maksymalnej głębokości, tworzony jest węzeł, a w nim
pozostaje informacja o wielkości pozostałego podzbioru.

Funkcja _predict_ na podstawie modelu dokonuje oceny próbek. Ocena ta
posłuży do klasyfikacji, po analizie przypadków na krzywej ROC.
Ocena obliczona jest na podstawie odległości liścia, do którego należy
badana próbka w każdym drzewie z lasu.
