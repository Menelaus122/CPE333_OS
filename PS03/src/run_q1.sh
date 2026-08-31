#!/bin/bash
# =====================================================================
#  CPE 333 PS03 - Q1 : เก็บผลการทดลองคำสั่ง ps / top / nice / renice / kill
#  ใช้งาน :  bash run_q1.sh > ../result/q1_verified.txt 2>&1
#  ต้องรันบน Linux (หรือ WSL) และมีคำสั่ง taskset, renice, killall, script
# =====================================================================
cd "$(dirname "$0")" || exit 1
export COLUMNS=120 LINES=40

# ทำให้ข้อความแจ้ง job ของ bash ขึ้นต้นด้วย "bash:" เหมือนตอนพิมพ์ใน terminal จริง
exec > >(sed -E "s#^.*run_q1\.sh: line [0-9]+:#bash:#") 2>&1

mkdir -p /tmp/ps03_q1

hr(){ echo; echo "===================================================================="; echo "$*"; echo "===================================================================="; }
sub(){ echo; echo "----- $* -----"; }

# รันสคริปต์ย่อยผ่าน pseudo terminal เพื่อให้ job control ทำงานได้เหมือน terminal จริง
pty(){ script -qec "bash $1" /dev/null | sed -e 's/\r$//' -e "s#^$1: line [0-9]*:#bash:#"; }

# ---- สคริปต์ย่อยสำหรับหัวข้อ 3.5 : job spec %n -------------------------
# ต้องแยกเป็นไฟล์ต่างหาก เพื่อให้ bash นับเลข job เริ่มจาก [1] เหมือน terminal ใหม่
cat > /tmp/ps03_q1/jobs.sh <<'EOF'
set -m
set -b
sleep 400 &
sleep 500 &
sleep 600 &
sleep 0.3
echo '$ jobs -l'
jobs -l
echo '$ kill %2            # send SIGTERM to job number 2'
kill %2 ; sleep 0.5
echo '$ jobs -l'
jobs -l
echo '$ kill -9 %1 %3      # kill the two remaining jobs'
kill -9 %1 %3 ; sleep 0.5
echo '$ jobs -l            # no output = no job left'
jobs -l
EOF

# ---- สคริปต์ย่อยสำหรับหัวข้อ 3.6 : pgrep / pkill / killall ------------
# ต้องแยกเป็นไฟล์ต่างหากด้วย ไม่เช่นนั้น pkill -f 'sleep 700'
# จะไปตรงกับ command line ของ shell ที่รันสคริปต์เอง แล้วฆ่าตัวเองทิ้ง
cat > /tmp/ps03_q1/pkill.sh <<'EOF'
set -m
set -b
sleep 700 & sleep 700 & sleep 700 &
sleep 0.3
echo '$ pgrep -a sleep'
pgrep -a sleep
echo "\$ pkill -f 'sleep 700'      # kill every process whose full command line matches"
pkill -f "sleep 700" ; sleep 0.5
echo '$ pgrep -a sleep'
pgrep -a sleep ; echo "exit status of pgrep = $?   (1 = nothing matched)"
echo
/tmp/ps03_q1/q1_sigdemo > /dev/null & /tmp/ps03_q1/q1_sigdemo > /dev/null &
sleep 0.3
echo '$ pgrep -a q1_sigdemo'
pgrep -a q1_sigdemo
echo '$ killall -9 q1_sigdemo      # kill by exact program name'
killall -9 q1_sigdemo ; sleep 0.5
echo '$ pgrep -a q1_sigdemo'
pgrep -a q1_sigdemo ; echo "exit status of pgrep = $?"
EOF

echo "# ผลการรันจริง - CPE333 PS03 ข้อ 1 (Linux commands for process manipulation & monitoring)"
echo "# Environment : $(lsb_release -ds 2>/dev/null), kernel $(uname -r)"
echo "# Tools       : $(ps --version 2>&1 | sed 's/^ps from //') (ps/top/kill/pgrep/pkill), util-linux (renice/taskset), psmisc (killall)"
echo "# Captured at : $(date '+%Y-%m-%d %H:%M:%S %Z')"

sub "0. คอมไพล์โปรแกรมช่วยทดลอง"
gcc -Wall -Wextra -O0 -o /tmp/ps03_q1/q1_burn q1_burn.c && echo '$ gcc -Wall -Wextra -O0 -o q1_burn q1_burn.c      => OK, no warning'
gcc -Wall -Wextra      -o /tmp/ps03_q1/q1_sigdemo q1_sigdemo.c && echo '$ gcc -Wall -Wextra -o q1_sigdemo q1_sigdemo.c   => OK, no warning'

hr "ส่วนที่ 1 : ps เทียบกับ top"

sub "1.0 สภาพแวดล้อม"
uname -srm
lsb_release -ds
echo "nproc = $(nproc) logical CPUs"
ps --version

