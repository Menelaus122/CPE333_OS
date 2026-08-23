/* q2_1_child_first.c -- CPE333 PS2, Q2.1
 *
 * Scenario: the CHILD dies while the PARENT is still running,
 * and the parent deliberately does NOT call wait().
 *
 * Expected observation with `ps -ef` / `ps -el` during the window:
 *   the child shows up as  [q2_1_child_fir] <defunct>  in state Z (zombie),
 *   still owned by the real parent (PPID = parent's PID), because the
 *   parent has not yet collected its exit status.
 *
 * Run:  ./q2_1_child_first &   then  ps -ef | grep q2_1
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PARENT_LIFETIME 30   /* seconds the parent stays alive after child dies */

int main(void)
{
    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) {
        /* CHILD: dies almost immediately */
        printf("[child ] PID = %d, PPID = %d -- exiting right now\n",
               getpid(), getppid());
        fflush(stdout);
        exit(0);
    }

    /* PARENT: outlives the child but never reaps it */
    printf("[parent] PID = %d, child PID = %d\n", getpid(), pid);
    printf("[parent] NOT calling wait(). Sleeping %d s.\n", PARENT_LIFETIME);
    printf("[parent] Inspect now with:  ps -ef | grep -e q2_1 -e defunct\n");
    fflush(stdout);

    sleep(PARENT_LIFETIME);

    printf("[parent] PID = %d exiting; the zombie child %d is now re-parented "
           "to init/systemd and reaped.\n", getpid(), pid);
    return 0;
}
