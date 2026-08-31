#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PROCESSES 100

// you may change this if needed
typedef struct {
    int pid;        // process id (int)
    int arrival;    // arrival time
    int burst;      // burst time
    int remaining;  // remaining burst time
    int finished;   // 0 = not finished, 1 = done
} Process;


/* Print one merged time slot. "idx" is the index of the process that owned
 * the CPU during [start, end), or -1 when the CPU was idle.
 * Nothing is printed for an empty slot (start == end), which happens once
 * before the very first scheduling decision. */
static void print_slot(int start, int end, int idx, const Process *procs)
{
    if (start >= end)
        return;

    if (idx < 0)
        printf("[%d-%d]: IDLE\n", start, end);
    else
        printf("[%d-%d]: P%d\n", start, end, procs[idx].pid);
}


/* Shortest Time-to-Completion First (STCF), also known as SRTF.
 *
 * The scheduler is preemptive: at the beginning of every time unit it looks at
 * every process that has already arrived and is not finished, and gives the CPU
 * to the one with the smallest remaining time. A process that arrives at time T
 * is already in the ready queue when the decision for time T is taken, so the
 * test below is "arrival <= time".
 *
 * Ties are broken by the smaller pid. That single rule covers both tie cases in
 * the problem statement: processes that arrive together still hold their full
 * burst as their remaining time, so "same arrival" is just a special case of
 * "same remaining time".
 *
 * Consecutive time units owned by the same process are merged into one slot,
 * so the output shows [start-end] ranges instead of one line per time unit.
 */
void simulate_stfc(Process *procs, int n)
{
    int time = 0;
    int done = 0;

    int current = -1;    /* index of the process on the CPU, -1 = idle */
    int slot_start = 0;  /* time at which the current slot began */

    /* A process with no work to do would never reach remaining == 0 by running,
     * so retire it up front instead of letting it stall the simulation. */
    for (int i = 0; i < n; i++) {
        if (procs[i].remaining <= 0 && !procs[i].finished) {
            procs[i].finished = 1;
            done++;
        }
    }

    while (done < n) {
        /* choose the ready process with the shortest remaining time */
        int pick = -1;
        for (int i = 0; i < n; i++) {
            if (procs[i].finished || procs[i].arrival > time)
                continue;

            if (pick == -1 ||
                procs[i].remaining < procs[pick].remaining ||
                (procs[i].remaining == procs[pick].remaining &&
                 procs[i].pid < procs[pick].pid))
                pick = i;
        }

        /* the owner of the CPU changed, so the previous slot ends here */
        if (pick != current) {
            print_slot(slot_start, time, current, procs);
            slot_start = time;
            current = pick;
        }

        if (pick == -1) {
            time++;      /* nothing has arrived yet, the CPU stays idle */
            continue;
        }

        procs[pick].remaining--;
        time++;

        if (procs[pick].remaining == 0) {
            procs[pick].finished = 1;
            done++;
        }
    }

    print_slot(slot_start, time, current, procs);   /* the last slot */
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <csvfile>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        perror("Error opening file");
        return 1;
    }

    Process procs[MAX_PROCESSES];
    int n = 0;
    char line[256];

    // skip header line
    // (checking the return value keeps an empty file from being read as data,
    //  and keeps the compile clean at -O2 where fgets is warn_unused_result)
    if (!fgets(line, sizeof(line), fp)) {
        fprintf(stderr, "Error: %s is empty\n", argv[1]);
        fclose(fp);
        return 1;
    }

    // read each row
    // you may change this if needed
    while (fgets(line, sizeof(line), fp) && n < MAX_PROCESSES) {
        int pid, arrival, burst;
        if (sscanf(line, "%d,%d,%d", &pid, &arrival, &burst) == 3) {
            procs[n].pid = pid;
            procs[n].arrival = arrival;
            procs[n].burst = burst;
            procs[n].remaining = burst;
            procs[n].finished = 0;
            n++;
        }
    }
    fclose(fp);

    simulate_stfc(procs, n);

    return 0;
}
