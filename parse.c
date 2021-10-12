#include <stdio.h>
#include <stdlib.h>

#define SIZE 256

#define INCP 0
#define DECP 1
#define INCV 2
#define DECV 3
#define OUTV 4
#define INV 5
#define LPB 6
#define LPE 7
#define END 8

extern char codebuffer[SIZE];
void evalbf(void);
int main(int argc, char* argv[]) 
{
  char bracketstack[SIZE];
  int top=0;

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
    if (read == SIZE-1) {
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
      case '[': codebuffer[read++]=LPB;
        bracketstack[top++] = '[';
        break;
      case ']': codebuffer[read++]=LPE;
        if (bracketstack[top] == '[') {
          top--;
        }
        break;
      default: break;
    }
  }
  if(!top) {
    fprintf(stderr,"program rejected; unbalanced brackets\n");
    exit(EXIT_FAILURE);
  }
  // insert end of program marker
  codebuffer[read++] = END;
  //for(int i=0;i<read;i++) printf("%d",codebuffer[i]);
  //printf("\n");
  //exit(0);


  fclose(file);

  evalbf();

  return EXIT_SUCCESS;
}
