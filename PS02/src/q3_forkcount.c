/* q3_forkcount.c -- CPE333 PS2, Q3
 *
 * How many times can we successfully call fork()?
 *
 * Strategy (the one suggested in the hint): build a CHAIN, not a tree.
 * Every process forks exactly one child and then blocks in waitpid().
 * So the chain grows one process at a time and unwinds cleanly bottom-up
 * -- this is NOT a fork bomb, and it can be stopped at any moment.
 *
 * The deepest process (the first one whose fork() fails) reports the
 * number of successful fork() calls back to the root through a pipe,
 * together with the errno that stopped it.
 *
 * SAFETY
 *   - HARD_CAP below stops the chain unconditionally.
 *   - Optional argv[1] = N applies setrlimit(RLIMIT_NPROC, N) first, so you
 *     can rehearse the experiment against a small, safe ceiling before
 *     running it against the real system limit.
 *
 * Usage:
 *   ./q3_forkcount            run against the real RLIMIT_NPROC
 *   ./q3_forkcount 300        run against an artificial ceiling of 300
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/resource.h>

#define HARD_CAP 200000        /* never build a chain longer than this */

struct result {
    int count;                 /* number of successful fork() calls */
    int err;                   /* errno that stopped us (0 = hit HARD_CAP) */
};

static int pfd[2];

/* Send the tally up the chain to the root and leave. */
static _Noreturn void report(int count, int err)
{
    struct result r;
    r.count = count;
    r.err   = err;
    if (write(pfd[1], &r, sizeof r) != (ssize_t)sizeof r)
        _exit(1);
    _exit(0);
}

/* GCC sees that every non-recursive exit from chain() is a _Noreturn call and
 * flags -Winfinite-recursion. It is a false positive: the recursion happens in
 * a fresh child each time and terminates as soon as fork() fails (or HARD_CAP
 * is reached), neither of which the compiler can reason about. */
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Winfinite-recursion"

/* I am the process produced by fork() call number `level`. */
static void chain(int level)
{
    pid_t pid;

    if (level >= HARD_CAP)
        report(level, 0);          /* stopped by our own ceiling */

    pid = fork();

    if (pid < 0)
        /* fork #(level+1) failed -> `level` forks succeeded in total */
        report(level, errno);

    if (pid == 0)
        chain(level + 1);      /* the child keeps digging */

    /* parent of this link: hold still until the chain below me unwinds */
    waitpid(pid, NULL, 0);
    _exit(0);
}

#pragma GCC diagnostic pop

int main(int argc, char *argv[])
{
    pid_t pid;
    struct result r = { 0, 0 };
    struct rlimit rl;

    if (argc > 1) {
        rlim_t want = (rlim_t)strtoul(argv[1], NULL, 10);
        if (getrlimit(RLIMIT_NPROC, &rl) == 0) {
            rl.rlim_cur = want;
            if (rl.rlim_max != RLIM_INFINITY && rl.rlim_cur > rl.rlim_max)
                rl.rlim_cur = rl.rlim_max;
            if (setrlimit(RLIMIT_NPROC, &rl) != 0)
                perror("setrlimit");
        }
    }

    if (getrlimit(RLIMIT_NPROC, &rl) == 0)
        printf("RLIMIT_NPROC in effect: soft = %ld, hard = %ld\n",
               (long)rl.rlim_cur, (long)rl.rlim_max);

    printf("Root PID = %d. Forking a chain until fork() fails ...\n", getpid());
    fflush(stdout);

    if (pipe(pfd) < 0) {
        perror("pipe");
        exit(EXIT_FAILURE);
    }

    pid = fork();
    if (pid < 0) {
        r.count = 0;
        r.err   = errno;
    } else if (pid == 0) {
        close(pfd[0]);
        chain(1);              /* this process came from fork() #1 */
        _exit(0);              /* unreachable */
    } else {
        close(pfd[1]);         /* only the descendants write */
        waitpid(pid, NULL, 0);
        if (read(pfd[0], &r, sizeof r) != (ssize_t)sizeof r) {
            fprintf(stderr, "could not read result from pipe\n");
            exit(EXIT_FAILURE);
        }
        close(pfd[0]);
    }

    printf("fork() succeeded %d times.\n", r.count);
    if (r.err == 0)
        printf("Stopped by the program's own HARD_CAP (%d), not by the OS.\n",
               HARD_CAP);
    else
        printf("fork() #%d failed with errno %d (%s).\n",
               r.count + 1, r.err, strerror(r.err));

    return 0;
}
