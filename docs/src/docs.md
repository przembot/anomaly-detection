---
title: "Projekt MOW - dokumentacja projektu"
author:
  - Kamila Lis
  - Przemysław Kopański
lang: pl

include-in-header: header.tex
header-includes:
  - \usepackage{indentfirst}
indent: true

colorlinks: true
urlcolor: blue

bibliography: src/ref.bib
---

# Szczegółowa interpretacja tematu projektu
Opracowywany temat - _Nienadzorowana detekcja anomalii za lasu izolacyjnego. Porównanie z nadzorowaną detekcją anomalii za pomocą dostępnych w R algorytmów klasyfikacji._
Bardziej szczegółowa interpretacja projektu została opisana w rozdziale trzecim.

# Opis algorytmów


## Algorytm implementowany - las izolacji
Detekcja anomalii z wykorzystaniem lasu izolacji (_iForest_) polega na separacji próbki na
podstawie zmierzonego stopnia podatności na izolację. W tym celu metoda wykorzystuje właściwości
anomalii - ich niewielką liczebność oraz znacząco różniące się wartości atrybutów.

Izolacja jest zrealizowana z użyciem prawidłowych drzew binarnych (_iTree_), w których każdy węzeł
w drzewie ma dokładnie zero lub dwa węzły potomne. Przyjętą miarą podatności na izolację jest
długość ścieżki, czyli liczba krawędzi jakie należy przejść, by dojść od korzenia do danej próbki
(o ile przejście to nie przekracza zdefiniowanej maksymalnej wysokości drzewa). Przykłady o
krótkiej ścieżce mają wysoką podatność, ponieważ obserwacje o wyróżniających się wartościach
atrybutów mają większe szanse na oddzielenie w początkowej fazie procesu partycjonowania, a
dodatkowo niewielka liczba anomalii powoduje mniejszą liczbę partycji.
Długość ścieżki obliczana jest jako `e + c(T.size)`, gdzie _e_ to liczba
krawędzi (przebytych od korzenia), a _c()_ to korekta,
służąca do szacowania średniej długości ścieżki losowego drzewa podrzędnego,
która mogłaby zostać skonstruowana przy użyciu danych o wielkości
przekraczającej limit wysokości drzewa. Korekta _c($\psi$)_,
średnia długość ścieżek od korzenia do liścia dla _$\psi$_ próbek,
(obliczana jak nieudane przeszukiwanie drzewa binarnego) jest wykorzystywana
do normalizacji stopnia anomalii. Normalizacja jest niezbędna do porównania
długości ścieżek drzew zbudowanych na podzbiorach o różnej wielkości.

Wykrywanie anomalii na podstawie lasu izolacyjnego jest dwustopniowe.
Pierwszy etap, uczenie, polega na budowie drzew
izolacji z użyciem podzbioru danych testowych. W następnym etapie algorytm przekazuje
przykłady testowe przez drzewa izolacji, aby uzyskać wynik anomalii dla każdego z nich:
  $s(x,n) = 2 - \frac{E(h(x))}{c(\psi)}$
  gdzie E to średnia długość ścieżek dla kolejnych drzew.
Wartości _s_ bliskie 1 oznaczają anomalię.

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

Algorytm klasyfikacji LOF [@breunig2000lof] wykorzystuje k-NN do określenia zagęszczenia punktów.
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

### Random Forest - las losowy

Działanie lasów losowych polega na klasyfikacji za pomocą grupy drzew decyzyjnych. Końcowa decyzja jest podejmowana w wyniku
głosowania większościowego nad klasami wskazanymi przez poszczególne drzewa decyzyjne. Każde z drzew konstruowane jest przez wylosowanie ze zwracaniem _N_ obiektów z zbioru uczącego o liczności _N_. W każdym węźle podział jest dokonywany jedynie na podstawie _k_ losowo wybranych cech. Ich liczba jest znacznie mniejsza od liczby wszystkich cech. Dzięki tej własności lasy losowe mogą być stosowane w problemach o dużej liczbie cech.

