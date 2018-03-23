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

bibliography: src/ref.bib
---

# Szczegółowa interpretacja tematu projektu
Opracowywany temat - _Nienadzorowana detekcja anomalii za lasu izolacyjnego. Porównanie z nadzorowaną detekcją anomalii za pomocą dostępnych w R algorytmów klasyfikacji._
Bardziej szczegółowa interpretacja projektu została opisana w rozdziale trzecim.

# Opis algorytmów


## Algorytm implementowany
Detekcja anomalii z wykorzystaniem lasu izolacji (_iForest_) polega na separacji próbki na
podstawie zmierzonego stopnia podatności na izolację. W tym celu metoda wykorzystuje właściwości
anomalii - niewielką liczebność oraz znacząco różniące się wartości atrybutów.

Izolacja jest zrealizowana z użyciem prawidłowych drzew binarnych (_iTree_), w których każdy węzeł
w drzewie ma dokładnie zero lub dwa węzły potomne. Przyjętą miarą podatności na izolację jest
długość ścieżki, czyli liczba krawędzi jakie należy przejść, by dojść od pnia do danej próbki
(o ile przejście to nie przekracza zdefiniowanej maksymalnej wysokości drzewa). Przykłady o
krótkiej ścieżce mają wysoką podatność, ponieważ obserwacje o wyróżniających się wartościach
atrybutów mają większe szanse na oddzielenie w początkowej fazie procesu partycjonowania, a
dodatkowo niewielka liczba anomalii powoduje mniejszą liczbę partycji.

Wykrywanie anomalii na podstawie lasu izolacyjnego jest dwustopniowe.
Pierwszy etap, uczenie, polega na budowie drzew
izolacji z użyciem podpróbek zbioru testowego. W następnym etapie algorytm przekazuje
przykłady testowe przez drzewa izolacji, aby uzyskać wynik anomalii dla każdego z nich.
Sposobem wykrywania anomalii jest sortowanie przykładów według ich średniej długości ścieżki.
Anomalie są przykładami, które znajdują się na górze listy.


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

Cechy pojedyńczego połączenia TCP:
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
- analogicznie: procent połączeń z błędami ,,SYN'', ,,REJ'', do innncyh usług.


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
do porównania.
Istotny wydaje się również wybór odpowiedniego jądra wraz z parametrami
dla algorytmu SVM, który zostanie dokonany później.
W miarę możliwości może być również powiększana wykorzystywana liczba próbek z zbioru danych [KDD Cup 1999 Data].
Dopuszczamy również możliwość ograniczenia liczby atrybutów, jeżeli
nie będziemy w stanie obsłużyć tak dużej ilości atrybutów.


# Bibliografia


[dataset]: https://archive.ics.uci.edu/ml/datasets/SPECT+Heart "SPECT Heart"
[wphish]: https://archive.ics.uci.edu/ml/datasets/Website+Phishing
[phishw]: https://archive.ics.uci.edu/ml/datasets/Phishing+Websites
[kdd]: http://archive.ics.uci.edu/ml/datasets/kdd+cup+1999+data
