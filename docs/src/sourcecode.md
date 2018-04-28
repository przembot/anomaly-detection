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

## knn.R

## svm.R

## rf.R

## if.R
