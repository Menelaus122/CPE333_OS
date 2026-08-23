/* q1_1_helloworld.c -- CPE333 PS2, Q1.1
 *
 * The plain fork() "hello world" from the process lecture slide.
 * fork() returns twice: 0 in the child, the child's PID in the parent.
 * The parent does NOT wait, so it can (and usually does) finish first.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

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
        printf("I am the parent, my PID = %d, my child PID = %d\n",
               getpid(), pid);
    }

    printf("Common line printed by PID %d\n", getpid());
    return 0;
}