# Plan badań

## Cel poszczególnych eksperymentów
Celem eksperymentów jest znalezienie algorytmu
wykrywającego anomalie w badanym zbiorze danych
w możliwie dokładny sposób. Należy zwrócić uwagę
na to, że detekcja anomalii jest szczególnym przypadkiem
zadania klasyfikacji, w którym występują tylko
2 kategorię.


## Charakterystyka wykorzystywanych zbiorów danych

Do badań wykorzystane zostaną zbiory danych dostępne
w repozytorium _UCL_.

### KDD Cup 1999 Data
Zbiór danych [KDD Cup 1999 Data][kdd] zawiera informacje
o połączeniach TCP na podstawie zapisanego ruchu w sieci LAN
symulującej typową sieć U.S. Air Force. Każde z połączeń jest oznaczone
jako połączenie poprawne lub atak określonego typu. Zbiór posiada 42 atrybuty,
łączna liczba instancji to 4.000.000, natomiast na rzecz projektu postanowiono
wykorzystać losowe wybrane 100.000 próbek.

Cechy pojedynczego połączenia TCP:

- czas trwania połączenia (w sekundach),
- typ protokółu warstwy transportowej,
- usługa sieciowa,
- liczba bajtów danych wysyłanych,
- liczba bajtów danych odbieranych,
- status połączenia (normalny/błąd),
- czy połączenie pochodzi/wychodzi do tego samego hosta/na ten sam port,
- liczba niepoprawnych fragmentów,
- liczba pakietów z flagą URG.

Cechy zawartości na podstawie domeny

- liczba spełnionych "gorących" wskaźników,
- liczba nieudanych prób logowania,
- informacja o poprawnym logowaniu,
- liczba spełnionych warunków oznaczających włamanie,
- informacja o uzyskanym dostępie do powłoki głównej (root shell),
- informacja o wywołaniu polecenia ,,su root'',
- liczba dostępu do roota,
- liczba operacji tworzenia pliku,
- liczba powłok systemowych,
- liczba operacji kontroli dostępu do plików,
- liczba wychodzących poleceń w sesji ftp,
- informacja o przynależności loginu do "gorącej" listy,
- informacja o zalogowaniu jako ,,gość''.

Cechy ruchu sieciowego obliczone w dwu-sekundowym oknie czasowym

- liczba połączeń do tej samej maszynie,
- procent połączeń z błędami ,,SYN'',
- procent połączeń z błędami ,,REJ'' (RST po próbie SYN),
- procent połączeń do tej samej usługi,
- procent połączeń do innych usług,
- liczba połączeń do tej samej usługi,
- analogicznie: procent połączeń z błędami ,,SYN'', ,,REJ'', do innych usług.


### Phishing Websites
[Phishing Websites][phishw] jest kolejnym zbiorem danych
opisujących adresy, które mogą być związane z atakiem typu phishing.
Występuje tutaj 30 atrybutów i 2456 instancji. Atrybuty mogą posiadać
2 lub 3 wartości ze znaczeniem identycznym jak w poprzednim zbiorze danych.

Atrybuty opisują:

