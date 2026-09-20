# PS06 — คำสั่งที่ต้องพิมพ์เองใน terminal และภาพหน้าจอที่ต้องถ่าย

เอกสารนี้ไม่ใช่รายงาน แต่เป็น script การทำงานร่วมกัน: **คุณพิมพ์คำสั่งใน terminal เอง**
แล้วพิมพ์ชื่อภาพ (เช่น `s03`) มาในแชต → Claude จะถ่ายภาพหน้าต่างนั้นให้ เซฟลง
`PS06/result/screenshots/` ตัดขอบภาพด้วย `PS06/tools/crop_shot.ps1` แล้วเปิดดูเพื่อยืนยันว่าภาพใช้ได้ก่อนไปขั้นถัดไป

## เตรียมตัวก่อนเริ่ม

1. เปิด **Windows Terminal → Ubuntu (WSL)** ให้หน้าต่างอยู่หน้าสุด (ไม่ต้อง maximize ก็ได้
   แต่อย่าให้หน้าต่างอื่นทับ)
2. ขยาย font ให้ใหญ่พอ: กด `Ctrl` + `Shift` + `+` ประมาณ 2–3 ครั้ง (ราว 14–16 pt)
   เพราะภาพจะถูกย่อลงเมื่อนำไปวางในรายงาน ถ้า font เล็กจะอ่านไม่ออก
3. พิมพ์ `clear` ก่อนทุกครั้งที่จะถ่ายภาพใหม่ เพื่อให้ในภาพเห็นเฉพาะคำสั่งของขั้นนั้น
4. ถ้าเจอปัญหา/error ให้พิมพ์ `err <ข้อความ>` มาในแชต Claude จะบันทึกไว้ใน
   `PS06/result/notes.txt` และเขียนเป็นหัวข้อ "ปัญหาที่พบ" ในรายงาน

> คำสั่งที่ขึ้นต้นด้วย `sudo` จะถาม password ของ Ubuntu — พิมพ์ในหน้าต่าง terminal เท่านั้น
> ไม่ต้องพิมพ์ password มาในแชต (ตอนพิมพ์ password จะไม่มีตัวอักษรแสดงบนหน้าจอ ถือว่าปกติ)

---

## ข้อ 1.2 — เพิ่มและลด swap space บน Linux (ภาพ s01–s09)

### s01 — ดูสถานะ swap เดิมก่อนแก้ไข

```bash
clear; free -h; echo; swapon --show; echo; cat /proc/swaps
```

ต้องเห็น: `Swap: 4.0Gi` และ swap เดิมเป็น partition `/dev/sdc`

### s02 — สร้าง file สำหรับใช้เป็น swap ขนาด 2 GiB

```bash
clear; sudo fallocate -l 2G /swapfile; ls -lh /swapfile
```

ต้องเห็น: file `/swapfile` ขนาด `2.0G`
(ถ้า `fallocate` ใช้ไม่ได้ ให้ใช้ `sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress` แทน)

### s03 — ตั้งสิทธิ์ให้ปลอดภัยและ format เป็น swap area

```bash
clear; sudo chmod 600 /swapfile; ls -lh /swapfile; sudo mkswap /swapfile
```

ต้องเห็น: สิทธิ์เปลี่ยนเป็น `-rw-------` และข้อความ `Setting up swapspace version 1` พร้อม UUID

### s04 — เปิดใช้งาน swap file

```bash
clear; sudo swapon /swapfile; swapon --show; cat /proc/swaps
```

ต้องเห็น: มีสองบรรทัดคือ `/dev/sdc` (partition) และ `/swapfile` (file)

### s05 — ยืนยันว่า swap เพิ่มขึ้นจริง

```bash
clear; free -h; free -h --si
```

ต้องเห็น: `Swap` total เปลี่ยนจาก `4.0Gi` เป็น `6.0Gi`

### s06 — ทำให้ถาวร (เพิ่มบรรทัดใน /etc/fstab)

```bash
clear; echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab; sudo systemctl daemon-reload; systemctl --no-pager list-units --type=swap
```

ผลที่ได้จริง: บรรทัด `/swapfile none swap sw 0 0` เข้า `/etc/fstab` สำเร็จ แต่ systemd ตอบ
`0 loaded units listed` คือ **ไม่สร้าง swap unit ให้** ซึ่งเป็นพฤติกรรมเฉพาะของ WSL2
(ดูสาเหตุในขั้น s06b)

### s06b — ทำไม systemd ถึงไม่รับ swap entry บน WSL2 (หลักฐานของสาเหตุ)

```bash
clear; systemd-detect-virt --container; journalctl -b --no-pager | grep -i "ignoring swap entry"; sudo swapoff /swapfile; swapon --show; sudo swapon -a; swapon --show
```

ต้องเห็น:

- `systemd-detect-virt --container` ตอบ `wsl` คือ systemd มองว่ากำลังทำงานอยู่ใน container
- บรรทัดจาก journal: `systemd-fstab-generator: Running in a container, ignoring swap entry for /swapfile`
- หลัง `swapoff` เหลือ swap เดียว แล้วพอสั่ง `swapon -a` ซึ่งอ่าน `/etc/fstab` โดยตรง
  `/swapfile` กลับมาอีกครั้ง แปลว่าบรรทัดใน fstab ถูกต้อง แต่ตัว systemd ต่างหากที่ข้ามมันไป

### s07 — ลด swap: ปิดการใช้งาน swap file

```bash
clear; sudo swapoff /swapfile; swapon --show; free -h
```

ต้องเห็น: เหลือแค่ `/dev/sdc` และ `Swap` total กลับเป็น `4.0Gi`

### s08 — ลบ file และคืนค่า /etc/fstab ให้เหมือนเดิม

```bash
clear; sudo sed -i '\|^/swapfile|d' /etc/fstab; sudo rm -f /swapfile; cat /etc/fstab; ls -lh /swapfile; free -h
```

ต้องเห็น: `/etc/fstab` ไม่มีบรรทัด swapfile แล้ว, `ls` ฟ้อง `No such file or directory`
(ถือว่าถูกต้อง) และ `Swap: 4.0Gi`

### s09 — ปรับ vm.swappiness (แนวโน้มที่ kernel จะย้าย page ลง swap)

```bash
clear; cat /proc/sys/vm/swappiness; sudo sysctl vm.swappiness=10; cat /proc/sys/vm/swappiness; sudo sysctl vm.swappiness=60; cat /proc/sys/vm/swappiness
```

ต้องเห็น: `60` → `10` → `60` (ตั้งค่าถาวรทำได้โดยเพิ่ม `vm.swappiness=10` ใน `/etc/sysctl.conf`)

---

## ตารางเช็กลิสต์ภาพ

| ชื่อภาพ | ชื่อ file ที่จะเซฟ | สถานะ |
|---|---|---|
| s01 | `s01_swap_baseline.png` | ✔ |
| s02 | `s02_fallocate.png` | ✔ |
| s03 | `s03_mkswap.png` | ✔ |
| s04 | `s04_swapon.png` | ✔ |
| s05 | `s05_free_after_add.png` | ✔ |
| s06 | `s06_fstab.png` | ✔ |
| s06b | `s06b_container_ignored.png` | ✔ |
| s07 | `s07_swapoff.png` | ✔ |
| s08 | `s08_cleanup.png` | ✔ |
| s09 | `s09_swappiness.png` | ✔ |
