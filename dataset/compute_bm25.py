# Author: puya.vahabi@gmail.com puyavahabi@berkeley.edu pvahabi@mit.edu
# Execute: python compute_bm25.py 
# Description: This file is taking the input files (in Alessandro's format), compute the bm25, and create one single file with the following format:
#              <Length_of_posting_list:int32><docid:int32><qscore:float32>...<docid:int32><qscore:float32> ... the first posting list is for termid 1 the next
#              is for termid 2 ... 
#

from __future__ import print_function
import sys
import os
import csv
import re
import struct
import datetime
import math
import random
import scipy
import glob
import string
import numpy as np
import operator

K1 = 0.9
B = 0.4

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def compute_doccnt_len(fname):
    DOC_COUNT = 0
    AVG_DOC_LEN = 0
    s = 0
    with open(fname, mode='r') as reader:
        for line in reader:
            cols = line.strip().split(' ')
            docid = int(cols[0])
            doc_name = cols[1]
            doc_len = int(cols[2])
            s = s + doc_len
            DOC_COUNT = DOC_COUNT + 1
    AVG_DOC_LEN = s/DOC_COUNT
    return (DOC_COUNT, AVG_DOC_LEN)

# main
def main(dirdata='./' ):
    eprint("computing doc_count and avg_doc_len")
    # ==> doc_map.txt <==
    # 1 GX244-49-0000000 313
    # 2 GX244-49-0011365 515
    DOC_COUNT = 25205160
    AVG_DOC_LEN = 937.2530745291837
    #DOC_COUNT, AVG_DOC_LEN = compute_doccnt_len(dirdata + "bhd_doc_map.txt")
    eprint("average doc length: " + str(AVG_DOC_LEN) + " average doc count: "+ str(DOC_COUNT))
    
    eprint("computing doc normalized length ")
    doc_len_norm = dict()
    with open(dirdata + 'bhd_doc_map.txt', mode='r') as reader:
        for line in reader:
            cols = line.strip().split(' ')
            docid = int(cols[0])
            doc_name = cols[1]
            doc_len = int(cols[2])
            doc_len_norm[docid] = K1 * (1 - B + B * doc_len / AVG_DOC_LEN)
      
    # ==> bhd_term_stem.txt <==
    # zovirax zovirax 640 356      puya: column 0 and 2 not clear what they are
    # zuniga zuniga 2747 1386
    eprint("computing IDF ")
    term_id = 0 # starting term_id from 0
    idf = dict()
    #termid = dict()
    with open(dirdata + 'bhd_term_stem.txt', mode='r') as reader:
        for line in reader:
            cols = line.strip().split(' ')
            term = cols[1]
            #termid[term] = term_id
            df = int(cols[3])
            if df > 0:
                idf[term_id] = math.log(DOC_COUNT / df)
            term_id = term_id + 1            
     
    # format of this file in input  <Length_of_posting_list:int32><docid:int32><tf:int16> all the terms in sequence from termid 1 
    # format output <Length_of_posting_list:int32><docid:int32><qscore:float32>
    eprint("computing BM25, and final score to save ")
    term_id = 0
    lout = []
    with open(dirdata + "bhd_term_stats.txt", mode='rb') as reader:
        #with open(dirdata + "impact_qscore.bin", mode='wb') as writer:
            while reader:
                size_packed = reader.read(4)
                if len(size_packed) == 4:
                    lout = []
                    #writer.write(size_packed)  # 4 bytes
                    size = struct.unpack('i', size_packed)[0]
                    for i in range(size):
                        docid = struct.unpack('i', reader.read(4))[0]
                        tf = struct.unpack('h', reader.read(2))[0]
                        #writer.write(struct.pack('i', docid )) # 4 bytes
                        bm25 = idf[term_id] * (K1 + 1) * tf / (doc_len_norm[docid] + tf)
                        #print("termid: " + str(term_id) + " docid: "+str(docid)+" tf: " + str(tf)+" bm25: "+str(bm25))
                        # if you want to introduce quantization here is the right place
                        #if term_id%100 ==0:
                        #    ieprint("termid: " + str(term_id) + " docid: "+str(docid)+" tf: " + str(tf)+" bm25: "+str(bm25))
                        #writer.write(struct.pack('f', bm25))   # 4 bytes  
                        if bm25 > 19.99: # upper bound
                               bm25 = 19.99
                        lout.append((term_id, docid, bm25))
                    lout.sort(key=lambda k: (k[2], -k[1]), reverse=True)
                    # lout.sort(key=operator.itemgetter(1))
                    #lout.sort(key=operator.itemgetter(2),reverse=True)
                    #lout.sort(key=operator.itemgetter(2,1), )
                    for term_id, docid, bm25 in lout:
                        print("%d\t%d\t%f" % (term_id, docid, bm25/20))
                else:
                    break
                term_id = term_id + 1       
if __name__ == "__main__":
    main(sys.argv[1])

