#!/bin/bash
# =====================================================================
#  CPE 333 PS03 - Q2 : เก็บผลการทดลอง foreground / background / CTRL+Z / fg / bg
#  ใช้งาน :  bash run_q2.sh > ../result/q2_verified.txt 2>&1
#
#  ข้อนี้ต้องใช้ terminal จริงเพราะ CTRL+Z และคำสั่ง jobs/fg/bg ทำงานได้ก็ต่อเมื่อ
#  shell มี job control ซึ่งเปิดเฉพาะตอนที่ shell เป็น interactive และมี tty
#  สคริปต์นี้จึงสร้าง pseudo terminal ด้วย script(1) แล้วป้อนคำสั่งเข้าไปทีละบรรทัด
#  โดยเว้นจังหวะให้เหมือนคนพิมพ์จริง ส่วน CTRL+Z ส่งเป็นไบต์ 0x1A (\032) ตรง ๆ
# =====================================================================
cd "$(dirname "$0")" || exit 1

WORK=/tmp/ps03_q2
rm -rf $WORK && mkdir -p $WORK
cp ss1_1.sh ss1_2.sh $WORK/
chmod 644 $WORK/ss1_1.sh $WORK/ss1_2.sh   # ตั้งใจไม่ให้รันได้ เพื่อสาธิต chmod

hr(){ echo; echo "===================================================================="; echo "$*"; echo "===================================================================="; }

# ลบรหัสควบคุมของ terminal (สี, ชื่อหน้าต่าง, bracketed paste) ออกจาก transcript
clean(){ perl -pe 's/\r$//; s/\e\[[0-9;?]*[a-zA-Z]//g; s/\e\][^\a]*\a//g; s/\e[=>]//g'; }

# เปิด interactive bash บน pseudo terminal แล้วรับคำสั่งจาก stdin
session(){ ( cd $WORK && script -q -c "bash --norc -i" /dev/null ) | clean; }

Z=$'\032'          # ไบต์ที่ terminal ตีความว่าเป็น CTRL+Z
PROMPT="export PS1='student@ubuntu:~/PS03\$ '"

echo "# ผลการรันจริง - CPE333 PS03 ข้อ 2 (foreground / background / job control)"
echo "# Environment : $(lsb_release -ds 2>/dev/null), kernel $(uname -r)"
echo "# Shell       : $(bash --version | head -1)"
echo "# Captured at : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "#"
echo "# transcript ด้านล่างเก็บจาก interactive bash บน pseudo terminal จริง"
echo "# บรรทัด ^Z คือการกด CTRL+Z"

# =====================================================================
hr "สถานการณ์ที่ 1 : ./ss1_1.sh เทียบกับ ./ss1_1.sh &"
# =====================================================================

echo
echo "----- 1.1 เนื้อหาของ ss1_1.sh -----"
cat -n ss1_1.sh

echo
echo "----- 1.2 transcript ของ terminal -----"
{
  sleep 1.0; echo "$PROMPT"
  sleep 0.4; echo 'ls -l ss1_1.sh'
  sleep 0.4; echo './ss1_1.sh'
  sleep 0.6; echo 'chmod +x ss1_1.sh'
  sleep 0.4; echo 'ls -l ss1_1.sh'

  # เตรียม ps ไว้ถ่ายภาพตอนที่สคริปต์กำลังรันแบบ foreground
  sleep 0.5; echo '(sleep 4; ps -o pid,ppid,pgid,tpgid,stat,args > /tmp/ps03_q2/fg1.txt 2>&1) &'
  sleep 0.6; echo 'date +%T ; time ./ss1_1.sh ; date +%T'
  sleep 13.0; echo 'cat /tmp/ps03_q2/fg1.txt'

  sleep 0.8; echo 'date +%T ; ./ss1_1.sh & date +%T'
  sleep 0.6; echo 'jobs -l'
  sleep 0.4; echo 'ps -o pid,ppid,pgid,tpgid,stat,args'
  sleep 0.6; echo 'echo "the shell is free while the job runs: 2+2 = $((2+2))"'
  sleep 0.4; echo 'wait'
  sleep 12.0; echo 'jobs -l'
  sleep 0.6; echo 'exit'
  sleep 0.5
} | session

# =====================================================================
hr "สถานการณ์ที่ 2 : CTRL+Z, jobs, fg และ bg"
# =====================================================================

echo
echo "----- 2.1 เนื้อหาของ ss1_2.sh -----"
cat -n ss1_2.sh

echo
echo "----- 2.2 transcript ของ terminal -----"
{
  sleep 1.0; echo "$PROMPT"
  sleep 0.4; echo 'chmod +x ss1_2.sh'
  sleep 0.4; echo './ss1_2.sh'
  sleep 2.0; printf '%s' "$Z"                 # <<< CTRL+Z
  sleep 1.0; echo 'jobs -l'
  sleep 0.5; echo 'ps -o pid,ppid,pgid,tpgid,stat,args'
  sleep 0.7; echo 'bg %1'
  sleep 0.8; echo 'jobs -l'
  sleep 0.5; echo 'ps -o pid,ppid,pgid,tpgid,stat,args'
  sleep 0.7; echo 'echo "the shell still answers while %1 runs in the background"'

  # เตรียม ps ไว้ถ่ายภาพตอนที่ job ถูกดึงกลับมาเป็น foreground
  sleep 0.5; echo '(sleep 2; ps -o pid,ppid,pgid,tpgid,stat,args > /tmp/ps03_q2/fg2.txt 2>&1) &'
  sleep 0.6; echo 'fg %1'
  sleep 4.0; printf '%s' "$Z"                 # <<< CTRL+Z อีกครั้ง
  sleep 1.0; echo 'jobs -l'
  sleep 0.5; echo 'cat /tmp/ps03_q2/fg2.txt'

  sleep 0.7; echo 'kill %1'
  sleep 1.0; echo 'jobs -l'
  sleep 0.6; echo 'jobs -l'

  # งานที่ต้องรับ input จากคีย์บอร์ด จะถูกหยุดเองถ้าอยู่เบื้องหลัง (SIGTTIN)
  # จึงเป็นกรณีที่ bg ใช้ไม่ได้ ต้อง fg เท่านั้น
  sleep 0.6; echo '( read -p "type your name: " n ; echo "[bgread] you typed: $n" ) &'
  sleep 1.2; echo 'jobs -l'
  sleep 0.6; echo 'bg %1'
  sleep 1.0; echo 'jobs -l'
  sleep 0.6; echo 'fg %1'
  sleep 1.2; echo 'CPE333'
  sleep 1.0; echo 'jobs -l'
  sleep 0.6; echo 'exit'
  sleep 0.5
} | session

rm -rf $WORK
echo
echo "=== จบการเก็บผลข้อ 2 ==="
