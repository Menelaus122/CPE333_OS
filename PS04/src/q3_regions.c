/* =====================================================================
 *  CPE 333 PS04 - Q3 : evidence program (not part of the problem sheet)
 *
 *  It answers three questions that the sheet's program only hints at:
 *    (1) which named memory region does each printed address belong to?
 *    (2) why are two consecutive malloc() blocks 48 bytes apart when
 *        only 40 bytes were asked for?
 *    (3) when does realloc() keep the block in place, and when must it move it?
 *
 *  Build:  gcc -Wall -Wextra -o q3_regions q3_regions.c
 * ===================================================================== */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

static int data_var = 7;                /* lives in .data, like Q1 and Q2 */

int main(void)
{
    int  stack_arr[10];
    int *heap_ptr = malloc(10 * sizeof(int));

    printf("== 1. one address from each region ==\n");
    printf("&data_var    (a .data object) = %p\n", (void *) &data_var);
    printf("heap_ptr     (from malloc)    = %p\n", (void *) heap_ptr);
    printf("&stack_arr[0](a local array)  = %p\n", (void *) &stack_arr[0]);
    printf("&heap_ptr    (the pointer)    = %p\n", (void *) &heap_ptr);

    printf("\n== 2. how far apart are consecutive malloc() blocks? ==\n");
    {
        size_t sizes[] = { 1, 8, 24, 25, 40, 40 };
        void  *prev = NULL;
        size_t i;

        for (i = 0; i < sizeof sizes / sizeof sizes[0]; i++) {
            void *p = malloc(sizes[i]);
            printf("malloc(%2zu) -> %p", sizes[i], p);
            if (prev != NULL)
                printf("   gap from previous block = %td bytes",
                       (char *) p - (char *) prev);
            printf("\n");
            prev = p;
        }
    }

    printf("\n== 3. realloc(): grow in place, or move? ==\n");
    {
        void         *p, *q, *blocker;
        unsigned long before;       /* keep the OLD address as a plain number:  */
                                    /* after realloc the old pointer itself is  */
                                    /* indeterminate and must not be used again */

        /* case A: the block is the last one on the heap, nothing is behind it */
        p      = malloc(10 * sizeof(int));
        before = (unsigned long) (uintptr_t) p;
        q      = realloc(p, 1000 * sizeof(int));
        printf("case A  no block behind it : 0x%lx -> %p   %s\n", before, q,
               (before == (unsigned long) (uintptr_t) q) ? "SAME (grown in place)"
                                                         : "MOVED");
        free(q);

        /* case B: another block was allocated right behind it first */
        p       = malloc(10 * sizeof(int));
        blocker = malloc(10 * sizeof(float));
        before  = (unsigned long) (uintptr_t) p;
        q       = realloc(p, 1000 * sizeof(int));
        printf("case B  a block behind it  : 0x%lx -> %p   %s\n", before, q,
               (before == (unsigned long) (uintptr_t) q) ? "SAME (grown in place)"
                                                         : "MOVED");
        free(q);
        free(blocker);
    }

    printf("\n== 4. the same addresses as named by the kernel ==\n");
    {
        FILE *f = fopen("/proc/self/maps", "r");
        char  line[512];

        if (f != NULL) {
            while (fgets(line, sizeof line, f) != NULL)
                fputs(line, stdout);
            fclose(f);
        }
    }

    free(heap_ptr);
    return 0;
}
