#!/bin/bash
# =====================================================================
#  CPE 333 PS03 - Q5 : เก็บผลการรันโปรแกรมจำลอง STCF
#  ใช้งาน :  bash run_q5.sh > ../result/q5_verified.txt 2>&1
#
#  สคริปต์นี้คอมไพล์ PS3.c แล้วคัดลอกทั้งไฟล์ที่ได้และไฟล์ .csv ไปไว้ในโฟลเดอร์
#  เดียวกันตามที่โจทย์กำหนด จากนั้นรันทีละเคส และเทียบผลกับตารางเวลาที่คำนวณ
#  ด้วยมือไว้ล่วงหน้า เพื่อยืนยันว่าโปรแกรมให้คำตอบตรงกับที่วิเคราะห์ไว้
# =====================================================================
exec 2>&1
cd "$(dirname "$0")" || exit 1

WORK=/tmp/ps03_q5
rm -rf $WORK && mkdir -p $WORK

sub(){ echo; echo "----- $* -----"; }

# ตารางเวลาที่คำนวณด้วยมือจากกฎของ STCF (ใช้เป็นเฉลยสำหรับตรวจคำตอบ)
cat > $WORK/expect1.txt <<'EOF'
[0-2]: P1
[2-4]: P2
[4-5]: P3
[5-7]: P2
[7-12]: P1
EOF
cat > $WORK/expect2.txt <<'EOF'
[0-2]: P1
[2-5]: IDLE
[5-6]: P2
[6-7]: P4
[7-9]: P2
[9-12]: P3
EOF
cat > $WORK/expect3.txt <<'EOF'
[0-3]: P2
[3-5]: P1
[5-7]: P2
[7-8]: P3
EOF

echo "# ผลการรันจริง - CPE333 PS03 ข้อ 5 (STCF scheduler simulation)"
echo "# Environment : $(lsb_release -ds 2>/dev/null), kernel $(uname -r)"
echo "# Compiler    : $(gcc --version | head -1)"
echo "# Captured at : $(date '+%Y-%m-%d %H:%M:%S %Z')"

sub "5.0 คอมไพล์"
echo '$ gcc -Wall -Wextra -o PS3 PS3.c'
gcc -Wall -Wextra -o $WORK/PS3 PS3.c && echo "=> OK, no warning"

# วางไฟล์ .csv ไว้โฟลเดอร์เดียวกับไฟล์ที่รันได้ ตามที่โจทย์กำหนด
cp ../material/case1.csv ../material/case2.csv ../material/case3.csv $WORK/

sub "5.1 ข้อมูลเข้าทั้งสามเคส"
for c in 1 2 3; do
    echo "\$ cat case$c.csv"
    cat $WORK/case$c.csv
    echo
done

cd $WORK || exit 1

for c in 1 2 3; do
    sub "5.2.$c ผลการรัน case$c.csv"
    echo "\$ ./PS3 case$c.csv"
    ./PS3 case$c.csv | tee out$c.txt

    echo
    echo "# compare with the timeline worked out by hand"
    echo "\$ diff out$c.txt expect$c.txt"
    if diff out$c.txt expect$c.txt; then
        echo "=> identical, the program agrees with the hand analysis"
    else
        echo "=> MISMATCH"
    fi
done

sub "5.3 กรณีขอบ: เรียกโปรแกรมผิดวิธีและไฟล์ที่ใช้ไม่ได้"
echo '$ ./PS3'
./PS3
echo "exit status = $?"
echo
echo '$ ./PS3 nosuchfile.csv'
./PS3 nosuchfile.csv
echo "exit status = $?"
echo
: > empty.csv
echo '$ ./PS3 empty.csv          # a completely empty file'
./PS3 empty.csv
echo "exit status = $?"
echo
printf 'pid,arrival,burst
' > header.csv
echo '$ ./PS3 header.csv         # header row only, no process at all'
./PS3 header.csv
echo "exit status = $?  (no process to schedule, so nothing is printed)"

cd /tmp || exit 1
rm -rf $WORK
echo
echo "=== จบการเก็บผลข้อ 5 ==="
