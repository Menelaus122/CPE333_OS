/* q5_1_sender_reads_own.c -- CPE333 PS2, Q5.1
 *
 * EXPERIMENT: what happens if the SENDER tries to read back its own message?
 *
 * Neither side closes any descriptor here, so the child holds both ends.
 * A pipe has no notion of "who wrote this" -- it is just a FIFO byte queue.
 * Whoever calls read() first drains the bytes.
 *
 * Phase 1: child writes, then immediately reads from fd[0] itself.
 *          -> the child gets its OWN message back.
 * Phase 2: the parent, the intended receiver, then tries to read.
 *          -> the pipe is empty and write ends are still open, so the
 *             parent BLOCKS forever. SIGALRM breaks it out after 3 s and
 *             read() fails with EINTR.
 *
 * Conclusion: the message was stolen by its own sender; the data is lost.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <sys/wait.h>

#define BUFSZ 128

static void on_alarm(int sig) { (void)sig; }   /* just interrupt the read() */

int main(void)
{
    int fd[2];
    pid_t pid;
    char msg[BUFSZ], buf[BUFSZ];
    ssize_t n;
    struct sigaction sa;

    if (pipe(fd) < 0) { perror("pipe"); exit(EXIT_FAILURE); }

    pid = fork();
    if (pid < 0) { perror("fork"); exit(EXIT_FAILURE); }

    if (pid == 0) {
        /* ---------- CHILD = SENDER, but it also reads ---------- */
        /* NOTE: deliberately NOT closing fd[0] -- that is the whole point. */
        snprintf(msg, sizeof msg, "Hello from child PID: %d", getpid());

        printf("[child ] writing: \"%s\"\n", msg);
        fflush(stdout);
        if (write(fd[1], msg, strlen(msg) + 1) < 0)
            perror("child write");

        printf("[child ] now reading from fd[0] (its OWN pipe) ...\n");
        fflush(stdout);

        n = read(fd[0], buf, sizeof buf - 1);
        if (n > 0) {
            buf[n] = '\0';
            printf("[child ] read back %zd bytes: \"%s\"   <-- its own message!\n",
                   n, buf);
        } else {
            printf("[child ] read returned %zd (%s)\n", n, strerror(errno));
        }
        fflush(stdout);
        exit(EXIT_SUCCESS);
    }

    /* ---------- PARENT = the intended RECEIVER ---------- */
    sa.sa_handler = on_alarm;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;                 /* no SA_RESTART: we WANT read() to fail */
    sigaction(SIGALRM, &sa, NULL);

    sleep(1);                        /* let the child write AND read first */

    printf("[parent] now trying to read the message ...\n");
    fflush(stdout);

    alarm(3);                        /* safety net so we never hang */
    n = read(fd[0], buf, sizeof buf - 1);
    alarm(0);

    if (n > 0) {
        buf[n] = '\0';
        printf("[parent] got %zd bytes: \"%s\"\n", n, buf);
    } else if (n == 0) {
        printf("[parent] read returned 0 (EOF)\n");
    } else {
        printf("[parent] read FAILED: %s\n", strerror(errno));
        printf("[parent] -> the pipe was empty: the sender had already "
               "consumed its own message.\n");
    }

    wait(NULL);
    return 0;
}
