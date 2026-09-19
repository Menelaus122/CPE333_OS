# Mini-Project 1 : คำสั่งที่ต้องทำใน VM ตามลำดับ

เอกสารนี้เป็นคู่มือปฏิบัติงานของกลุ่ม ทำตามทีละ Phase ห้ามข้าม **หลักฐานทั้งหมดคือภาพหน้าจอจริง** ไม่มีการพิมพ์ผลลัพธ์ลงรายงานเอง รายงาน `.docx` จะเขียนตอนท้ายจากภาพในโฟลเดอร์ `result/screenshots/` เท่านั้น

## วิธีเก็บภาพหลักฐาน (Claude เป็นคนถ่าย)

- เราพิมพ์คำสั่งใน VM เอง เมื่อถึงจุด 📸 ให้ **ส่งชื่อภาพ เช่น `s07` ใน Claude Code** แล้ว **รอให้ Claude ตอบว่าภาพผ่าน** ก่อนทำขั้นต่อไป
- Claude จะดึงหน้าต่าง VMware ขึ้นมาด้านหน้า ถ่ายทั้งบาน (เห็นชื่อ VM `CPE333-kernel` บนแถบชื่อ และนาฬิกาของ Ubuntu) ตรวจว่าภาพอ่านออกและแสดงผลที่ต้องการ แล้วบันทึกลง `result/screenshots/` ตามชื่อไฟล์ในตารางท้ายเอกสาร ถ้าภาพไม่ผ่านจะบอกว่าต้องรันอะไรใหม่
- เปิดหน้าต่าง VMware แบบปกติหรือ maximize ได้ **ห้ามใช้โหมด Full Screen ของ VMware และห้ามย่อหน้าต่าง (minimize)** ตอนส่งชื่อภาพ
- เปิด terminal ใน Ubuntu ให้เต็มหน้าต่าง และขยายตัวอักษรด้วย `Ctrl+Shift+=` ให้อ่านออกเมื่อย่อลงหน้า A4
- คำสั่งที่เป็นหลักฐาน (มี 📸 ต่อท้าย) ให้ **วางทีละบรรทัดแล้วกด Enter** เพื่อให้ทุกผลลัพธ์มีบรรทัดคำสั่งกำกับอยู่ด้านบน
- คำสั่ง `sed` ให้คัดลอกไปวางทั้งบรรทัด อย่าพิมพ์เอง เพราะมีเครื่องหมาย `\` เยอะ
- ถ้าเจอ error ให้ส่ง `err` พร้อมอธิบายสั้น ๆ Claude จะถ่ายเก็บเป็น `err_*.png` และจดวิธีแก้ลง `result/notes.txt` เพื่อเขียนหัวข้อ "ปัญหาที่พบและวิธีแก้ไข"

| สเปกของ VM | ค่า |
| --- | --- |
| Hypervisor | VMware Workstation 17 Player |
| Guest OS | Ubuntu 24.04 LTS Desktop (amd64) |
| RAM | 12 GB (12288 MB) |
| Disk | 100 GB แบบ dynamic เก็บที่ `C:\Users\Oping\Documents\Virtual Machines\Ubuntu 64-bit` |
| CPU | 12 vCPU |
| Firmware | BIOS (ค่าเริ่มต้นของ Player ไม่มี Secure Boot) |

---

## Phase 1 — สร้าง VM (ฝั่ง Windows)

1. ติดตั้ง **VMware Workstation 17 Player** (ฟรีสำหรับใช้ส่วนตัว)
2. ดาวน์โหลด ISO **Ubuntu 24.04.5.1 LTS Desktop** (รุ่นย่อยล่าสุดของ 24.04 ออกเมื่อ 14 ก.ย. 2569 ขนาด 5.8 GB) จากลิงก์ตรง
   <https://releases.ubuntu.com/24.04/ubuntu-24.04.5.1-desktop-amd64.iso>
   แล้วตรวจว่าไฟล์ไม่เสียด้วย PowerShell ค่าที่ได้ต้องตรงกับ
   `4DA4A0C9035DA8E68A59A838674F403F0A54472C78A83B4FB7F78D03588F85A7`

   ```powershell
   Get-FileHash .\ubuntu-24.04.5.1-desktop-amd64.iso
   ```
3. **Create a New Virtual Machine**
   - เลือก **I will install the operating system later** (เลี่ยง Easy Install ของ VMware)
   - Guest OS: **Linux → Ubuntu 64-bit**
   - Name: `CPE333-kernel`
   - Maximum disk size: **100 GB**
4. **Customize Hardware** (หรือ **Player → Manage → Virtual Machine Settings**)
   - Memory: **12288 MB**
   - Processors: **12** (ช่อง *Number of processor cores*)
   - CD/DVD: **Use ISO image file** → ไฟล์ ISO ที่ดาวน์โหลดมา
5. shared folder ยังเพิ่มไม่ได้ตอนนี้ ต้องรอให้ติดตั้ง Ubuntu และ VMware Tools เสร็จก่อน (ดู Phase 2 ข้อ 2)

Player ไม่มีหน้าตั้งค่า Firmware VM จึงบูตแบบ **BIOS** ซึ่งไม่มี Secure Boot อยู่แล้ว เคอร์เนล `linux-image-unsigned` ที่เราจะ build จึงบูตได้โดยไม่ต้องตั้งอะไรเพิ่ม (จะพิสูจน์ในภาพ `s03`)

เปิด **Virtual Machine Settings** ค้างไว้ที่แท็บ Hardware แล้วส่ง:

📸 `s01_vm_hardware.png` — เห็น Memory 12 GB, Processors 12, Hard Disk 100 GB

แล้วกด **OK** เพื่อบันทึกค่า

---

## Phase 2 — ติดตั้ง Ubuntu และบันทึกสภาพเริ่มต้น

1. บูต VM ติดตั้ง Ubuntu ตามค่าปกติ เลือก **Erase disk and install Ubuntu** (ลบแค่ดิสก์เสมือน 100 GB ของ VM) ตอนตั้งชื่อเครื่องให้ใช้ `cpe333-kernel`
2. หลังล็อกอินครั้งแรก อัปเดตระบบและติดตั้ง VMware Tools (ตอนนี้ยัง copy-paste ไม่ได้ ต้องพิมพ์เอง):

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y open-vm-tools-desktop
sudo reboot
```

   ที่แถบเหลืองของ VMware ให้กด **Remind Me Later** ไม่ต้องกด *Install Tools* หลังรีบูต ที่หน้าล็อกอินให้คลิกชื่อผู้ใช้ แล้วกดเฟือง ⚙ มุมขวาล่าง เลือก **Ubuntu on Xorg** ก่อนใส่รหัสผ่าน เพราะบน Wayland การ copy-paste ระหว่าง Windows กับ VM มักใช้ไม่ได้ วางข้อความใน Terminal ใช้ `Ctrl+Shift+V`

   จากนั้นเพิ่ม shared folder (ต้องทำหลัง VMware Tools ทำงานแล้ว ไม่งั้นปุ่ม Add จะเป็นสีเทา): **Player ▾ → Manage → Virtual Machine Settings → Options → Shared Folders → Always enabled → Add…** → Host path `C:\Users\Oping\CPE333_OS\Miniproj1` ชื่อ `Miniproj1` → Finish → OK

