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
                    dodatkowe bilbioteki z repozytorium CRAN.
- _mow-projekt.Rproj_ - plik konfiguracyjny do _IDE_ R-studio.

# Dokumentacja poszczególnych modułów

## load.R
Skrypt odpowiada za wczytanie i wstępne przetworzenie danych (m.in. podział na zbiory treningowy i testowy, rozłożenie na czynniki danych nienumerycznych).

## knn.R
Program realizuje algorytm k-najbliższych sąsiadów przy wykorzystaniu bilioteki _class_. W ramach skryptu algorytm testowany jest z różnymi wartościami parametru _k_ na wszystkich zbiorach danych. 

## svm.R
Program realizuje jednoklasową klasyfikację przy pomocy maszyny wektorów nośnych _SVM_ przy wykorzystaniu bilioteki _e1071_.

## rf.R
Program realizuje klasyfikację przy pomocy lasu losowego z wykorzystaniem bilioteki _randomForest_.

## iforest.R
Implementacja lasu izolacji.