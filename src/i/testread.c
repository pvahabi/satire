// Author: Puya.vahabi@gmail.com, puyavahabi@berkeley.edu pvahabi@mit.edu  
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.
// Description: reading a binary file in the following format, pseudocode in python:
//              with open('./bhd_term_stats.txt', mode='rb') as reader:
// 			while reader:
// 				size_packed = reader.read(4)
// 				if len(size_packed) == 4:
//				size = struct.unpack('i', size_packed)[0]
//				print(size)
//				for i in range(size):
//					docid = struct.unpack('i', reader.read(4))[0]
//					tf = struct.unpack('h', reader.read(2))[0]
//					print(docid)
//					print(tf)
#include <stdio.h>
#include <stdlib.h>
#define MAXDNUM 50000000
#define MAXTNUM 50000
/* function to read one couple docid, quantized_score */
int readds(FILE *fp, unsigned int* docid, float* qscore);

int readds(FILE *fp, unsigned int* docid, float* qscore){
    size_t bytes = 0;
    // read docid
    if ((bytes = fread(docid, sizeof(unsigned int), 1, fp)) == 1 ){
        if (*docid>0){
            if ((bytes = fread(qscore, sizeof(float), 1, fp)) == 1 ){
                if (*qscore>0){
                    printf(" docid: %u, qscore: %f", *docid, *qscore);
                    putchar ('\n');
                 } else {fprintf(stderr, "error in reading qscore from file, qscore equal to zero");}
            } else {fprintf(stderr, "error in reading qscore from file");}
         } else {fprintf(stderr, "error in reading docid from file, docid equal to zero");}
    } else {fprintf(stderr, "error in reading docid from file"); }   
    return 0;
}

int main (int argc, char **argv) {
    //unsigned char buf[BUFSZ] = {0};
    //size_t bytes = 0, readsz = sizeof buf;
    //static unsigned int doc_len_norm[
    size_t bytes = 0;
    unsigned int i, docid, termid, length = 0;
    float qscore;
    FILE *fp = argc > 1 ? fopen (argv[1], "rb") : stdin;
    
    if ( (sizeof(unsigned int)) != 4 || (sizeof(float)) != 4 ){
        fprintf(stderr, "error: number of bytes for unsigned int or float in this platform are not supported");
    }
    
    if (!fp) {
        fprintf (stderr, "error: file open failed '%s'.\n", argv[1]);
        return 1;
    }
    
    termid = 0;
    while( (bytes = fread(&length, sizeof(unsigned int), 1, fp)) == 1 ){ 
        printf("number of docs: %u for termid: %u",length, termid);
        // read one unsinged int 
        if (length > 0){
           for (i = 0; i < length; i++){
               // we have termid, docid, qscore after here, mv the file pointer
               readds(fp, &docid, &qscore);
           } 
        }
        termid++;
        // print just one line
        return 0;
    }

    if (fp != stdin)
        fclose (fp);
    return 0;
}