3. ต่อ shared folder ให้เมานต์อัตโนมัติทุกครั้งที่บูต (ทำครั้งเดียว):

```bash
echo ".host:/ /mnt/hgfs fuse.vmhgfs-fuse defaults,allow_other,uid=$(id -u),gid=$(id -g),nofail 0 0" | sudo tee -a /etc/fstab
sudo mkdir -p /mnt/hgfs && sudo systemctl daemon-reload && sudo mount -a
ls /mnt/hgfs/Miniproj1/docs        # ต้องเห็น COMMANDS.md
```

4. บันทึกสภาพเครื่องก่อนเริ่มงาน (วางทีละบรรทัด):

```bash
date
hostnamectl
uname -r
nproc
free -h
lsblk -d -e7 -o NAME,SIZE,MODEL
[ -d /sys/firmware/efi ] && echo "boot mode: UEFI" || echo "boot mode: BIOS (no Secure Boot)"
```

📸 `s03_baseline.png` — ต้องเห็น Ubuntu 24.04, Virtualization: vmware, 12 CPU, RAM ประมาณ 12 GB, ดิสก์ 100G และ `boot mode: BIOS (no Secure Boot)` **จดค่า `uname -r` ไว้** นี่คือเคอร์เนลเดิม

5. (ไม่บังคับ) Player ทำ snapshot ไม่ได้ ถ้าอยากมีจุดกู้คืน ให้ **Shut Down** VM (ไม่ใช่ Suspend) แล้วคัดลอกโฟลเดอร์ VM ทั้งโฟลเดอร์ไปเก็บไว้ ใช้พื้นที่ประมาณ 15–20 GB ใน PowerShell ของ Windows:

   ```powershell
   robocopy "C:\Users\Oping\Documents\Virtual Machines\Ubuntu 64-bit" "D:\VM-backup\01-clean-install" /E
   ```

   ถ้าข้ามขั้นนี้ก็ยังย้อนกลับได้ เพราะ Phase 7 จะแสดงการบูตกลับเคอร์เนลเดิมผ่าน GRUB อยู่แล้ว

