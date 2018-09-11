#! /usr/bin/perl -w

# Author: puya.vahabi@gmail.com puyavahabi@berkeley.edu pvahabi@mit.edu
# Execute: 1-generate_test_data.pl #terms #docs #max_run_length #outputfile #outputfile_normalized_version <term_id \t doc_id \t score> SCORE_FLOATING
# Description: the file is getting as input the number of terms and documents
#              in the generated dataset, and given a term and a score, max number of docs with that score. 
#              The output is in this format
#              Term_id		Score_1 docs_with_this_score* doc_1 doc_2 doc_3 ...# Score_2 doc_with_this_score* doc_8 doc_9 doc_13#
#              00000000         10 4* 15 18 16 19# 9 1* 0# 8 3* 3 12 2# 7 1* 8# 6 9* 6 9 5 4 10 14 11 17 13# 5 2* 7 1#
#              00000001         10 2* 17 15# 9 9* 14 2 12 8 7 5 3 16 1# 8 9* 4 13 18 19 11 10 6 9 0#
#              The output for the second file:
#              term_id \t doc_id \t score
#              0 \t  5 \t 1
# Usage example: perl 1-generate_test_data.pl 100 5 4 testdata.tsv testdata_normalized.tsv 10000

use List::Util qw(shuffle);
die "Usage: $0 number_of_terms number_of_documents max_run_length output_file SCORE_FLOATING\n"
    unless $#ARGV == 5;

die "Can't write to $ARGV[3]\n"
    unless open T, ">$ARGV[3]";

die "Can't write to $ARGV[4]\n"
    unless open N, ">$ARGV[4]";


$SCORE_FLOATING = $ARGV[5];                                # print the score value in a float value - divide the score by $SCORE_FLOATING
for ($t = 0; $t < $ARGV[0]; $t++) {                        # Loop over all the terms, one term per each line
    @doclist = shuffle 0..($ARGV[1] - 1);                  # Have a random ordered list of all the doc ids possible
    $docs_not_output = $ARGV[1];                           # Documents not yet output for this particular term
    $max_score = int (2.5 * $ARGV[1] / $ARGV[2]);          # Some value for the max_score possible
    $max_score = 10 if $max_score < 10;
    $score = $max_score;                                   # Start with max_score

    print T sprintf("%08d\t", $t);			   # Start the TERM LINE
    $i = 0; 						   # inserted by PUYA
    while ($docs_not_output > 0 ) {
	$run_length = 1 + int(rand($ARGV[2]));  	   # Choose a random run length in  1..max_run_length
	$run_length = $docs_not_output if ($run_length > $docs_not_output);
	# $i = 0;  # index into shuffled doc list  CHANGED BY PUYA
	print T " $score $run_length*";                    # Write the info <score and number of docs> for this run of this term
	my @dlist;
	for ($r = 0; $r < $run_length; $r++) {
            $doc_id = $doclist[$i++];
	    $dlist[$r] = $doc_id;
	    $docs_not_output--; 			   # to just be sure that we have not yet used all the docs in the dataset
	}
        $score_f = $score/$SCORE_FLOATING;
        my @sorted_dlist = sort { $a <=> $b } @dlist;
	for ($r = 0; $r < $run_length; $r++) {
	    print T " ", $dlist[$r];                       # each run is composed by a set of docs that have same score for this term
            print N sprintf("%d\t%d\t%f\n", $t, $sorted_dlist[$r],$score_f);
	}
	print T "#";   					    # Mark the end of the run.
	$score--;					    # Next run will have 1 score less, so all the scores are ordered
    }
    print T "\n";                                           # END OF LINE FOR THIS TERM
}

close T;
close N;
print "@ARGV", "\n written.\n";
exit(0);
