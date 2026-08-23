/* q5_3_many_messages.c -- CPE333 PS2, Q5.3
 *
 * EXPERIMENT: the sender writes SEVERAL messages before the receiver reads.
 *
 * A pipe is a BYTE STREAM, not a message queue. It preserves order
 * (FIFO) but keeps no record of where one write() ended and the next began.
 *
 * Phase 1: the child writes 3 messages while the parent sleeps.
 *          The parent then does ONE read() with a large buffer and gets
 *          all 3 messages glued together in a single call.
 * Phase 2: the child writes 3 more; the parent reads them 8 bytes at a
 *          time, showing that the boundaries were never there to begin with
 *          and a read() can split a message in half.
 *
 * Conclusion: framing is the application's job (fixed-size records, a
 * length prefix, or a delimiter such as '\0' / '\n').
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define BUFSZ   512
#define SMALL   8
#define NMSG    3

static void dump(const char *tag, const char *p, ssize_t n)
{
    ssize_t i;
    printf("%s %zd bytes: [", tag, n);
    for (i = 0; i < n; i++) {
        if (p[i] == '\0')      printf("<NUL>");
        else if (p[i] == '\n') printf("<LF>");
        else                   putchar(p[i]);
    }
    printf("]\n");
    fflush(stdout);
}

int main(void)
{
    int fd[2];
    pid_t pid;
    char msg[BUFSZ], buf[BUFSZ];
    ssize_t n;
    int i;

    if (pipe(fd) < 0) { perror("pipe"); exit(EXIT_FAILURE); }

    pid = fork();
    if (pid < 0) { perror("fork"); exit(EXIT_FAILURE); }

    if (pid == 0) {
        /* ---------- CHILD = SENDER ---------- */
        close(fd[0]);

        for (i = 1; i <= NMSG; i++) {
            snprintf(msg, sizeof msg, "MSG%d from child PID: %d|", i, getpid());
            printf("[child ] write #%d: \"%s\"\n", i, msg);
            fflush(stdout);
            if (write(fd[1], msg, strlen(msg)) < 0)   /* '|' is our delimiter */
                perror("child write");
        }

        sleep(2);   /* let the parent finish phase 1 before phase 2 starts */

        for (i = NMSG + 1; i <= 2 * NMSG; i++) {
            snprintf(msg, sizeof msg, "MSG%d|", i);
            printf("[child ] write #%d: \"%s\"\n", i, msg);
            fflush(stdout);
            if (write(fd[1], msg, strlen(msg)) < 0)
                perror("child write");
        }

        close(fd[1]);
        exit(EXIT_SUCCESS);
    }

    /* ---------- PARENT = RECEIVER, reads late ---------- */
    close(fd[1]);

    printf("[parent] sleeping 1 s so the child can queue %d messages ...\n",
           NMSG);
    fflush(stdout);
    sleep(1);

    printf("[parent] PHASE 1: one big read()\n");
    n = read(fd[0], buf, sizeof buf - 1);
    if (n > 0) {
        buf[n] = '\0';
        dump("[parent] got", buf, n);
        printf("[parent] -> %d separate write() calls arrived in ONE read(). "
               "Message boundaries are gone.\n", NMSG);
    }
    fflush(stdout);

    sleep(2);   /* let the child queue the second batch */

    printf("[parent] PHASE 2: reading %d bytes at a time\n", SMALL);
    while ((n = read(fd[0], buf, SMALL)) > 0)
        dump("[parent]   chunk", buf, n);

    printf("[parent] read() returned %zd -> EOF, sender is gone.\n", n);
    printf("[parent] -> a single message got split across several read() "
           "calls. The pipe is a byte stream.\n");

    close(fd[0]);
    wait(NULL);
    return 0;
}
