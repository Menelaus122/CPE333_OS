# Makefile for CPE333 Problem Session 6 (Virtual Memory)
# ปฏิบัติการนี้ไม่มี program ภาษา C ทุกหลักฐานเป็นภาพหน้าจอใน result/screenshots/
# จึงมีแต่ target สำหรับสร้างเอกสารเท่านั้น

XELATEX = xelatex -interaction=nonstopmode
DOC_DIR = docs
TOOL_DIR = tools

.PHONY: all pdf docx clean

all: pdf docx

# รันสองรอบเพื่อให้สารบัญและเลขหน้าถูกต้อง
pdf:
	cd $(DOC_DIR) && $(XELATEX) PS06.tex && $(XELATEX) PS06.tex

# สร้างรายงานฉบับ .docx จากเนื้อหาชุดเดียวกัน
docx:
	node $(TOOL_DIR)/build_report.js

clean:
	rm -f $(DOC_DIR)/*.aux $(DOC_DIR)/*.fdb_latexmk $(DOC_DIR)/*.fls $(DOC_DIR)/*.log $(DOC_DIR)/*.out $(DOC_DIR)/*.toc
