#!/bin/bash
# =====================================================================
#  CPE 333 PS04 - Q2 : เก็บผลการทดลอง Extern Storage Class
#  ใช้งาน :  bash run_q2.sh > ../result/q2_verified.txt 2>&1
#  ต้องรันบน Linux (หรือ WSL) และมี gcc, binutils (nm/readelf/objdump), util-linux (setarch)
# =====================================================================
cd "$(dirname "$0")" || exit 1
WORK=/tmp/ps04_q2
mkdir -p "$WORK"

hr(){ echo; echo "===================================================================="; echo "$*"; echo "===================================================================="; }
sub(){ echo; echo "----- $* -----"; }

# รันโปรแกรมซ้ำ 3 ครั้งตามที่โจทย์กำหนด
run3(){                      # run3 <label> <binary>
  local i
  for i in 1 2 3; do
    echo "\$ $1                              # run $i"
    "$2"
  done
}

hr "0. Environment"
echo "\$ uname -r ; lsb_release -ds ; gcc --version | head -1"
uname -r
lsb_release -ds
gcc --version | head -1
echo
echo "\$ cat /proc/sys/kernel/randomize_va_space   # 2 = full ASLR is ON"
cat /proc/sys/kernel/randomize_va_space

# =====================================================================
hr "1. STEP 1 : with 'extern' in main(), compiled WITHOUT -no-pie (default = PIE)"
# =====================================================================
echo "\$ gcc -Wall -Wextra -o q2_extern q2_extern.c"
gcc -Wall -Wextra -o "$WORK/q2_extern" q2_extern.c
echo "(exit status = $?)"
echo
run3 "./q2_extern" "$WORK/q2_extern"

# =====================================================================
hr "2. STEP 2-3 : 'extern' deleted from main(), compiled WITHOUT -no-pie"
# =====================================================================
echo "\$ gcc -Wall -Wextra -o q2_noextern q2_noextern.c"
gcc -Wall -Wextra -o "$WORK/q2_noextern" q2_noextern.c
echo "(exit status = $?)"
echo
run3 "./q2_noextern" "$WORK/q2_noextern"

# =====================================================================
hr "3. STEP 4 : the very same two programs rebuilt with -no-pie"
# =====================================================================
echo "\$ gcc -no-pie -Wall -Wextra -o q2_extern_nopie   q2_extern.c    2>/dev/null"
gcc -no-pie -Wall -Wextra -o "$WORK/q2_extern_nopie" q2_extern.c 2>/dev/null
echo "\$ gcc -no-pie -Wall -Wextra -o q2_noextern_nopie q2_noextern.c  2>/dev/null"
gcc -no-pie -Wall -Wextra -o "$WORK/q2_noextern_nopie" q2_noextern.c 2>/dev/null

sub "3.1 extern + -no-pie"
run3 "./q2_extern_nopie" "$WORK/q2_extern_nopie"

sub "3.2 no extern + -no-pie"
run3 "./q2_noextern_nopie" "$WORK/q2_noextern_nopie"

# =====================================================================
hr "4. Evidence : declaration vs definition, and which x is which"
# =====================================================================

sub "4.1 symbol table : the global x is a GLOBAL symbol, the local x has no symbol at all"
echo "\$ nm q2_extern_nopie   | grep -w x           # 'D' upper case = external linkage"
nm "$WORK/q2_extern_nopie" | grep -w x
echo "\$ nm q2_noextern_nopie | grep -w x           # the global x is still there, unchanged"
nm "$WORK/q2_noextern_nopie" | grep -w x
echo
echo "\$ readelf -s q2_extern_nopie | grep -w x     # OBJECT, GLOBAL, 4 bytes, in .data"
readelf -s "$WORK/q2_extern_nopie" | grep -w x
echo
echo "(compare with Q1: the static y was 'd' lower case = local, no other file can see it)"

