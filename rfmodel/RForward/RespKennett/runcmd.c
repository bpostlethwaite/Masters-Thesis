/*
    RUNCMD -- Run a command as a pipe and return output; fortran-callable.

    Called via (Fortran):
       res = runcmd(cmd,token,buf)

    Assumes:
       cmd	Command to run or input to command.
                string must start with "|" to signify command to run
		string must start with ">" to signify text to write to
		   the command to be read as input by it,
		string must start with "<" to signify a line of text to be
		   read from the command, as output by it.  Text following
		   "<" is a prefix, which, when read, terminates the read
		   with end-of-file indication; re-read is possible.
       token	Indicator of new command/continuing command; set to zero
                   to start new command.
       buf	Buffer address - contains output to send, or input to return

    Returns:
       token	Token to be passed to continue to receive command output
       function result:
                >= 0 number of bytes read (one line or a full buffer)
                -1 end of file, finished
                -2 error

    History:  08/02/01  Initial version.
              08/03/09  Modified for better Fortran use.
              08/03/11  Bidirectional I/O, multiple running commands.
              08/05/13  Add prefix check to turn around transaction.
       --G. Helffrich/U. Bristol

*/

#define runcmd runcmd_
#define CHARS sizeof(char)

#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

/* ********************************************************************* *
 *                                                                       *
 *   First, a little linked-list library to help keep track of pipes:    *
 *                                                                       *
 * ********************************************************************* */

/* Map integer PID's into pipes to use for communication. */
struct pid_list
{
  int   pid;              /* key */
  FILE *pipes[2];         /* val */
  struct pid_list *next;  /* duh */ 
};

static struct pid_list *pid_ll = (struct pid_list *) NULL;

/* The ll_*() functions all make use of the global var `pid_ll'. */

static int
ll_insert (int key, FILE *in, FILE *out)
{
  struct pid_list *new;
  new = (struct pid_list *) malloc (sizeof (*new));

  new->pid       = key;
  new->pipes[0]  = in;
  new->pipes[1]  = out;
  new->next      = pid_ll;

  pid_ll = new;

  return key;
}


static void
ll_delete (int key)
{
  struct pid_list *this, *last;

  this = pid_ll;
  last = (struct pid_list *) NULL;

  while (this)
    {
      if (this->pid == key)
        {
          /* Delete this node and leave. */
          if (last)
            last->next = this->next;
          else
            pid_ll = this->next;
          free (this);
          return;
        }

      /* Else no match, so try the next one. */
      last = this;
      this = this->next;
    }
}

static FILE ** 
ll_lookup (int key)
{
  struct pid_list *this = pid_ll;

  while (this)
    {
      if (this->pid == key)
        return this->pipes;

      /* Else no match, so try the next one. */
      this = this->next;
    }

  /* Zero is special in this context anyway. */
  return NULL;
}

int runcmd(char cmd[], int *token, char buf[],
           int cmdlen, int buflen) {

  int i, res, inp[2], oup[2];

  /* See if abandon signal */
  if (*cmd != '|' &&
      *cmd != '>' &&
      *cmd != '<') {
    if (*token) {
      FILE **pipes = ll_lookup(*token);
      res = pipes != NULL;
      if (res) {
         kill(*token, SIGTERM);
	 res = fclose(pipes[0]) + fclose(pipes[1]);
         ll_delete(*token);
      }
    } else
      res = 0;
    *token = 0;
    return res;
  }

  /* See if start or resume */
  if (!*token) { /* Start */
    int pid;
    char *fname;
    char *argv[4];
    FILE *tofp, *frfp;
    extern char **environ;

    if (*cmd != '|')
      return -1;

    for(i=cmdlen-1;cmd[i]==' ' && i>0;--i);  /* get rid of trailing blanks */
    fname = (char *)malloc(++i+1);
    if (fname == NULL)
      return -3;

    (void)strncpy(fname,cmd,i); fname[i]='\0';
    argv[0] = "sh";
    argv[1] = "-c";
    argv[2] = fname+1;
    argv[3] = NULL;

    res =  pipe(&inp) + pipe(&oup);
    if (res) {
      *token = 0;
      return -2;
    }

    pid = fork();
    if (-1 == pid) {
       /* Error on process fork */
       *token = 0;
       return -2;
    }
    if (pid) {
       /* Parent process -- prepare pipes for use */
       res = close(oup[1]) + close(inp[0]);
       if (res) fprintf(stderr, "in parent: pipe close error %d\n", res);
       tofp = fdopen(inp[1], "w");
       res = tofp == NULL;
       if (res) fprintf(stderr, "in parent: input pipe fdopen failure\n");
       frfp = fdopen(oup[0], "r");
       res = frfp == NULL;
       if (res)
          fprintf(stderr, "in parent: output pipe fdopen failure\n");
       *token = ll_insert (pid, tofp, frfp);
       return res;
    }

    /* Child process -- housekeeping and start up other process */
    res = close(oup[0]) + close(inp[1]);
    if (res) {
       fprintf(stderr, "in child: pipe close error %d\n", res);
       exit(-2);
    }
    res = (0 != dup2(inp[0], 0)) + (1 != dup2(oup[1], 1));
    if (res) {
       fprintf(stderr, "in child: dup2 error %d\n", res);
       exit(-2);
    }
    res = execve("/bin/sh", argv, environ);
    exit (-2);
  }
  
  /* Resume - read or write.  Retrieve file pointer */
  if (*cmd == '>') {
     /* Write -- pass output to pipe. */
     FILE **pipes = ll_lookup(*token);

     res = pipes != NULL;
     if (res) {
        res =  fwrite( buf, CHARS, buflen, pipes[0]);
        res += fwrite( "\n", CHARS, 1, pipes[0]);
        fflush(pipes[0]);
     }
     res = (res == buflen+1) ? 0 : -1;

  } else {
     /* Read next buffer of input, looping if zero because we're reading from
        a pipe, which may not deliver all the data requested at once. */
     FILE **pipes = ll_lookup(*token);
     int pfxlen;

     if (pipes == NULL) return -2;

     /* Determine prompt length */
     for (i=cmdlen-1; i>0; i--)
        if (cmd[i] != ' ') break;
     pfxlen = i;

     i = 0;
     do {
	i += res = fread(buf+i, CHARS, 1, pipes[1]);
	if (i == pfxlen && 0 == strncmp(cmd+1,buf,pfxlen)) return -1;
	if (res && buf[i-1] == '\n') return i-1;
     } while (i < buflen && !feof(pipes[1]));
  }

  /* If done, call pclose, ensuring it returns something sensible */
  if (res < 0) {
     FILE **pipes = ll_lookup(*token);

     if (pipes != NULL) {
	kill(*token, SIGTERM);
	res = (fclose(pipes[0]) + fclose(pipes[1])) ? -2 : -1;
        ll_delete(*token);
     }
  }

  return res;
}
