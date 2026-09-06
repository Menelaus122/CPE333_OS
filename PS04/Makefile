# Makefile for CPE333 Problem Session 4

CC = gcc
CFLAGS = -Wall -Wextra
XELATEX = xelatex -interaction=nonstopmode

SRC_DIR = src
DOC_DIR = docs
RESULT_DIR = result

.PHONY: all build pdf result result-q1 result-q2 clean

all: build pdf

# โจทย์ให้คอมไพล์โปรแกรมเดียวกันสองแบบ คือแบบปกติ (PIE) กับแบบ -no-pie
build: $(SRC_DIR)/q1_static $(SRC_DIR)/q1_auto \
       $(SRC_DIR)/q1_static_nopie $(SRC_DIR)/q1_auto_nopie \
       $(SRC_DIR)/q2_extern $(SRC_DIR)/q2_noextern \
       $(SRC_DIR)/q2_extern_nopie $(SRC_DIR)/q2_noextern_nopie \
       $(SRC_DIR)/q2_shared

$(SRC_DIR)/q1_static_nopie: $(SRC_DIR)/q1_static.c
	$(CC) $(CFLAGS) -no-pie $< -o $@

$(SRC_DIR)/q1_auto_nopie: $(SRC_DIR)/q1_auto.c
	$(CC) $(CFLAGS) -no-pie $< -o $@

$(SRC_DIR)/q2_extern_nopie: $(SRC_DIR)/q2_extern.c
	$(CC) $(CFLAGS) -no-pie $< -o $@

$(SRC_DIR)/q2_noextern_nopie: $(SRC_DIR)/q2_noextern.c
	$(CC) $(CFLAGS) -no-pie $< -o $@

# ตัวอย่างที่ extern ถูกใช้จริง คือแชร์ตัวแปรข้ามไฟล์ ต้องลิงก์สองไฟล์เข้าด้วยกัน
$(SRC_DIR)/q2_shared: $(SRC_DIR)/q2_shared_main.c $(SRC_DIR)/q2_shared_def.c
	$(CC) $(CFLAGS) $^ -o $@

$(SRC_DIR)/%: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@

pdf:
	cd $(DOC_DIR) && $(XELATEX) PS04.tex && $(XELATEX) PS04.tex

# เก็บผลการทดลองใหม่ทั้งหมด (ต้องรันบน Linux/WSL)
result: result-q1 result-q2

result-q1:
	bash $(SRC_DIR)/run_q1.sh > $(RESULT_DIR)/q1_verified.txt 2>&1

result-q2:
	bash $(SRC_DIR)/run_q2.sh > $(RESULT_DIR)/q2_verified.txt 2>&1

clean:
	rm -f $(SRC_DIR)/*.o
	rm -f $(SRC_DIR)/q1_static $(SRC_DIR)/q1_auto $(SRC_DIR)/q1_static_nopie $(SRC_DIR)/q1_auto_nopie
	rm -f $(SRC_DIR)/q2_extern $(SRC_DIR)/q2_noextern $(SRC_DIR)/q2_extern_nopie $(SRC_DIR)/q2_noextern_nopie $(SRC_DIR)/q2_shared
	rm -f $(DOC_DIR)/*.aux $(DOC_DIR)/*.fdb_latexmk $(DOC_DIR)/*.fls $(DOC_DIR)/*.log $(DOC_DIR)/*.out $(DOC_DIR)/*.toc
