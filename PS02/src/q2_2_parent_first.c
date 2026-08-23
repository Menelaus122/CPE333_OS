/* q2_2_parent_first.c -- CPE333 PS2, Q2.2
 *
 * Scenario: the PARENT dies while the CHILD is still running.
 *
 * The child becomes an ORPHAN. The kernel immediately re-parents it to
 * the nearest subreaper, normally PID 1 (init/systemd) -- or the user's
 * systemd --user instance on a modern desktop distro.
 *
 * The child therefore prints two different PPIDs: its real parent before
 * the parent exits, and 1 (or the subreaper) afterwards.
 * NOTE: there is NO zombie here -- an orphan is reaped automatically.
 *
 * Run:  ./q2_2_parent_first &   then  ps -ef | grep q2_2
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define CHILD_LIFETIME 30

int main(void)
{
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) {
        /* CHILD: outlives the parent */
        printf("[child ] PID = %d, PPID = %d  (original parent, still alive)\n",
               getpid(), getppid());
        fflush(stdout);

        sleep(2);   /* give the parent time to die */

        printf("[child ] PID = %d, PPID = %d  (parent is gone -> re-parented)\n",
               getpid(), getppid());
        printf("[child ] Inspect now with:  ps -ef | grep q2_2\n");
        fflush(stdout);

        sleep(CHILD_LIFETIME);

        printf("[child ] PID = %d exiting, final PPID = %d\n",
               getpid(), getppid());
        exit(0);
    }

    /* PARENT: exits immediately, without waiting */
    printf("[parent] PID = %d, child PID = %d -- exiting immediately\n",
           getpid(), pid);
    fflush(stdout);
    return 0;
}