---

## Phase 3 — เตรียมเครื่องสำหรับ build

```bash
sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
grep ^Types /etc/apt/sources.list.d/ubuntu.sources
sudo apt update
```

📸 `s04_deb_src.png` — ทุกบรรทัดของ `grep` เป็น `Types: deb deb-src` และผลของ `apt update` มีบรรทัดที่ลงท้ายด้วย `Sources`

```bash
sudo apt build-dep -y linux linux-image-unsigned-$(uname -r)
sudo apt install -y fakeroot llvm libncurses-dev dwarves
```

📸 `s05_build_dep.png` — ท้ายผลของสองคำสั่งนี้ ไม่มี error

---

## Phase 4 — ดาวน์โหลดและเตรียมซอร์สเคอร์เนล

### 4.1 ดาวน์โหลดซอร์สของเคอร์เนลรุ่นที่ใช้อยู่

```bash
mkdir -p ~/kernel && cd ~/kernel
apt source linux-image-unsigned-$(uname -r)
cd ~/kernel/linux-*/
chmod a+x debian/scripts/* debian/scripts/misc/*
fakeroot debian/rules clean
```

`debian/debian.env` บอกว่าเคอร์เนลนี้ใช้ changelog ในโฟลเดอร์ไหน ถ้า ISO ติดตั้งเคอร์เนล HWE มาจะเป็นโฟลเดอร์ `debian.hwe-X.Y` (เครื่องนี้ใช้เคอร์เนล 7.0 จึงน่าจะเป็น `debian.hwe-7.0`) แทน `debian.master` ที่คู่มือ Ubuntu ยกตัวอย่าง ตัวแปร `$D` ด้านล่างจะชี้ให้ถูกโฟลเดอร์เอง (ถ้าปิด terminal ไปแล้วเปิดใหม่ ต้องรันบรรทัด `D=...` ซ้ำ)

วางทีละบรรทัด:

```bash
pwd
ls ~/kernel
cat debian/debian.env
D=$(sed -n 's/^DEBIAN=//p' debian/debian.env); echo $D
```

📸 `s06_apt_source.png`

### 4.2 เปลี่ยนเลข ABI เป็น 999

เลข ABI คือเลขหลังขีดในบรรทัดแรกของ changelog เช่น `6.8.0-51.52` → `6.8.0-999.52` ทำให้เคอร์เนลที่เรา build ชื่อ `...-999-generic` แยกจากเคอร์เนลเดิมได้ชัดเจน

```bash
cp $D/changelog ~/kernel/changelog.orig
sed -i '1s/\(([0-9.]*\)-[0-9]*\./\1-999./' $D/changelog
diff -u ~/kernel/changelog.orig $D/changelog | head -8
```

📸 `s07_abi_999.png` — บรรทัด `-` เป็นเลขเดิม บรรทัด `+` เป็น `-999.`

### 4.3 ฝังข้อความของกลุ่มในเคอร์เนล

เพิ่มหนึ่งบรรทัดใน `start_kernel()` ต่อจากบรรทัดที่พิมพ์ banner ของเคอร์เนล หลังบูตจะเห็นข้อความนี้ใน `dmesg` เป็นหลักฐานว่าเคอร์เนลที่รันอยู่คือตัวที่กลุ่มคอมไพล์เอง