sub "1.1 ps (ไม่ใส่ option) - เห็นเฉพาะ process ของ terminal ตัวเองเท่านั้น"
echo '$ ps'
ps

sub "1.2 ps aux | head -8   (BSD syntax : ทุก process ในระบบ)"
echo '$ ps aux | head -8'
ps aux | head -8

sub "1.3 ps -ef | head -8   (UNIX syntax : มีคอลัมน์ PPID ให้เห็นความเป็นพ่อลูก)"
echo '$ ps -ef | head -8'
ps -ef | head -8

# สร้างภาระงานจริงไว้เป็นเป้าให้ ps และ top มองเห็น
taskset -c 0 /tmp/ps03_q1/q1_burn 30 MONITOR_ME &  bpid=$!
sleep 2

sub "1.4 ps -eo ... --sort=-%cpu   (เลือกคอลัมน์เองและเรียงลำดับได้)"
echo '$ taskset -c 0 ./q1_burn 30 MONITOR_ME &      # a CPU-hungry process to watch'
echo '$ ps -eo pid,ppid,ni,pri,stat,%cpu,%mem,etime,comm --sort=-%cpu | head -6'
ps -eo pid,ppid,ni,pri,stat,%cpu,%mem,etime,comm --sort=-%cpu | head -6

sub "1.5 ps เป็นภาพนิ่งครั้งเดียว (one-shot snapshot) จึงจบทันที"
echo '$ /usr/bin/time -f "real %e s" ps aux > /dev/null'
/usr/bin/time -f "real %e s" ps aux > /dev/null
echo "\$ ps -e --no-headers | wc -l"; ps -e --no-headers | wc -l

sub "1.6 top -b -n 1   (batch mode ถ่ายภาพครั้งเดียวเพื่อเก็บลงรายงาน)"
echo '$ top -b -n 1 | head -13'
top -b -n 1 -w 120 | head -13

sub "1.7 top -b -n 2 -d 1   (สองภาพห่างกัน 1 วินาที : top คำนวณ %CPU ใหม่ทุกรอบ)"
echo '$ top -b -n 2 -d 1 | grep -E "^top -|^Tasks|^%Cpu|q1_burn"'
top -b -n 2 -d 1 -w 120 | grep -E "^top -|^Tasks|^%Cpu|q1_burn"
kill -9 $bpid 2>/dev/null ; wait $bpid 2>/dev/null

hr "ส่วนที่ 2 : คำสั่ง nice และ renice"

sub "2.1 ค่า nice ตั้งต้นของ process ใหม่ และการสั่ง nice"
echo -n '$ nice                                  ->  '; nice
echo -n '$ nice -n 10 nice                       ->  '; nice -n 10 nice
echo -n '$ nice -n 19 nice                       ->  '; nice -n 19 nice
echo -n '$ nice -n 5 nice -n 5 nice   (increments add up)  ->  '; nice -n 5 nice -n 5 nice

sub "2.2 กรณีควบคุม : burner 2 ตัว ค่า nice เท่ากัน (0 กับ 0) ผูกไว้ที่ CPU 0 ทั้งคู่ นาน 15 วินาที"
echo '$ taskset -c 0 ./q1_burn 15 A_nice0 &'
echo '$ taskset -c 0 ./q1_burn 15 B_nice0 &'
taskset -c 0 /tmp/ps03_q1/q1_burn 15 A_nice0  &  pa=$!
taskset -c 0 /tmp/ps03_q1/q1_burn 15 B_nice0  &  pb=$!
sleep 4
echo '$ ps -o pid,ni,pri,psr,stat,%cpu,time,args -p <pid1>,<pid2>      # while both are running'
ps -o pid,ni,pri,psr,stat,%cpu,time,args -p $pa,$pb
wait $pa $pb

sub "2.3 กรณีทดลอง : burner 2 ตัว ค่า nice ต่างกัน (0 กับ 19) ผูกไว้ที่ CPU 0 ทั้งคู่ นาน 15 วินาที"
echo '$ taskset -c 0            ./q1_burn 15 HIGH_nice0 &'
echo '$ taskset -c 0 nice -n 19 ./q1_burn 15 LOW_nice19 &'
taskset -c 0            /tmp/ps03_q1/q1_burn 15 HIGH_nice0   &  ph=$!
taskset -c 0 nice -n 19 /tmp/ps03_q1/q1_burn 15 LOW_nice19   &  pl=$!
sleep 4
echo '$ ps -o pid,ni,pri,psr,stat,%cpu,time,args -p <pid1>,<pid2>      # while both are running'
ps -o pid,ni,pri,psr,stat,%cpu,time,args -p $ph,$pl
echo '$ top -b -n 1 -p <pid1> -p <pid2>'
top -b -n 1 -w 120 -p $ph -p $pl | tail -4
wait $ph $pl

