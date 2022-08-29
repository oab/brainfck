#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define MAX_CODESIZE 256
#define MAX_BRACKETS 128
#define MAX_DISPLACEMENT 256

#define INCP 0
#define DECP 1
#define INCV 2
#define DECV 3
#define OUTV 4
#define INV 5
#define LPB 6
#define LPE 7
#define END 8

extern char codebuffer[MAX_CODESIZE];
void evalbf(void);

struct bracket {
  char bracket;
  short read;
};

int main(int argc, char* argv[]) 
{
  if(argc < 2)	{
    fprintf(stderr,"expected one or more arguments\n");
    exit(EXIT_FAILURE);
  }

  // flags 
  bool show_and_exit=false;    	
  // set flags	
  for(int arg=1;arg<argc-1;arg++) {
    if(strcmp(argv[arg],"-s") == 0 ) show_and_exit=true;
  }	  
 
  
  FILE *file = fopen(argv[argc-1],"r");
  if(!file) {
    fprintf(stderr,"failed to open file %s\n",argv[argc-1]);
    exit(EXIT_FAILURE);
  }
  
  struct bracket bracketstack[MAX_CODESIZE];
  int top=-1;
  int c;
  int read=0;
  while((c = fgetc(file)) != EOF) {
    if (read == MAX_CODESIZE-1) {
      fprintf(stderr,"program rejected; too big\n");
      exit(EXIT_FAILURE);
    }

    switch(c) {
      case '>': codebuffer[read++]=INCP; break;
      case '<': codebuffer[read++]=DECP; break;
      case '+': codebuffer[read++]=INCV; break;
      case '-': codebuffer[read++]=DECV; break;
      case '.': codebuffer[read++]=OUTV; break;
      case ',': codebuffer[read++]=INV; break;
      case '[': codebuffer[read]=LPB;
        bracketstack[++top] = (struct bracket){'[', read};
        read+=2;
        break;
      case ']': codebuffer[read]=LPE;
        if (top != -1 && bracketstack[top].bracket == '[') {
          // store the jump locations in the byte next to the brackets 
          // we store jump locations as relative displacements st. if ... m  ...  k ....
          // then k-(k-m) = m  and m+(k-m)=k  and we can compute          [ai     ]bj
          // i=m+2 and j=k+2
          // st. if we are at m then m+a = k+2 and if we are at k then k-a = m+2
          int displacement = read - bracketstack[top].read;
          codebuffer[bracketstack[top].read+1] = (char)displacement+2;
          codebuffer[read+1]= (char)displacement-2;
          --top;          
        } 
	read+=2;
        break;
      default: break;
    }
  }
  fclose(file);
  
  // insert end of program marker
  codebuffer[read++] = END;
 
  if(top != -1) {
    fprintf(stderr,"program rejected; unbalanced brackets\n");
    exit(EXIT_FAILURE);
  }
  
  if(show_and_exit) {
    for(int i=0;i<read;i++) {
      char out;
      int l=0;
      switch(codebuffer[i]) {
        case 0: out = '>';break;
        case 1: out = '<';break;
        case 2: out = '+';break;
        case 3: out = '-';break;
        case 4: out = '.';break;
        case 5: out = ',';break;
        case 6: out = '[';l=1;break;
        case 7: out = ']';l=1;break;
        case 8: out = 'E';break;
        default: out='?';break;      
      }
      if(l!=1) { 
        printf("%c",out);
      } else {
        printf("%c(%d)",out,codebuffer[++i]);
      }
    }
    printf("\n"); 
    exit(EXIT_SUCCESS);
  }

  evalbf();
  printf("\n");

  return EXIT_SUCCESS;

  
}