```bash
cp init/main.c ~/kernel/main.c.orig
sed -i 's/^\(\s*\)pr_notice("%s", linux_banner);$/&\n\1pr_notice("CPE333 MiniProject1: custom kernel compiled by our group\\n");/' init/main.c
diff -u ~/kernel/main.c.orig init/main.c
```

📸 `s08_main_c.png` — diff มีบรรทัด `+	pr_notice("CPE333 ...\n");` หนึ่งบรรทัดพอดี ถ้า diff ว่างเปล่า ให้เปิด `nano init/main.c` แล้วเพิ่มบรรทัดนั้นใต้ `pr_notice("%s", linux_banner);` เอง

### 4.4 (ไม่บังคับ) เปิดดูการตั้งค่าเคอร์เนล

```bash
fakeroot debian/rules editconfigs
```

ตอบ `Y` เฉพาะ `amd64/config.flavour.generic` ที่เหลือตอบ `n` เมื่อหน้า menuconfig ขึ้นมาให้ถ่ายภาพแล้วกด **Exit** โดยไม่ต้องแก้อะไร

📸 `s09_menuconfig.png`

---

## Phase 5 — คอมไพล์เคอร์เนล

ใช้เวลาประมาณ 1–3 ชั่วโมง ระหว่างนั้นอย่าปิด VM หรือปล่อยให้ Windows sleep

```bash
cd ~/kernel/linux-*/
fakeroot debian/rules clean
{ date; time fakeroot debian/rules binary; rc=$?; date; echo "build exit status = $rc"; } 2>&1 | tee ~/build.log
```

📸 `s10_build_running.png` — ส่งเมื่อไหร่ก็ได้ระหว่าง build ให้เห็นข้อความคอมไพล์กำลังวิ่ง

ระหว่างที่ build เปิด terminal อีกแท็บ (`Ctrl+Shift+T`) แล้วรัน `top` แล้วกด `1` เพื่อดูแยกทีละ CPU

📸 `s11_build_cpu.png` — เห็น `%Cpu0`–`%Cpu11` ถูกใช้งานพร้อมกัน และมี process `cc1`/`make` ของการ build (กด `q` ออกจาก `top` หลังถ่ายแล้ว)

เมื่อ build จบ กลับมาที่แท็บแรก ท้ายจอต้องเห็น `real/user/sys`, เวลาจบ และ `build exit status = 0` แล้ววางทีละบรรทัด เพื่อให้ภาพเดียวกันมีทั้งคำสั่ง build และเวลาเริ่ม:

```bash
history | grep "fakeroot debian/rules binary" | grep -v grep
head -2 ~/build.log
```

📸 `s12_build_done.png`

จากนั้นวางทีละบรรทัด:

```bash
ls -lh ~/kernel/*.deb
df -h /
```

📸 `s13_deb_list.png`

**ถ้า build ล้ม** ถ่ายภาพ error ก่อน แล้วหาบรรทัดที่ผิดด้วย `grep -n -i -m5 ' error' ~/build.log`
- ล้มที่ขั้นตรวจ ABI/module (เพราะ ABI 999 ไม่มีของเดิมให้เทียบ) → รันใหม่ด้วย
  `{ date; time skipabi=true skipmodule=true fakeroot debian/rules binary; rc=$?; date; echo "build exit status = $rc"; } 2>&1 | tee ~/build.log`
- ดิสก์เต็ม → เพิ่ม `skipdbg=true` แบบเดียวกัน เพื่อไม่สร้างแพ็กเกจ debug symbol

---

## Phase 6 — ติดตั้งเคอร์เนลใหม่

```bash
cd ~/kernel
sudo dpkg -i linux-hwe-7.0-headers-7.0.0-999_*_all.deb \
             linux-headers-7.0.0-999-generic_*_amd64.deb \
             linux-image-unsigned-7.0.0-999-generic_*_amd64.deb \
             linux-modules-7.0.0-999-generic_*_amd64.deb
```

(ใช้ชื่อเต็ม ไม่ใช้ `linux-modules-*` เพราะ build ได้ package module เสริมอีก 6 ตัว เช่น `linux-modules-iwlwifi` ซึ่งเป็น driver ของฮาร์ดแวร์ที่ VM ไม่มี และเกินกว่า 4 package ที่คู่มือกำหนด)

