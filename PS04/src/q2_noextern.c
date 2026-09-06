/* =====================================================================
 *  CPE 333 PS04 - Q2 Step 2 : the same program with "extern" removed from main()
 *  Step 2 of the problem sheet: delete "extern" on line 15 and re-run.
 *  Build:  gcc -o q2_noextern q2_noextern.c            (default = PIE)
 *          gcc -no-pie -o q2_noextern_nopie q2_noextern.c
 * ===================================================================== */
#include <stdio.h>
#include <stdlib.h>

int x = 20;

void display()
{
    extern int x;
    printf(" Display value of x: %d\n", x);
    printf(" Address of x (in display function): %p\n\n", &x);
}

void main()
{
    int x;
    printf(" Print value of x: %d\n", x);
    printf(" Address of x (in main function): %p\n\n", &x);

    display();
}
