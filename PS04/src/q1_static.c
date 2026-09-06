/* =====================================================================
 *  CPE 333 PS04 - Q1 Step 1 : Static Storage Class
 *  Source code taken verbatim from the problem sheet (PS4_2026_OS.md).
 *  Build:  gcc -o q1_static q1_static.c            (default = PIE)
 *          gcc -no-pie -o q1_static_nopie q1_static.c
 * ===================================================================== */
#include <stdio.h>
#include <stdlib.h>

void main()
{
    auto int x = 3;

    while (x > 0)
    {
        static int y = 5;
        y++;

        printf("The value of y is %d\n", y);
        printf("The address of y is %p\n\n", &y);

        x--;
    }
}
