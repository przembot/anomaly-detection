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
Bardziej szczegółowa interpretacja projektu została opisana w rozdziale trzecim.

# Opis algorytmów


## Algorytm implementowany
Detekcja anomalii z wykorzystaniem lasu izolacji (_iForest_) polega na separacji próbki na podstawie zmierzonego stopnia podatności na izolację. W tym celu metoda wykorzystuje właściwości anomalii - niewielką liczebność oraz znacząco różniące się wartości atrybutów. 

Izolacja jest zrealizowana z użyciem prawidłowych drzew binarnych (_iTree_), w których każdy węzeł w drzewie ma dokładnie zero lub dwa węzły potomne. Przyjętą miarą podatności na izolację jest długość ścieżki, czyli liczba krawędzi jakie należy przejść, by dojść od pnia do danej próbki (o ile przejście to nie przekracza zdefiniowanej maksymalnej wysokości drzewa). Przykłady o krótkiej ścieżce mają wysoką podatność, ponieważ obserwacje o wyróżniających się wartościach atrybutów mają większe szanse na oddzielenie w początkowej fazie procesu partycjonowania, a dodatkowo niewielka liczba anomalii powoduje mniejszą liczbę partycji. 

Wykrywanie anomalii na podstawie lasu izolacyjnego jest dwustopniowe. Pierwszy etap, uczenie, polega na budowie drzew
izolacji z użyciem podpróbek zbioru testowego. W następnym etapie algorytm przekazuje przykłady testowe przez drzewa izolacji, aby uzyskać wynik anomalii dla każdego z nich. Sposobem wykrywania anomalii jest sortowanie przykładów według ich średniej długości ścieżki. Anomalie są przykładami, które znajdują się na górze listy.


## Algorytmy wykorzystane do badań

Jakość zaimplementowanego algorytmu zostanie porównana
z implementacjami wybranych algorytmów dostępnych
w repozytorium CRAN.

### k-NN - k najbliższych sąsiadów

Algorytm k-NN jest jednym z najprostszych algorytmów klasyfikacji.
Polega na obliczeniu i porównaniu odległości danego przykładu do przykładów
będącymi w trenującym zbiorze danych. W kolejnym kroku następuje
klasyfikacja - k przykładów testowych, które są w najmniejszej
odległości od badanego punktu dokonuje głosowania,
którą klasę przydzielić badanemu punktowi.

W przypadku tego projektu, zostaną wykorzystane 2 klasy - punkt typowy
i anomalia.

### LOF - local outlier factor

http://www.dbs.ifi.lmu.de/Publikationen/Papers/LOF.pdf
Algorytm klasyfikacji LOF wykorzystuje k-NN do określenia zagęszczenia punktów.
Przez porównanie lokalnej gęstości przykładu do lokalnej gęstości
jego sąsiadów można określić regiony o podobnej gęstości oraz punkty
znacząco mniejsze zagęszczenie niż ich sąsiedzi.
W tym algorytmie zakłada się, że anomalie występują nielicznie,
dlatego też punkty o mniejszej gęstości traktowane są jako odstające.


### Jedno-klasowy SVM - maszyna wektorów nośnych

Algorytm SVM (support vector machine) jest algorytmem klasyfikacji.
Poszukuje on funkcji decyzyjnej takiej, że jej odległość pomiędzy
punktami należącymi do różnych klas jest możliwie największa.
Jednoklasowość polega tutaj na klasyfikacji przykładu do klasy
odpowiadającej typowemu punktowi, a nie przydzielenie
do tej klasy oznaczać będzie, że punkt jest anomalią.


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

### k-NN
Parametr _k_ określa liczbę najbliższych sąsiadów biorących
udział w głosowaniu odnośnie wyboru klasy dla badanego przykładu.

### LOF
W algorytmie _LOF_ wykorzystywany jest parametr _k_
który ma znaczenie jak w przypadku algorytmu k-NN.

### SVM
Do uruchomienia algorytmu SVM należy podać typ wykorzystywanego jądra
(np. Gaussowskiej) oraz jego odpowiednie parametry.

### Las izolacji
Parametry etapu uczenia:

* liczba drzew _t_
* rozmiar zbioru uczącego $\psi$

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

Ze względu na ograniczoną w chwili obecnej wiedzę na temat
dostępnych bibliotek, później będą wybrane
biblioteki implementujące algorytmy wykorzystane
do porównania
Istotny wydaje się również wybór odpowiedniego jądra wraz z parametrami
dla algorytmu SVM, który zostanie dokonany później.


[dataset]: https://archive.ics.uci.edu/ml/datasets/SPECT+Heart "SPECT Heart"
