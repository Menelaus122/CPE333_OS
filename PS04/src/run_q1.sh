#!/bin/bash
# =====================================================================
#  CPE 333 PS04 - Q1 : เก็บผลการทดลอง Static Storage Class
#  ใช้งาน :  bash run_q1.sh > ../result/q1_verified.txt 2>&1
#  ต้องรันบน Linux (หรือ WSL) และมี gcc, binutils (nm/readelf), util-linux (setarch)
# =====================================================================
cd "$(dirname "$0")" || exit 1
WORK=/tmp/ps04_q1
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
echo
echo "\$ gcc -v 2>&1 | grep -o -- '--enable-default-pie'   # PIE is the distro default"
gcc -v 2>&1 | grep -o -- '--enable-default-pie'

# =====================================================================
hr "1. STEP 1 : with 'static', compiled WITHOUT -no-pie (default = PIE)"
# =====================================================================
echo "\$ gcc -Wall -Wextra -o q1_static q1_static.c"
gcc -Wall -Wextra -o "$WORK/q1_static" q1_static.c
echo "(exit status = $?)"
echo
run3 "./q1_static" "$WORK/q1_static"

# =====================================================================
hr "2. STEP 2-3 : 'static' deleted, compiled WITHOUT -no-pie (default = PIE)"
# =====================================================================
echo "\$ gcc -Wall -Wextra -o q1_auto q1_auto.c"
gcc -Wall -Wextra -o "$WORK/q1_auto" q1_auto.c
echo "(exit status = $?)"
echo
run3 "./q1_auto" "$WORK/q1_auto"

# =====================================================================
hr "3. STEP 4 : the very same two programs rebuilt with -no-pie"
# =====================================================================
echo "\$ gcc -no-pie -Wall -Wextra -o q1_static_nopie q1_static.c"
gcc -no-pie -Wall -Wextra -o "$WORK/q1_static_nopie" q1_static.c
echo "\$ gcc -no-pie -Wall -Wextra -o q1_auto_nopie   q1_auto.c"
gcc -no-pie -Wall -Wextra -o "$WORK/q1_auto_nopie" q1_auto.c
echo

sub "3.1 static + -no-pie"
run3 "./q1_static_nopie" "$WORK/q1_static_nopie"

sub "3.2 no static + -no-pie"
run3 "./q1_auto_nopie" "$WORK/q1_auto_nopie"

# =====================================================================
hr "4. Evidence : where does each 'y' actually live?"
# =====================================================================
sub "4.1 ELF type of the four binaries"
echo "\$ file q1_static q1_auto q1_static_nopie q1_auto_nopie"
file "$WORK/q1_static" "$WORK/q1_auto" "$WORK/q1_static_nopie" "$WORK/q1_auto_nopie" \
  | sed -e "s#$WORK/##" -e 's/, BuildID.*//'

sub "4.2 symbol table : the static y has a name and an address, the auto y does not"
echo "\$ nm q1_static_nopie | grep -i ' y'          # 'D' = initialised data section"
nm "$WORK/q1_static_nopie" | grep -i ' y'
echo "\$ nm q1_static       | grep -i ' y'          # PIE: same symbol, address = file offset"
nm "$WORK/q1_static" | grep -i ' y'
echo "\$ nm q1_auto_nopie   | grep -i ' y'          # nothing: the auto y is a stack slot"
nm "$WORK/q1_auto_nopie" | grep -i ' y'
echo "(exit status = $?   -> 1 means grep found no symbol named y)"

sub "4.3 the .data section that holds the static y"
echo "\$ readelf -S q1_static_nopie | grep -A1 ' .data '"
readelf -S "$WORK/q1_static_nopie" | grep -A1 ' \.data '
echo
echo "\$ readelf -h q1_static_nopie | grep -E 'Type|Entry'"
readelf -h "$WORK/q1_static_nopie" | grep -E 'Type|Entry'
echo "\$ readelf -h q1_static       | grep -E 'Type|Entry'"
readelf -h "$WORK/q1_static" | grep -E 'Type|Entry'

sub "4.4 same PIE binaries run with ASLR switched off (setarch -R)"
echo "\$ setarch -R ./q1_static | grep address        # run 1, 2, 3"
for i in 1 2 3; do setarch -R "$WORK/q1_static" | grep address | head -1; done
echo
echo "\$ setarch -R ./q1_auto   | grep address        # run 1, 2, 3"
for i in 1 2 3; do setarch -R "$WORK/q1_auto" | grep address | head -1; done

sub "4.5 PIE: printed address = (random load base) + (fixed offset from the symbol table)"
SYMOFF=$(nm "$WORK/q1_static" | awk '/ [dDbB] y/{print $1}')
echo "offset of y inside the file (from nm) = 0x$SYMOFF"
echo "\$ ./q1_static | head -2        # run 1, 2, 3   ->  base = printed address - offset"
for i in 1 2 3; do
  ADDR=$("$WORK/q1_static" | awk '/address/{print $6; exit}')
  printf 'printed &y = %s    load base = 0x%x\n' "$ADDR" $(( ADDR - 0x$SYMOFF ))
done
echo
SYMOFF_NP=$(nm "$WORK/q1_static_nopie" | awk '/ [dDbB] y/{print $1}')
echo "link-time address of y in the no-pie binary (from nm) = 0x$SYMOFF_NP"
echo "\$ ./q1_static_nopie | head -2  # run 1, 2, 3   ->  base = 0, address is the link-time one"
for i in 1 2 3; do
  ADDR=$("$WORK/q1_static_nopie" | awk '/address/{print $6; exit}')
  printf 'printed &y = %s    load base = 0x%x\n' "$ADDR" $(( ADDR - 0x$SYMOFF_NP ))
done

sub "4.6 the address printed by the auto version is really a stack address"
echo "(ASLR switched off with setarch -R so that the numbers can be compared directly)"
echo "\$ setarch -R ./q1_auto | grep address | head -1"
setarch -R "$WORK/q1_auto" | grep address | head -1
echo "\$ setarch -R bash -c 'grep \[stack\] /proc/self/maps'"
setarch -R bash -c 'grep "\[stack\]" /proc/self/maps'
echo "\$ setarch -R ./q1_static | grep address | head -1     # for comparison: not on the stack"
setarch -R "$WORK/q1_static" | grep address | head -1

hr "END OF Q1"
