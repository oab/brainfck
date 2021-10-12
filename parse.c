#include <stdio.h>
#include <stdlib.h>

#define SIZE 256
extern char codebuffer[SIZE];
void evalbf(void);
int main(int argc, char* argv[]) 
{

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
  while((c = fgetc(file)) != EOF && read < SIZE-1) {	  
    switch(c) {
      case '>': codebuffer[read++]=0; break;
      case '<': codebuffer[read++]=1; break;
      case '+': codebuffer[read++]=2; break;
      case '-': codebuffer[read++]=3; break;
      case '.': codebuffer[read++]=4; break;
      case ',': codebuffer[read++]=5; break;
      case '[': codebuffer[read++]=6; break;
      case ']': codebuffer[read++]=7; break;
      default: break;
    }
  }
  // insert end of program marker
  codebuffer[read++] = 8;
  //for(int i=0;i<read;i++) printf("%d",codebuffer[i]);
  //printf("\n");
  //exit(0);

  if (SIZE < read) {
    fprintf(stderr,"program rejected; too big\n");
    exit(EXIT_FAILURE);
  }

  fclose(file);

  evalbf();

  return EXIT_SUCCESS;
}