📸 `s14_dpkg_install.png` — ท้ายผลของ `dpkg -i` ไม่มี error

Ubuntu ซ่อนเมนู GRUB ไว้โดยปริยาย ต้องเปิดให้แสดงก่อนจึงจะถ่ายภาพได้:

```bash
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/; s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
grep ^GRUB_TIMEOUT /etc/default/grub
sudo update-grub
```

📸 `s15_update_grub.png` — `GRUB_TIMEOUT_STYLE=menu`, `GRUB_TIMEOUT=10` และ `Found linux image: /boot/vmlinuz-...-999-generic`

```bash
sudo reboot
```

ตอนบูต ให้คลิกเข้าไปในหน้าต่าง VM แล้ว **กดลูกศรเพื่อหยุดนับถอยหลังของ GRUB ก่อน** แล้วค่อยส่งชื่อภาพ (ถ้าไม่หยุด GRUB จะบูตต่อภายใน 10 วินาที ถ่ายไม่ทัน)

📸 `s16_grub_menu.png` — เมนูหลักของ GRUB
📸 `s17_grub_advanced.png` — เลือก **Advanced options for Ubuntu** แล้วกด Enter เห็นทั้งเคอร์เนลเดิมและ `-999-generic`

ถ่ายเสร็จแล้วเลือกรายการ `-999-generic` (ตัวที่ไม่ใช่ recovery mode) แล้วกด Enter เพื่อบูต

---

## Phase 7 — ตรวจสอบผล และทดลองย้อนกลับ

### 7.1 บูตเข้าเคอร์เนลใหม่

หลังบูตเข้าเคอร์เนล 999 จาก Phase 6 แล้ว (บูตครั้งต่อไปเลือก **Ubuntu** รายการแรกได้เลย เพราะเลข 999 สูงกว่าเคอร์เนลเดิม GRUB จึงเลือกเป็นค่าเริ่มต้น) วางทีละบรรทัด:

```bash
date
uname -r
uname -v
sudo dmesg | grep CPE333
dpkg -l | grep -- -999-generic
```

📸 `s18_new_kernel.png` — `uname -r` ลงท้าย `-999-generic`, `uname -v` แสดงวันเวลาที่กลุ่ม build และเห็นข้อความ `CPE333 MiniProject1: ...`

### 7.2 ย้อนกลับไปเคอร์เนลเดิม

`sudo reboot` → GRUB → **Advanced options for Ubuntu** → เลือกเคอร์เนลเดิม (ตัวที่จดไว้ใน Phase 2 ไม่ใช่ตัวที่เขียนว่า recovery mode) แล้ววางทีละบรรทัด:

```bash
uname -r
ls /boot/vmlinuz-*
```

📸 `s19_rollback.png` — `uname -r` เป็นเคอร์เนลเดิม แต่ใน `/boot` ยังมีเคอร์เนล 999 อยู่

จากนั้น `sudo reboot` กลับเข้าเคอร์เนล 999 ตามปกติ

---

## รายการภาพหลักฐานที่ต้องมีครบก่อนเขียนรายงาน

| Phase | ไฟล์ใน `result/screenshots/` |
| --- | --- |
| 1 สร้าง VM | `s01_vm_hardware.png` |
| 2 ติดตั้ง Ubuntu | `s03_baseline.png` |
| 3 เตรียมเครื่อง | `s04_deb_src.png`, `s05_build_dep.png` |
| 4 เตรียมซอร์ส | `s06_apt_source.png`, `s07_abi_999.png`, `s08_main_c.png`, `s09_menuconfig.png` (ไม่บังคับ) |
| 5 คอมไพล์ | `s10_build_running.png`, `s11_build_cpu.png`, `s12_build_done.png`, `s13_deb_list.png` |
| 6 ติดตั้ง | `s14_dpkg_install.png`, `s15_update_grub.png`, `s16_grub_menu.png`, `s17_grub_advanced.png` |
| 7 ตรวจสอบ | `s18_new_kernel.png`, `s19_rollback.png` |

รวม 18 ภาพ (บังคับ 17) และ `result/notes.txt` ถ้ามีปัญหาระหว่างทาง