- zawieranie adresu IP w odnośniku,
- długość adresu,
- użycie serwisu do skracania adresu,
- posiadanie symbolu _\@_,
- przekierowanie z użyciem _//_,
- dodanie prefiksu bądź sufiksu za pomocą _-_,
- ilość poddomen,
- użycie SSL wraz z oceną podmiotu wystawiającego certyfikat; wiek certyfikatu,
- czas rejestracji domeny,
- czy odnośnik favicon jest zewnętrzny,
- używanie niestandardowego portu,
- użycie _https_ jako części adresu (np. https-google.com),
- czy adres posiada długi opis żądania,
- czy adres nie ma w sobie za dużo uchwytów (_anchor_),
- odnośniki w tagach _meta, script oraz link_,
- czy użycie SFH nie wzbudza podejrzeń,
- wysyłanie informacji za pomocą maila,
- czy nazwa podmiotu zawiera się w adresie (sprawdzenie za pomocą WHOIS),
- liczba przekierowań,
- wykorzystanie zdarzenia _onMouseOver_ do zmiany status bara,
- wyłączanie możliwości kliknięcia prawego przycisku myszy,
- przekierowanie za pomocą _IFrame_,
- wiek domeny,
- czy istnieje rekord w DNS,
- czy ruch na podanej stronie jest odpowiednio duży (sprawdzony w zewnętrznej bazie Alexadatabase),
- jaki jest PageRank adresu,
- czy strona jest indeksowana przez Google,
- liczba odnośników wskazujących na stronę,
- czy adres istnieje w bazie danych adresów phishingowych (np. PhishTank, StopBadware).

### SPECT Heart
Zbiór danych [SPECT Heart][dataset]
zawiera wyniki badań tomografii serca człowieka.
W wyniku ekstrakcji danych z powstałych w czasie badania zdjęć
powstał podany zbiór danych.
Zawiera on 22 atrybuty binarne opisujące badanie
oraz jeden atrybut binarny będący wynikiem klasyfikacji.
Zbiór danych podzielony został na zbiór trenujący,
zawierający 187 przykładów oraz zbiór testowy,
zawierający 80.

Podany zbiór różni się od pozostałych ilością dostępnych próbek (poniżej 300),
jak i tematyką danych. Posłuży on do dodatkowego porównania
jakości algorytmów.


## Parametry algorytmów

### k-NN
Parametr _k_ określa liczbę najbliższych sąsiadów biorących
udział w głosowaniu odnośnie wyboru klasy dla badanego przykładu.

### LOF
W algorytmie _LOF_ wykorzystywany jest parametr _k_
który ma znaczenie jak w przypadku algorytmu k-NN.

### SVM
Do uruchomienia algorytmu SVM należy podać:
* typ (klasyfikacja / regresja / wykrywanie anomalii (klasyfikacja jednoklasowa))
* nazwę funkcji jądrowej (liniowa / wielomianowa / radialna / sigmoidalna )
* parametry (zależnie od wybranego typu i funkcji jądrowej).

### Las losowy
Parametry etapu uczenia:
* liczba drzew _ntree_

### Las izolacji
Parametry etapu uczenia:j

* liczba drzew _t_
* rozmiar zbioru uczącego $\psi$

Parametry etapu oceny:

* maksymalna wysokość drzewa _hlim_


## Miary jakości i procedury oceny modeli
W celu ocenienia modeli zostanie wykorzystany
zbiór testowy. Miarę jakości stanowić
będzie stosunek poprawnie sklasyfikowanych
przykładów do jej całkowitej ilości, nazywany dalej _quality_.
Dodatkowo pod uwagę brane będą takie metryki jak 
czułość (_sensitivity_), czyli stosunek wyników 
prawdziwie dodatnich do sumy prawdziwie dodatnich 
i fałszywie ujemnych i swoistość (_specificity_), czyli
stosunek wyników prawdziwie ujemnych do sumy 
prawdziwie ujemnych i fałszywie dodatnich.
Przy detekcji anomalii będzie nam szczególnie zależeć na maksymalizowaniu
czułości, by jak najwięcej wartości odstających zostało wykrytych.

Procedura oceny polegać będzie na wytrenowaniu modelu
używając danych ze zbioru trenującego, po czym
wyliczenie miary jakości w sposób wyżej opisany.


# Otwarte kwestie wymagające późniejszego rozwiązania

Ze względu na ograniczoną w chwili obecnej wiedzę na temat
dostępnych bibliotek, później będą wybrane
biblioteki implementujące algorytmy wykorzystane
do porównania.
Istotny wydaje się również wybór odpowiedniego jądra wraz z parametrami
dla algorytmu SVM, który zostanie dokonany później.
W miarę możliwości może być również powiększana wykorzystywana liczba próbek z zbioru danych [KDD Cup 1999 Data].
Dopuszczamy również możliwość ograniczenia liczby atrybutów, jeżeli
nie będziemy w stanie obsłużyć tak dużej ilości atrybutów.


