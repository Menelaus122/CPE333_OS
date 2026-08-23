/* q1_2_wait.c -- CPE333 PS2, Q1.2
 *
 * Same program as q1_1 but the parent calls wait() so that it blocks
 * until the child terminates. This forces a deterministic ordering:
 * the child's output always appears before the parent's post-wait output,
 * and the child is reaped immediately (never left <defunct>).
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>  

int main(void)
{
    pid_t pid;

    printf("Hello World!\n");

    pid = fork();
    if (pid < 0) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) {
        /* child */
        printf("I am the child, my PID = %d, my parent PID = %d\n",
               getpid(), getppid());
    } else {
        /* parent */
        wait(NULL); 
        printf("I am the parent, my PID = %d, my child PID = %d\n",
               getpid(), pid);
    }

    printf("Common line printed by PID %d\n", getpid());
    return 0;
}
