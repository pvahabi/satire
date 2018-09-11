#!/bin/bash

# Author: puya.vahabi@gmail.com puyavahabi@berkeley.edu pvahabi@mit.edu
# Execute: sh run.sh
# Description: This shell script generate synthetic data and query for testing the indexing and query processing of satire. 
#

perl 1-generate_test_data.pl 100 5 4 testdata.tsv testdata_normalized.tsv 10000
# 2-generate_test_queries.pl #queries #querylengthmax #terms_datase
perl 2-generate_test_queries.pl 10 4 100 querytestdata.tsv

