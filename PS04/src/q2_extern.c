/* =====================================================================
 *  CPE 333 PS04 - Q2 Step 1 : Extern Storage Class
 *  Source code taken verbatim from the problem sheet (PS4_2026_OS.md).
 *  Build:  gcc -o q2_extern q2_extern.c            (default = PIE)
 *          gcc -no-pie -o q2_extern_nopie q2_extern.c
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
    extern int x;
    printf(" Print value of x: %d\n", x);
    printf(" Address of x (in main function): %p\n\n", &x);

    display();
}
