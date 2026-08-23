# Makefile for CPE333 Problem Session 2

CC = gcc
CFLAGS = -Wall -Wextra -O2
XELATEX = xelatex -interaction=nonstopmode

SRC_DIR = src
DOC_DIR = docs
BUILD_DIR = build

SRCS = $(wildcard $(SRC_DIR)/*.c)
PROGS = $(patsubst $(SRC_DIR)/%.c,$(SRC_DIR)/%,$(SRCS))

.PHONY: all build pdf clean

all: build pdf

build: $(PROGS)

$(SRC_DIR)/%: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@

pdf:
	cd $(DOC_DIR) && $(XELATEX) REPORT.tex && $(XELATEX) REPORT.tex

clean:
	rm -f $(SRC_DIR)/*.o $(SRC_DIR)/q1_1 $(SRC_DIR)/q1_2 $(SRC_DIR)/q2 $(SRC_DIR)/q3 $(SRC_DIR)/q4 $(SRC_DIR)/q5
	rm -f $(DOC_DIR)/*.aux $(DOC_DIR)/*.fdb_latexmk $(DOC_DIR)/*.fls $(DOC_DIR)/*.log $(DOC_DIR)/*.out $(DOC_DIR)/*.toc
