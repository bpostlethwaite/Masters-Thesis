/*
    RUNCMD -- Run a command as a pipe and return output; fortran-callable.

    Called via (Fortran):
       res = runcmd(cmd,token,buf)

    Assumes:
       cmd	Command to run; must start with "|" to signify pipe
       token	Indicator of new command/continuing command; set to zero
                   to start new command.
       buf	Buffer address

    Returns:
       token	Token to be passed to continue to receive command output
       function result:
                >= 0 number of bytes read (one line or a full buffer)
                -1 end of file, finished
                -2 error

    History:  08/02/01  Initial version.
              08/03/09  Modified for better Fortran use.
       --G. Helffrich/U. Bristol

*/

#define runcmd runcmd_

#include <stdio.h>
#include <sys/file.h>
#include <fcntl.h>
#include <sys/stat.h>

int runcmd(char cmd[], int *token, char buf[],
           int cmdlen, int buflen) {

  int i, res;
  FILE *fp;

  /* See if abandon signal */
  if (*cmd != '|') {
    if (*token)
      res = pclose((FILE *)*token);
    else
      res = 0;
    *token = 0;
    return res;
  }

  /* See if start or resume */
  if (!*token) { /* Start */
    char *fname;
    if (*cmd != '|')
      return -1;

    for(i=cmdlen-1;cmd[i]==' ' && i>0;--i);  /* get rid of trailing blanks */
    fname = (char *)malloc(++i+1);
    if (fname == NULL)
      return -3;

    (void)strncpy(fname,cmd,i); fname[i]='\0';
    fp = popen(fname+1,"r");  		/* create pipe */
    free(fname);
    if (fp == NULL) {
      *token = 0;
      return -2;
    }
    *token = (int)fp;
  } else /* Resume - retrieve file pointer */
    fp = (FILE *)*token;

  /* Read next buffer of input, looping if zero because we're reading from
     a pipe, which may not deliver all the data requested at once. */
  i = 0;
  do {
    i += res = fread(buf+i, sizeof(char), 1, fp);
    if (res && buf[i-1] == '\n') return i-1;
  } while (i < buflen && !feof(fp));

  /* If done, call pclose, ensuring it returns something sensible */
  if (res <= 0)
    res = pclose(fp) ? -2 : -1;

  return res;
}

#if 0

main(argc,argv)
   int argc;
   char *argv[];
{
   char buf[128];
   int token = 0;
   int buflen = sizeof(buf);
   int res;
   int n=0;

   res = runcmd(argv[1],&token,&buflen,buf,strlen(argv[1]));
   while (res > 0) {
      fwrite(buf,sizeof(char),res,stdout);
      ++n;
      zrunout_(argv[1],&token,&buflen,buf,&res,strlen(argv[1]));
   }
   printf("\n%d calls%s\n",n,res ? ", ended in error":"");
}
#endif
