---
title: "Projekt MOW - wstępne założenia"
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

# Szczegółowa interpretacja tematu projektu
Opracowywany temat - _Nienadzorowana detekcja anomalii za lasu izolacyjnego. Porównanie z nadzorowaną detekcją anomalii za pomocą dostępnych w R algorytmów klasyfikacji._

# Opis algorytmów


## Algorytm implementowany
Detekcja anomali z wykorzystaniem lasu izolacji (_iForest_) polega na separacji próbki na podstawie zmierzonego stopnia podatności na izolację. W tym celu metoda wykorzystuje właściwości anomalii - niewielką liczebność oraz znacząco różniące się wartości atrybutów. 

Izolacja jest zrealizowana z użyciem prawidłowych drzew binarnych (_iTree_), w których każdy węzeł w drzewie ma dokładnie zero lub dwa węzły potomne. Przyjętą miarą podatności na izolację jest długość ścieżki, czyli liczba krawędzi jakie należy przejść, by dojść od pnia do danej próbki (o ile przejście to nie przekracza zdefiniowanej maksymalnej wysokości drzewa). Przykłady o któtkiej ścieżce mają wysoką podatność, ponieważ obserwacje o wyróżniających się wartościach atrybutów mają większe szanse na oddzielenie w początkowej fazie procesu partycjonowania, a dodatkowo niewielka liczba anomalii powoduje mniejszą liczbę partycji. 

Wykrywanie anomali na podstawie lasu izolacujnego jest dwustopniowe. Pierwszy etap, uczenie, polega na budowie drzew
izolacji z użyciem podpróbek zbioru testowego. W następnym etapie algorytm przekazuje przykłady testowe przez drzewa izolacji, aby uzyskać wynik anomalii dla każdego z nich. Sposobem wykrywania anomalii jest sortowanie przykładów według ich średniej długości ścieżki. Anomalie są przykładami, które znajdują się na górze listy.


## Algorytmy wykorzystane do badań

# Plan badań

## Cel poszczególnych eksperymentów
Celem eksperymentów jest znalezienie algorytmu
wykrywającego anomalie w badanym zbiorze danych
w możliwie dokładny sposób. Należy zwrócić uwagę
na to, że detekcja anomalii jest szczególnym przypadkiem
zadania klasyfikacji, w którym występują tylko
2 kategorię.


## Charakterystyka wykorzystywanego zbioru danych
Do badań zostanie wykorzystany zbiór danych z repozytorium UCL - [SPECT Heart][dataset].
Zawarto w nim wyniki badań tomografii serca człowieka.
W wyniku ekstrakcji danych z powstałych w czasie badania zdjęć
powstał podany zbiór danych.
Zawiera on 22 atrybuty binarne opisujące badanie
oraz jeden atrybut binarny będący wynikiem klasyfikacji.
Zbiór danych podzielony został na zbiór trenujący,
zawierający 187 przykładów oraz zbiór testowy,
zawierający 80.


## Parametry algorytmów
### Las izolacji
Parametry etapu uczenia:
  * liczba drzew _t_
  * rozmiar zbioru uczącego $$ \psi $$
Parametry etapu oceny:
  * maksymalna wysokość drzewa _hlim_


## Miary jakości i procedury oceny modeli
W celu ocenienia modeli zostanie wykorzystany
zbiór testowy. Miarę jakości stanowić
będzie stosunek poprawnie sklasyfikowanych
przykładów do jej całkowitej ilości.

Procedura oceny polegać będzie na wytrenowaniu modelu
używając danych ze zbioru trenującego, po czym
wyliczenie miary jakości w sposób wyżej opisany.


# Otwarte kwestie wymagające późniejszego rozwiązania


[dataset]: https://archive.ics.uci.edu/ml/datasets/SPECT+Heart "SPECT Heart"
