#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#define INITIAL_BALANCE 1000L 
#define AMOUNT          1L     
#define MAX_THREADS     64

long balance = INITIAL_BALANCE; 

enum role { DEPOSITOR, WITHDRAWER, BOTH };

struct atm {
    pthread_t tid;
    enum role role;
    long      tx;               /* transactions this thread must make     */
    long      deposits;         /* written once by the thread when done:  */
    long      withdrawals;      /* how many transactions it really made   */
};

void deposit_plain(void)
{
    balance = balance + AMOUNT;
}

void withdraw_plain(void)
{
    balance = balance - AMOUNT;
}

void *atm_thread(void *arg)
{
    struct atm *a = arg;
    long done_dep = 0, done_wdr = 0;    
    long i;

    if (a->role == DEPOSITOR || a->role == BOTH)
        for (i = 0; i < a->tx; i++) {
            deposit_plain();
            done_dep++;
        }
    if (a->role == WITHDRAWER || a->role == BOTH)
        for (i = 0; i < a->tx; i++) {
            withdraw_plain();
            done_wdr++;
        }

    a->deposits    = done_dep;
    a->withdrawals = done_wdr;
    return NULL;
}

static void usage(const char *prog)
{
    fprintf(stderr, "usage: %s [threads] [tx_per_thread]\n"
                    "  threads = 1, or an even number from 2 to %d\n",
            prog, MAX_THREADS);
    exit(1);
}

int main(int argc, char *argv[])
{
    struct atm atms[MAX_THREADS];
    int  nthreads = 1;
    long tx       = 1000000;
    long deposits = 0, withdrawals = 0, expected;
    int  i;

    if (argc > 1)
        nthreads = atoi(argv[1]);
    if (argc > 2)
        tx = atol(argv[2]);
    if (nthreads < 1 || nthreads > MAX_THREADS
        || (nthreads > 1 && nthreads % 2 != 0) || tx < 1)
        usage(argv[0]);

    memset(atms, 0, sizeof atms);
    for (i = 0; i < nthreads; i++) {
        atms[i].tx = tx;
        if (nthreads == 1)
            atms[i].role = BOTH;
        else
            atms[i].role = (i < nthreads / 2) ? DEPOSITOR : WITHDRAWER;
    }

    /* start every ATM first, then wait for all of them to finish */
    for (i = 0; i < nthreads; i++)
        if (pthread_create(&atms[i].tid, NULL, atm_thread, &atms[i]) != 0) {
            perror("pthread_create");
            return 1;
        }
    for (i = 0; i < nthreads; i++)
        pthread_join(atms[i].tid, NULL);

    for (i = 0; i < nthreads; i++) {
        deposits    += atms[i].deposits;
        withdrawals += atms[i].withdrawals;
    }
    expected = INITIAL_BALANCE + deposits * AMOUNT - withdrawals * AMOUNT;

    printf("[plain] threads=%d tx=%ld in=%ld out=%ld | expected=%ld actual=%ld diff=%+ld %s\n",
           nthreads, tx, deposits, withdrawals, expected, balance,
           balance - expected, (balance == expected) ? "OK" : "RACE");
    return 0;
}