# Część praktyczna

Ta część dokumentacji opisuje działania podjęte po oddaniu wstępnej dokumentacji,
będącej powyżej.

## Zmiana algorytmu porównawczego

W dokumentacji wstępnej planowano wykorzystanie do badań algorytmu LOF, w trakcie realizacji projektu postanowiono jednak zastąpić go algorytmem lasu losowego. Wykorzystanie algorytmu wykorzystującego drzewa decyzyjne powinno pozwolić na dokładniejsze porównanie i ocenę działania implementowanego algorytmu lasu izolacji.

## Uzyskane wyniki

### k-NN
W pierwszym kroku, w celu dobrania najlepszej wartości parametru _k_, dla każdego zbioru danych przeprowadzono klasyfikację z nieparzystymi liczbami sąsiadów biorących udział w głosowaniu w przedziale 1-9. Następnie, dla wybranego _k_, dokonano klasyfikacji 20-krotnie ze względu na losowy wybór sąsiada przez algorytm w przypadku remisów (kilka próbek o tej samej wartości atrybutu). Wyniki (wartości średnie) przedstawione są w tabeli.

| Dane              |  k  | quality   | specificity | sensitivity |
| ----------------- |:---:| :--------:|:-----------:|:-----------:|
| SPECT Heart       |  3  | 0.6187166 | 91.0000000  | 59.3313953  |
| Phishing Websites |  1  | 0.9537986 | 94.14368    | 96.45659    |
| KDD Cup 1999 Data |  -  |    -      |     -       |     -       |

Z powodu bardzo wielu remisów (nawet przy dużych wartościach parametru _k_) nie udało się przeprowadzić klasyfikacji na zbiorze KDD Cup 1999 Data.

![Analiza ROC, k-nn, zbiór SPECT](images/knn_spect_parameters.pdf)

![Analiza ROC, k-nn, zbiór Phishing Websites](images/knn_pweb_parametry.pdf)


### SVM
W detekcji anomalii metodą maszyn wektorów nośnych w pierwszej kolejności wykorzystano radialną funkcję jądrową (najczęściej stosowaną) oraz jednoklasowy typ klasyfikacji (modelowanie klasy). Podobnie jak w przypadku poprzedniego algorytmu, przetestowano działanie metody na zbiorze testowym dla wartości parametru _gamma_ {0.1, 0.125, 0.2, 0.25, 0.5, 0.8, 1} (kolejne wartości na wykresie są oznaczone kolejnymi kolorami tęczy).
Modyfikowany parametr _gamma_ jest parametrem funkcji jądrowej i definiuje wpływ pojedynczego przykładu trenującego (niska wartość oznacza daleki zasięg). Wyniki przeprowadzonych testów przedstawione są na wykresach 

![Analiza ROC, SVM, zbiór SPECT](images/spect_svm.png)

![Analiza ROC, SVM, zbiór Phishing Websites](images/pweb_svm.png)

![Analiza ROC, SVM, zbiór KDD](images/kdd_svm_radial.pdf)

Z powodu niezadowalających wyników działania algorytmu dla dwóch pierwszych zbiorów danych postanowiono zmienić funkcję jądrową na funkcję wielomianową. Ponownie, na tych samych zbiorach danych, przeprowadzono testy dla  stopni wielomianu od 2 do 6.

![Analiza ROC, SVM (jądro liniowe), SPECT](images/spect_svm_linear.pdf)

![Analiza ROC, SVM (jądro wielomianowe), Phishing Websites](images/pweb_svm_polynomial.pdf)

Ostatecznie, najlepsze osiągnięte wyniki:

