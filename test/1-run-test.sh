#!/bin/bash

# Author: puya.vahabi@gmail.com puyavahabi@berkeley.edu pvahabi@mit.edu
# Execute: sh 1-run-test.sh 
# Description: This shell script generate synthetic data and query, and run the indexer of satire, and query processor for the synthetic data.
#

# PARAM
num_terms=5000					       # number of terms desired for the synthetic data 
num_docs=25205180			 	       # number of docs desired for the synthetic data
max_run_length=20				       # max number of docs in one run (run=given a term, all the docs with the same score are in 1 run)
datapath="../data/testdata.tsv"			       # 
datapath_normalized="../data/testdata_normalized.tsv"  # This is the file of text containing the term \t doc \t scores for each line.
datapath_query="../data/querytestdata.tsv"             # the path where we save the synthetic query data
num_queries=50000				       # max number of queries in the synthetic data for testing purpose 
max_query_length=4				       # max number of terms in the syntethic data for each query (randomly selected)
output_stem="test"  				       # This will be the stem of the index files produced.
lowScoreCutoff=000.1				       # If a quantised term doc score is less than this, it will not be included inthe index.
maxQuantisedValue=10000				       # The floating point scores are multiplied by this and then floor()ed.
datapath_query_processed="querytestdata.out"           # output of the query processing
indexStem="test"				       # This is the stem of the three files making up the SATIRE index to be used: <stem>.cfg, <stem>.vocab and <stem>.if.
debg=0						       # Controls verbosity of debugging output of query processor
postingsCountCutoff=0				       # Query processing - Early Termination Mechanism. Stop if the total number of postings processed exceeds this value. (Only checked at the end of a run, and if value > 0.)
lowScoreCutoff=1				       # An early termination mechanism (ETM).  Don't process any postings with scores below this value.
k=10						       # The number of ranked results required.


echo "Generating synthetic data and queries for $num_terms terms, $num_docs documents and max_run_length=$max_run_length"
#perl ../data/1-generate_test_data.pl $num_terms $num_docs $max_run_length $datapath $datapath_normalized $maxQuantisedValue
#perl ../data/2-generate_test_queries.pl $num_queries $max_query_length $num_terms $datapath_query

echo "Run the indexer and put the index in the test directory";
python ../dataset/compute_bm25.py ../dataset/ | ../src/i.exe inputFileName=$datapath_normalized outputStem=$indexStem numDocs=$num_docs lowScoreCutoff=$lowScoreCutoff maxQuantisedValue=$maxQuantisedValue

echo "Run the queries and put the output in the test directory\n\n";
#../src/q.exe indexStem=$indexStem numDocs=$num_docs debug=$debg postingsCountCutoff=$postingsCountCutoff k=$k lowScoreCutoff=$lowScoreCutoff < $datapath_query > $datapath_query_processed

echo "Done."


