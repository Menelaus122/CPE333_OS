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


void simulate_stfc(Process *procs, int n) {
    //your implementation
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
    fgets(line, sizeof(line), fp);

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
