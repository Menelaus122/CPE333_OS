# Makefile for CPE333 Problem Session 7 (Concurrency and Thread)
# หลักฐานทุกขั้นเป็นภาพหน้าจอใน result/screenshots/ คำสั่งที่ใช้ถ่ายภาพอยู่ใน docs/COMMANDS.md

CC = gcc
XELATEX = xelatex -interaction=nonstopmode

SRC_DIR = src
DOC_DIR = docs
TOOL_DIR = tools

.PHONY: all build pdf docx clean

all: build pdf

# คอมไพล์ตามคำสั่งในใบงานทุกตัวอักษร และตั้งใจไม่ใส่ -O
# ถ้าใช้ -O2 คอมไพเลอร์อาจรวมลูปทั้งลูปเป็นการบวกครั้งเดียว ทำให้ race condition แทบไม่เกิด
build: $(SRC_DIR)/ps7

$(SRC_DIR)/ps7: $(SRC_DIR)/ps7.c
	$(CC) -o $@ $< -lpthread

# รันสองรอบเพื่อให้สารบัญและเลขหน้าถูกต้อง
pdf:
	cd $(DOC_DIR) && $(XELATEX) PS07.tex && $(XELATEX) PS07.tex

# สร้างรายงานฉบับ .docx จาก PS07.tex ไฟล์เดียวกัน
docx:
	node $(TOOL_DIR)/build_report.js

clean:
	rm -f $(SRC_DIR)/ps7
	rm -f $(DOC_DIR)/*.aux $(DOC_DIR)/*.fdb_latexmk $(DOC_DIR)/*.fls $(DOC_DIR)/*.log $(DOC_DIR)/*.out $(DOC_DIR)/*.toc
