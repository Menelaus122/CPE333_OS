/* =====================================================================
 *  CPE 333 PS04 - Q1 Step 2 : the same program with the "static" keyword removed
 *  Step 2 of the problem sheet: delete the "static" keyword and re-run.
 *  Build:  gcc -o q1_auto q1_auto.c            (default = PIE)
 *          gcc -no-pie -o q1_auto_nopie q1_auto.c
 * ===================================================================== */
#include <stdio.h>
#include <stdlib.h>

void main()
{
    auto int x = 3;

    while (x > 0)
    {
        int y = 5;
        y++;

        printf("The value of y is %d\n", y);
        printf("The address of y is %p\n\n", &y);

        x--;
    }
}