sub "4.2 the 'extern' keyword inside main() is a no-op"
# สร้างไฟล์ที่ลบทั้งบรรทัด extern int x; ใน main ทิ้ง (ไม่ประกาศอะไรเลย)
# ถ้า extern ในฟังก์ชันไม่มีผล โค้ดเครื่องของ main ต้องออกมาเหมือนกันเป๊ะ
awk '{ if ($0 == "    extern int x;" && ++n == 2) next; print }' q2_extern.c > "$WORK/q2_nodecl.c"
echo "\$ diff q2_extern.c q2_nodecl.c        # the whole declaration line is gone from main()"
diff q2_extern.c "$WORK/q2_nodecl.c"
echo
gcc -no-pie -w -o "$WORK/q2_nodecl_nopie" "$WORK/q2_nodecl.c"
objdump -d --no-show-raw-insn "$WORK/q2_extern_nopie" | sed -n '/<main>:/,/^$/p' | tail -n +2 > "$WORK/dis_extern.txt"
objdump -d --no-show-raw-insn "$WORK/q2_nodecl_nopie" | sed -n '/<main>:/,/^$/p' | tail -n +2 > "$WORK/dis_nodecl.txt"
echo "\$ objdump -d q2_extern_nopie | sed -n '/<main>:/,/^\$/p' > dis_extern.txt"
echo "\$ objdump -d q2_nodecl_nopie | sed -n '/<main>:/,/^\$/p' > dis_nodecl.txt"
echo "\$ diff dis_extern.txt dis_nodecl.txt"
if diff "$WORK/dis_extern.txt" "$WORK/dis_nodecl.txt"; then
  echo "identical, the extern declaration inside main() generates no code at all"
fi
echo
echo "\$ cat dis_extern.txt                  # the machine code of main() in both files"
cat "$WORK/dis_extern.txt"

sub "4.3 a declaration is not a definition : remove the global and the LINKER complains"
sed '/^int x = 20;$/d' q2_extern.c > "$WORK/q2_nodef.c"
echo "\$ diff q2_extern.c q2_nodef.c         # the definition 'int x = 20;' is gone"
diff q2_extern.c "$WORK/q2_nodef.c"
echo "\$ gcc -w -o q2_nodef q2_nodef.c"
gcc -w -o "$WORK/q2_nodef" "$WORK/q2_nodef.c" 2>&1 | sed -e "s#$WORK/##g" -e 's#/usr/bin/ld#ld#'
echo "(exit status of gcc = ${PIPESTATUS[0]}   -> the compiler was happy, the linker was not)"

sub "4.4 ASLR switched off (setarch -R) : the addresses stop moving"
echo "\$ setarch -R ./q2_extern   | grep Address     # run 1, 2, 3"
for i in 1 2 3; do setarch -R "$WORK/q2_extern" | grep -m1 Address; done
echo
echo "\$ setarch -R ./q2_noextern | grep Address     # run 1, 2, 3 (the local x in main)"
for i in 1 2 3; do setarch -R "$WORK/q2_noextern" | grep -m1 Address; done
echo
echo "\$ setarch -R bash -c 'grep \[stack\] /proc/self/maps'"
setarch -R bash -c 'grep "\[stack\]" /proc/self/maps'

sub "4.5 what extern is actually for : one variable shared by two .c files"
echo "\$ gcc -Wall -Wextra -o q2_shared q2_shared_main.c q2_shared_def.c"
gcc -Wall -Wextra -o "$WORK/q2_shared" q2_shared_main.c q2_shared_def.c
echo "(exit status = $?)"
echo "\$ ./q2_shared"
"$WORK/q2_shared"
echo
echo "\$ nm q2_shared_main.o | grep -w shared_counter    # 'U' = Undefined, only a declaration"
gcc -c -o "$WORK/q2_shared_main.o" q2_shared_main.c
gcc -c -o "$WORK/q2_shared_def.o" q2_shared_def.c
nm "$WORK/q2_shared_main.o" | grep -w shared_counter
echo "\$ nm q2_shared_def.o  | grep -w shared_counter    # 'D' = Defined, this is where it lives"
nm "$WORK/q2_shared_def.o" | grep -w shared_counter

hr "END OF Q2"
