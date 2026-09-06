#!/bin/bash
# =====================================================================
#  CPE 333 PS04 - Q3 : เก็บผลการทดลอง malloc / realloc / free
#  ใช้งาน :  bash run_q3.sh > ../result/q3_verified.txt 2>&1
#  ต้องรันบน Linux (หรือ WSL) และมี gcc, util-linux (setarch)
#  โจทย์ข้อนี้กำหนดให้คอมไพล์แบบปกติ คือ "without -no-pie"
# =====================================================================
cd "$(dirname "$0")" || exit 1
WORK=/tmp/ps04_q3
mkdir -p "$WORK"

hr(){ echo; echo "===================================================================="; echo "$*"; echo "===================================================================="; }
sub(){ echo; echo "----- $* -----"; }

# ดึงค่าที่อยู่ตัวที่ n ที่พิมพ์ด้วย ">>" ถัดจากหัวข้อ s ในไฟล์ผล
field(){    # field <file> <section header> <n>
  awk -v s="$2" -v n="$3" \
      '$0==s{f=1;c=0;next} f&&/^>>/{c++; if(c==n){print substr($0,3); exit}}' "$1"
}

hr "0. Environment"
echo "\$ uname -r ; lsb_release -ds ; gcc --version | head -1 ; ldd --version | head -1"
uname -r
lsb_release -ds
gcc --version | head -1
ldd --version | head -1
echo
echo "\$ cat /proc/sys/kernel/randomize_va_space   # 2 = full ASLR is ON"
cat /proc/sys/kernel/randomize_va_space

# =====================================================================
hr "1. STEP 1-2 : the program exactly as the sheet gives it (b still commented out)"
# =====================================================================
echo "\$ gcc -Wall -Wextra -o q3_alloc q3_alloc.c"
gcc -Wall -Wextra -o "$WORK/q3_alloc" q3_alloc.c
echo "(exit status = $?)"

sub "1.1 first run"
echo "\$ ./q3_alloc"
"$WORK/q3_alloc"

sub "1.2 second run, to separate what moves from what stays"
echo "\$ ./q3_alloc"
"$WORK/q3_alloc"

# =====================================================================
hr "2. STEP 4-5 : the two commented places uncommented (b is allocated and freed)"
# =====================================================================
echo "\$ diff q3_alloc.c q3_alloc_b.c        # only the two blocks the sheet asks about"
diff q3_alloc.c q3_alloc_b.c
echo
echo "\$ gcc -Wall -Wextra -o q3_alloc_b q3_alloc_b.c"
gcc -Wall -Wextra -o "$WORK/q3_alloc_b" q3_alloc_b.c
echo "(exit status = $?)"

sub "2.1 first run"
echo "\$ ./q3_alloc_b"
"$WORK/q3_alloc_b"

sub "2.2 second run"
echo "\$ ./q3_alloc_b"
"$WORK/q3_alloc_b"

# =====================================================================
hr "3. STEP 6 : the two programs compared directly, with ASLR switched off"
# =====================================================================
echo "(setarch -R makes both programs start from the same heap base, so the"
echo " addresses of the two runs can be compared number by number)"
echo
echo "\$ setarch -R ./q3_alloc   > out_a.txt"
setarch -R "$WORK/q3_alloc"   > "$WORK/out_a.txt"
echo "\$ setarch -R ./q3_alloc_b > out_b.txt"
setarch -R "$WORK/q3_alloc_b" > "$WORK/out_b.txt"
echo "\$ diff out_a.txt out_b.txt"
diff "$WORK/out_a.txt" "$WORK/out_b.txt"

sub "3.1 the numbers that matter, side by side"
A_MAL=$(field "$WORK/out_a.txt" "After malloc Pointer a" 1)
A_REA=$(field "$WORK/out_a.txt" "After realloc Pointer a" 1)
B_MAL=$(field "$WORK/out_b.txt" "After malloc Pointer a" 1)
B_B=$(field   "$WORK/out_b.txt" "After malloc Pointer b" 1)
B_REA=$(field "$WORK/out_b.txt" "After realloc Pointer a" 1)

printf '%-34s %-16s %-16s\n' "" "q3_alloc" "q3_alloc_b"
printf '%-34s %-16s %-16s\n' "a after malloc(40)"   "$A_MAL" "$B_MAL"
printf '%-34s %-16s %-16s\n' "b after malloc(40)"   "(not allocated)" "$B_B"
printf '%-34s %-16s %-16s\n' "a after realloc(4000)" "$A_REA" "$B_REA"
echo
if [ "$A_MAL" = "$A_REA" ]; then
  echo "q3_alloc  : realloc returned the SAME address, the block grew in place"
else
  echo "q3_alloc  : realloc MOVED the block by $(( A_REA - A_MAL )) bytes"
fi
if [ "$B_MAL" = "$B_REA" ]; then
  echo "q3_alloc_b: realloc returned the SAME address, the block grew in place"
else
  echo "q3_alloc_b: realloc MOVED the block by $(( B_REA - B_MAL )) bytes"
fi
echo
echo "b - a                     = $(( B_B - B_MAL )) bytes   (40 bytes were requested)"
echo "new a - b                 = $(( B_REA - B_B )) bytes"

# =====================================================================
hr "4. Evidence : which region is which, chunk overhead, and realloc's rule"
# =====================================================================
echo "\$ gcc -Wall -Wextra -o q3_regions q3_regions.c"
gcc -Wall -Wextra -o "$WORK/q3_regions" q3_regions.c
echo "(exit status = $?)"
echo
echo "\$ setarch -R ./q3_regions            # ASLR off so the numbers stay comparable"
setarch -R "$WORK/q3_regions" > "$WORK/regions.txt"
awk '/^== 4/{exit} {print}' "$WORK/regions.txt"

sub "4.1 the kernel's own map of the same process (only the lines that matter)"
echo "\$ ... reading /proc/self/maps from inside the program"
grep -E '\[heap\]|\[stack\]|rw-p .*q3_regions' "$WORK/regions.txt"

hr "END OF Q3"
