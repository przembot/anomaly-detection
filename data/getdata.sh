#!/bin/sh

# KDD Cup
wget http://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/kddcup.names
wget http://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/kddcup.data_10_percent.gz
wget http://archive.ics.uci.edu/ml/machine-learning-databases/kddcup99-mld/corrected.gz
gunzip *.gz

# Phishing Websites
wget -O PW.arff https://archive.ics.uci.edu/ml/machine-learning-databases/00327/Training%20Dataset.arff

# SPECT Heart
wget https://archive.ics.uci.edu/ml/machine-learning-databases/spect/SPECT.names
wget https://archive.ics.uci.edu/ml/machine-learning-databases/spect/SPECT.train
wget https://archive.ics.uci.edu/ml/machine-learning-databases/spect/SPECT.test
