/* CPE 333 PS03 - Q1
 * A process that catches SIGTERM and SIGINT and refuses to exit,
 * used to show why SIGKILL (kill -9) exists.
 */
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

static const char msg_term[] = "[sigdemo] caught SIGTERM (15) -- handler ran, still alive\n";
static const char msg_int[]  = "[sigdemo] caught SIGINT  (2)  -- handler ran, still alive\n";

static void handler(int sig)
{
    /* write() is async-signal-safe, printf() is not */
    if (sig == SIGTERM)
        write(STDOUT_FILENO, msg_term, sizeof msg_term - 1);
    else
        write(STDOUT_FILENO, msg_int, sizeof msg_int - 1);
}

int main(void)
{
    signal(SIGTERM, handler);
    signal(SIGINT, handler);

    printf("[sigdemo] pid = %d, catching SIGTERM(15) and SIGINT(2)\n", getpid());
    fflush(stdout);

    for (;;)
        pause();     /* sleep until a signal arrives */

    return 0;
}
