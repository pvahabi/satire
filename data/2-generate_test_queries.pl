#! /usr/bin/perl -w

# Author: puya.vahabi@gmail.com puyavahabi@berkeley.edu pvahabi@mit.edu
# Execute: 2-generate_test_queries.pl #queries #max_query_length #max_terms_dataset #outputfile
# Description: the file is getting as input the number of queries (per each line there is one query), maximum terms per each query to be choosen randomly, 
#              max number of terms in the dataset, outputfilename.
#              The output:
#              query_id1 \t term_id1 term_id2 term_id3 ...
# Usage example: perl 2-generate_test_queries.pl 10 4 100 test_queries.tsv


use List::Util qw(shuffle);

die "Usage: $0 #queries #querylengthmax #terms_dataset\n"
    unless $#ARGV == 3;

die "Can't write\n"
    unless open T, ">$ARGV[3]";

for ($q = 0; $q < $ARGV[0]; $q++) { 				# Each line one query
    $qlength = int(rand($ARGV[1])) + 1;                         # Choose randomly the number of terms this query should have
    print T "$q\t";
    for ($w = 0; $w < $qlength; $w++) {                         # Loop on the query term
	$t = int(rand($ARGV[2]));                               # Write the terms this query has
	print T "$t ";
    }
    print T "\n";						# Next query
}

close T;

print "@ARGV", "\n written.\n";

exit(0);