| Dane              | funkcja jądrowa | parametr  | quality   | specificity | sensitivity |
| ----------------- |:---------------:| :--------:| :--------:|:-----------:|:-----------:|
| SPECT Heart       | liniowa         |    brak   | 0.8342246 |  0.8488     |    0.6667   |       
| Phishing Websites | wielomianowa    | degree=4  | 0.6951872 |  0.6977     |    0.6667   |   
| KDD Cup 1999 Data |  radialna       | gamma=0.5 | 0.9106    |  0.8983     |    1.0000   |


 

### Las losowy
Dla algorytmu lasu losowego wykonano testy działania dla różnej liczby generowanych drzew.
W tabeli zamieszczono wartości parametrów, dla których algorytm osiąga najlepsze wartości dla przyjętych metryk.

| Dane              | ntree | quality   | specificity | sensitivity |
| ----------------- |:-----:| :--------:|:-----------:|:-----------:|
| SPECT Heart       |  50   | 0.7914439 |  0.7907     |  0.8000     |
| Phishing Websites | 300   | 0.9579439 |  0.9730     |  0.9391     |
| KDD Cup 1999 Data |  50   | 0.9278138 |  0.9115     |  0.9952     |

![Analiza ROC, RF, zbiór SPECT](images/spect_rf_2.pdf)

![Analiza ROC, RF, zbiór Phishing Websites](images/pweb_rf_2.pdf)

### iForest
W ostatnim etapie badań sprawdzono jakość działania zaimplementowanego algorytmu detekcji anomalii lasu izolacyjnego. Wykresy ROC dla różnych wartości parametrów _ntree_ i  _chi_ przedstawione są na rysunkach \ref{pweb_if}, \ref{spect_if} i \ref{kdd_if}.
Najlepsze wyniki zamieszczono w tabeli.

| Dane              | ntree | chi   | threshold | specificity | sensitivity | kolor  |
| ----------------- |:-----:|:-----:|:---------:|:-----------:|:-----------:|:------:|
| SPECT Heart       |  30   |  32   | 0.5130554 | 73.8372093  | 73.3333333  | fiolet |
| Phishing Websites |  10   |  1024 | 0.5186933 | 73.2649203  | 74.4273504  | zółty  |
| KDD Cup 1999 Data |  30   |  512  | 0.4824599 | 97.0161570  | 91.8126787  | fiolet |

![Analiza ROC, iForest, zbiór SPECT \label{spect_if}](images/spect_if.png)

![Analiza ROC, iForest, zbiór Phishing Websites \label{pweb_if}](images/pweb_if.png)

![Analiza ROC, iForest, zbiór KDD \label{kdd_if}](images/kdd_if.png)

## Wnioski z wyników
W ramach projektu zaimplementowano algorytm lasu izolacji iForest w języku R. 
Na podstawie wykonanych testów należy stwierdzić, że algorytm z powodzeniem spełnia swoje przeznaczenie. 
Algorytm ten, podobnie jak las losowy, stworzył model, który dla zbioru KDD Cup 1999 Data na wykresie ROC znalazł punkt w okolicy optymalnego (100%,100%).

Algorytm wypada gorzej dla zbioru Phishing Websites, natomiast tworzy model lepszy od SVM.
Dla tego zbioru danych najlepsze rezultaty udało się osiągnąć algorytmami k-NN i RF.

Analiza wykresu krzywej ROC dla zbioru SPECT Heart sugeruje, że wszystkie badane algorytmy osiągnęły zbliżoną jakość. 
Prawdopodobnie wynika to z małej ilości przykładów zbioru.

# Bibliografia

[dataset]: https://archive.ics.uci.edu/ml/datasets/SPECT+Heart "SPECT Heart"
[wphish]: https://archive.ics.uci.edu/ml/datasets/Website+Phishing
[phishw]: https://archive.ics.uci.edu/ml/datasets/Phishing+Websites
[kdd]: http://archive.ics.uci.edu/ml/datasets/kdd+cup+1999+data
