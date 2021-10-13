#include <stdio.h>
#include <stdlib.h>

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
  struct bracket bracketstack[MAX_CODESIZE];
  int top=-1;

  if(argc != 2)	{
    fprintf(stderr,"expected input file\n");
    exit(EXIT_FAILURE);
  }
  
  FILE *file = fopen(argv[1],"r");
  if(!file) {
    fprintf(stderr,"failed to open file %s\n",argv[1]);
    exit(EXIT_FAILURE);
  }
  

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
        if (0 <= top && bracketstack[top].bracket == '[') {
          // store the jump locations in the byte next to the brackets 
          // we store jump locations as relative displacements st. if ... m  ...  k ....
          // we want, given i@m+2 and j@k+2                               [ai     ]bj
          // to set a=k-m+2 and b=k-m+2
          // st. if we are at m then m+a = k+2 and if we are at k then k-a = m+2
          int displacement = read- bracketstack[top].read+2;
          codebuffer[bracketstack[top].read+1] = displacement;
          codebuffer[read+1]= displacement;
          top--;
        }
        read+=2;
        
        break;
      default: break;
    }
  }
 
  if(0 <= top) {
    fprintf(stderr,"program rejected; unbalanced brackets\n");
    exit(EXIT_FAILURE);
  }
  // insert end of program marker
  codebuffer[read++] = END;
  for(int i=0;i<=read;i++) {
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
    }
    if(!l) { 
      printf("%c ",out);
    } else {
      printf("%c%d",out,codebuffer[i++]);
    }
  }
  printf("\n");
  exit(0);


  fclose(file);

  evalbf();

  return EXIT_SUCCESS;

  
}
