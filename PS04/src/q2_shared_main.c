/* =====================================================================
 *  CPE 333 PS04 - Q2 : what "extern" is actually for (file 2 of 2)
 *  This file only DECLARES the variable: no storage is reserved here,
 *  the linker resolves the name to the one defined in q2_shared_def.c.
 * ===================================================================== */
#include <stdio.h>

extern int shared_counter;      /* declaration: no storage reserved */
void bump_from_other_file(void);

int main(void)
{
    printf(" q2_shared_main.c: value = %d, address = %p\n",
           shared_counter, (void *) &shared_counter);

    bump_from_other_file();

    printf(" q2_shared_main.c: value = %d, address = %p   (changed by the other file)\n",
           shared_counter, (void *) &shared_counter);
    return 0;
}
