/* =====================================================================
 *  CPE 333 PS04 - Q2 : what "extern" is actually for (file 1 of 2)
 *  This file DEFINES the variable, so this is where the storage lives.
 *  Build:  gcc -Wall -Wextra -o q2_shared q2_shared_main.c q2_shared_def.c
 * ===================================================================== */
#include <stdio.h>

int shared_counter = 100;       /* definition: reserves the storage */

void bump_from_other_file(void)
{
    shared_counter++;
    printf(" q2_shared_def.c : value = %d, address = %p\n",
           shared_counter, (void *) &shared_counter);
}
