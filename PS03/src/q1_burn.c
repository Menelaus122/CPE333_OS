/* CPE 333 PS03 - Q1
 * CPU burner used to demonstrate nice / renice / kill.
 * Usage: ./q1_burn <seconds> <label>
 *
 * It spins for <seconds> of wall clock time and reports how many rounds of
 * work it managed to finish. Two burners started together therefore report
 * numbers that can be compared directly: the ratio of the two round counts
 * is the ratio of the CPU share the scheduler gave them.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/resource.h>
#include <sys/time.h>

#define WORK_PER_ROUND 200000

int main(int argc, char *argv[])
{
    int seconds = (argc > 1) ? atoi(argv[1]) : 10;
    const char *label = (argc > 2) ? argv[2] : "burn";

    struct timeval start, now;
    gettimeofday(&start, NULL);

    unsigned long long rounds = 0;
    double sum = 0.0;
    double elapsed;

    for (;;) {
        for (int i = 0; i < WORK_PER_ROUND; i++)   /* one round of pure CPU work */
            sum += i * 0.5;
        rounds++;

        gettimeofday(&now, NULL);
        elapsed = (now.tv_sec - start.tv_sec)
                + (now.tv_usec - start.tv_usec) / 1e6;
        if (elapsed >= seconds)
            break;
    }

    int ni = getpriority(PRIO_PROCESS, 0);   /* the nice value we are running at */

    (void)sum;   /* compiled with -O0, so the work loop is never optimized away */

    printf("[%s] pid=%d nice=%d rounds=%llu wall=%.2fs\n",
           label, getpid(), ni, rounds, elapsed);
    fflush(stdout);
    return 0;
}
