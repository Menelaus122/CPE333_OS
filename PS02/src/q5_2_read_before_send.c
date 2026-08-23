/* q5_2_read_before_send.c -- CPE333 PS2, Q5.2
 *
 * EXPERIMENT: what happens if the RECEIVER reads BEFORE the sender sends?
 *
 * Phase 1: the parent calls read() on an empty pipe whose write end is
 *          still open. read() does not fail and does not return 0 --
 *          it BLOCKS. The child sleeps 3 s and then writes; only then does
 *          the parent's read() return. The measured elapsed time proves
 *          the parent really was asleep in the kernel.
 *
 * Phase 2: the child closes its write end and exits. The parent reads again.
 *          Now every write end is closed, so read() returns 0 = EOF
 *          instead of blocking.
 *
 * Conclusion: a blocking read() on a pipe synchronises the two processes.
 * "Empty pipe + writer alive" -> block. "Empty pipe + no writer" -> EOF.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/wait.h>

#define BUFSZ 128
#define SEND_DELAY 3

static double now(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

int main(void)
{
    int fd[2];
    pid_t pid;
    char msg[BUFSZ], buf[BUFSZ];
    ssize_t n;
    double t0;

    if (pipe(fd) < 0) { perror("pipe"); exit(EXIT_FAILURE); }

    pid = fork();
    if (pid < 0) { perror("fork"); exit(EXIT_FAILURE); }

    if (pid == 0) {
        /* ---------- CHILD = SENDER, but a slow one ---------- */
        close(fd[0]);

        printf("[child ] sleeping %d s before sending ...\n", SEND_DELAY);
        fflush(stdout);
        sleep(SEND_DELAY);

        snprintf(msg, sizeof msg, "Hello from child PID: %d", getpid());
        printf("[child ] sending now: \"%s\"\n", msg);
        fflush(stdout);
        if (write(fd[1], msg, strlen(msg) + 1) < 0)
            perror("child write");

        close(fd[1]);            /* closing the last write end -> reader sees EOF */
        printf("[child ] write end closed, exiting.\n");
        fflush(stdout);
        exit(EXIT_SUCCESS);
    }

    /* ---------- PARENT = RECEIVER, reads far too early ---------- */
    close(fd[1]);

    printf("[parent] calling read() immediately, pipe is still empty ...\n");
    fflush(stdout);

    t0 = now();
    n = read(fd[0], buf, sizeof buf - 1);
    if (n > 0) {
        buf[n] = '\0';
        printf("[parent] read() returned after %.2f s with %zd bytes: \"%s\"\n",
               now() - t0, n, buf);
        printf("[parent] -> read() BLOCKED, it did not fail and did not "
               "return 0.\n");
    } else {
        printf("[parent] read() returned %zd\n", n);
    }
    fflush(stdout);

    /* Phase 2: read again, this time with no writer left */
    printf("[parent] reading again, now that every write end is closed ...\n");
    fflush(stdout);

    t0 = now();
    n = read(fd[0], buf, sizeof buf - 1);
    printf("[parent] read() returned %zd after %.2f s  -> %s\n",
           n, now() - t0,
           n == 0 ? "EOF (no writer left, so no blocking)" : "unexpected");

    close(fd[0]);
    wait(NULL);
    return 0;
}
