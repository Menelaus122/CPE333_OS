# Makefile for CPE333 Problem Session 3

CC = gcc
CFLAGS = -Wall -Wextra
XELATEX = xelatex -interaction=nonstopmode

SRC_DIR = src
DOC_DIR = docs
RESULT_DIR = result

SRCS = $(wildcard $(SRC_DIR)/*.c)
PROGS = $(patsubst $(SRC_DIR)/%.c,$(SRC_DIR)/%,$(SRCS))

.PHONY: all build pdf result result-q1 result-q2 result-q5 clean

all: build pdf

build: $(PROGS)

# q1_burn ต้องคอมไพล์ด้วย -O0 เพื่อไม่ให้คอมไพเลอร์ตัดลูปคำนวณทิ้ง
$(SRC_DIR)/q1_burn: $(SRC_DIR)/q1_burn.c
	$(CC) $(CFLAGS) -O0 $< -o $@

$(SRC_DIR)/%: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -O2 $< -o $@

pdf:
	cd $(DOC_DIR) && $(XELATEX) PS03.tex && $(XELATEX) PS03.tex

# เก็บผลการทดลองใหม่ทั้งหมด (ใช้เวลาประมาณ 3 นาที ต้องรันบน Linux/WSL)
result: result-q1 result-q2 result-q5

result-q1:
	bash $(SRC_DIR)/run_q1.sh > $(RESULT_DIR)/q1_verified.txt 2>&1

result-q2:
	bash $(SRC_DIR)/run_q2.sh > $(RESULT_DIR)/q2_verified.txt 2>&1

result-q5:
	bash $(SRC_DIR)/run_q5.sh > $(RESULT_DIR)/q5_verified.txt 2>&1

clean:
	rm -f $(SRC_DIR)/*.o $(PROGS)
	rm -f $(DOC_DIR)/*.aux $(DOC_DIR)/*.fdb_latexmk $(DOC_DIR)/*.fls $(DOC_DIR)/*.log $(DOC_DIR)/*.out $(DOC_DIR)/*.toc
