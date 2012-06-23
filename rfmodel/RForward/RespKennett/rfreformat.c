/* This program is a bit of glue between the synthetic seismogram program
   and the receiver function program.  It waits for output from it and
   reformats the output into what the RF calculation program wants to see.
   It uses character-by-character reads to defeat buffering so that it can
   respond as soon as complete output is available.
   
   The reformatting is essentially the equivalent of this:

   | awk 'BEGIN{win="'"${win}"'"; noi="'"${noi}"'"}
      {rfout=substr($1,1,length($1)-1) "rfr"
         printf "%s %s %s %s %s %s\n",$1,win,$2,win,noi,rfout
      }' |

   where the $win is the first arg, and the $noi is the second arg to the
   program.

   -v option for testing; it echoes the standard input to standard error as
      soon as something is available.

   2008/03/11 - Initial version.
   2008/06/30 - Arbitrary suffix (third arg).

   --G. Helffrich/U. Bristol
*/

#include <stdlib.h>
#include <stdio.h>
#define BUFLEN 512

int main(int argc, char *argv[]) {
   int i, j, verb = 0, res, str[3];
   char buf[BUFLEN], *sfx = "rfr";

   if (argc < 2) exit(1);

   for(str[2]=j=0, i=1; i<argc; i++) {
      if (0 == strcmp(argv[i],"-v"))
         verb = 1;
      else 
         str[j++] = i;
   }
   if (str[2]) sfx=argv[str[2]];

   setlinebuf(stdin); setlinebuf(stdout);

   do {
      int k;

      res = i = 0;
      do {
         res += i;
	 i = fread(buf+res, sizeof(char), 1, stdin);
      } while (buf[res] != '\n' && !feof(stdin));
      if (res <= 0) break;
      if (verb) fprintf(stderr, "(reformat) %.*s", res, buf);
      for(i=0; i<res; i++) if (buf[i] == ' ') break;
      for(j=i; j<res; j++) if (buf[j] != ' ') break;
      for(k=j; k<res; k++) if (buf[k] == ' ' || buf[k] == '\n') break;
      buf[i] = buf[k] = '\0';
      fprintf(stdout,
         "%s %s %s %s %s %.*s%s\n",
	    buf,argv[str[0]],buf+j,argv[str[0]],argv[str[1]],k-j-1,buf+j,sfx);
      fflush(stdout);
   } while (1);

   return 0;
}
