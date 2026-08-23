/* q4_pipe.c -- CPE333 PS2, Q4
 *
 * pipe() + fork(): the CHILD is the sender, the PARENT is the receiver.
 *
 * A pipe is a unidirectional byte stream with two descriptors:
 *   fd[0] = read end, fd[1] = write end.
 * fork() duplicates both ends, so after the fork FOUR descriptors refer to
 * the pipe. Each side must close the end it does not use:
 *   sender   (child)  closes fd[0]
 *   receiver (parent) closes fd[1]
 * If the receiver kept fd[1] open, its read() would never see end-of-file,
 * because the kernel only reports EOF once every write end is closed.
 *
 * Expected output (deterministic -- see the note in the parent branch):
 *   Child: Child PID: xxxxxx
 *   Parent: Parent PID: yyyyyy
 *   Parent: Hello from child PID: xxxxxx
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define BUFSZ 128

int main(void)
{
    int fd[2];
    pid_t pid;
    char msg[BUFSZ], buf[BUFSZ];
    ssize_t n;

    if (pipe(fd) < 0) {
        perror("pipe");
        exit(EXIT_FAILURE);
    }

    pid = fork();
    if (pid < 0) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) {
        /* ---------- CHILD = SENDER ---------- */
        close(fd[0]);                       /* sender never reads */

        printf("Child: Child PID: %d\n", getpid());
        fflush(stdout);

        snprintf(msg, sizeof msg, "Hello from child PID: %d", getpid());

        if (write(fd[1], msg, strlen(msg) + 1) < 0) {   /* +1 sends the '\0' */
            perror("child write");
            exit(EXIT_FAILURE);
        }

        close(fd[1]);                       /* signal EOF to the reader */
        exit(EXIT_SUCCESS);
    }

    /* ---------- PARENT = RECEIVER ---------- */
    close(fd[1]);                           /* receiver never writes */

    /* Read FIRST, then print. The child flushes its own line to stdout before
     * it writes into the pipe, so this read() cannot return until the child's
     * line has already reached the terminal. That makes the output order
     * deterministic and equal to the one the problem sheet specifies, using
     * the blocking read as the synchronisation point -- no sleep() needed.
     * Printing before the read would race the child and, in practice, put the
     * parent's line first about 39 times out of 40. */
    n = read(fd[0], buf, sizeof buf - 1);   /* blocks until the child writes */
    if (n < 0) {
        perror("parent read");
        exit(EXIT_FAILURE);
    }
    buf[n] = '\0';

    printf("Parent: Parent PID: %d\n", getpid());
    printf("Parent: %s\n", buf);

    close(fd[0]);
    wait(NULL);                             /* reap the child */
    return 0;
}