sub "2.4 renice : เปลี่ยนค่า nice ของ process ที่กำลังรันอยู่แล้ว"
taskset -c 0 /tmp/ps03_q1/q1_burn 12 renice_target & pr=$!
sleep 1
echo '$ ps -o pid,ni,pri,stat,comm -p <pid>        # before renice'
ps -o pid,ni,pri,stat,comm -p $pr
echo "\$ renice -n 15 -p $pr"
renice -n 15 -p $pr
echo '$ ps -o pid,ni,pri,stat,comm -p <pid>        # after renice'
ps -o pid,ni,pri,stat,comm -p $pr
wait $pr

sub "2.5 เฉพาะ root เท่านั้นที่ลดค่า nice (คือเพิ่ม priority) ได้"
echo "current user : $(id -un)  (uid=$(id -u))"
echo '$ nice -n -5 nice'
nice -n -5 nice
sleep 60 & p=$!
echo "\$ sleep 60 &        -> pid $p"
echo "\$ renice -n -5 -p $p"
renice -n -5 -p $p
echo "exit status = $?"
echo "\$ renice -n +8 -p $p        # raising the nice value is always allowed"
renice -n 8 -p $p
ps -o pid,ni,pri,stat,comm -p $p
echo "\$ renice -n 0 -p $p         # lowering it back is refused, even for our own process"
renice -n 0 -p $p
echo "exit status = $?"
kill -9 $p 2>/dev/null ; wait $p 2>/dev/null

hr "ส่วนที่ 3 : การ kill process และ job"

sub "3.1 kill -l : รายชื่อสัญญาณทั้งหมดที่ส่งได้"
echo '$ kill -l'
kill -l

sub "3.2 kill <PID> : สัญญาณตั้งต้นคือ SIGTERM (15)"
sleep 300 & p=$!
echo "\$ sleep 300 &        -> pid $p"
ps -o pid,ppid,stat,comm -p $p
echo "\$ kill $p"
kill $p ; sleep 0.5
echo "\$ ps -o pid,stat,comm -p $p        # no data row = the process is gone"
ps -o pid,stat,comm -p $p ; echo "exit status of ps = $?"
wait $p 2>/dev/null

sub "3.3 process ที่ดักจับ SIGTERM ไว้ : kill เฉย ๆ ไม่พอ ต้องใช้ kill -9"
/tmp/ps03_q1/q1_sigdemo & s=$!
sleep 0.5
echo "\$ kill $s            # SIGTERM -> the handler runs, the process survives"
kill $s ; sleep 0.5
echo "\$ kill -INT $s       # SIGINT  -> the handler runs, the process survives"
kill -INT $s ; sleep 0.5
echo "\$ ps -o pid,stat,comm -p $s"
ps -o pid,stat,comm -p $s
echo "\$ kill -9 $s         # SIGKILL can be neither caught nor ignored"
kill -9 $s ; sleep 0.5
echo "\$ ps -o pid,stat,comm -p $s"
ps -o pid,stat,comm -p $s ; echo "exit status of ps = $?"
wait $s 2>/dev/null

sub "3.4 kill -STOP / kill -CONT : พักและปลุก process แทนการฆ่า"
sleep 300 & q=$!
sleep 0.3
echo "\$ ps -o pid,stat,comm -p $q        # S = sleeping"
ps -o pid,stat,comm -p $q
echo "\$ kill -STOP $q"
kill -STOP $q ; sleep 0.3
echo "\$ ps -o pid,stat,comm -p $q        # T = stopped"
ps -o pid,stat,comm -p $q
echo "\$ kill -CONT $q"
kill -CONT $q ; sleep 0.3
echo "\$ ps -o pid,stat,comm -p $q        # back to S again"
ps -o pid,stat,comm -p $q
kill -9 $q 2>/dev/null ; wait $q 2>/dev/null

sub "3.5 การฆ่า JOB ด้วย job spec %n"
pty /tmp/ps03_q1/jobs.sh

sub "3.6 pgrep / pkill / killall : อ้างถึง process ด้วยชื่อแทน PID"
pty /tmp/ps03_q1/pkill.sh

sub "3.7 kill -0 : ถามว่า PID นั้นยังมีอยู่ไหม โดยไม่ส่งสัญญาณจริง"
sleep 300 & r=$!
kill -0 $r && echo "\$ kill -0 $r   -> pid $r is alive (exit status 0)"
kill $r ; sleep 0.5
kill -0 $r 2>/dev/null || echo "\$ kill -0 $r   -> bash: kill: ($r) - No such process (exit status 1)"
wait $r 2>/dev/null

rm -rf /tmp/ps03_q1
echo
echo "=== จบการเก็บผลข้อ 1 ==="
