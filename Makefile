#!/bin/bash

all: day1 day2 day3 day4

DAY1=01-intro
DAY2=02-classification
DAY3=03-performance
DAY4=04-trees

day1: $(DAY1)/slides.pdf

01-intro/slides.pdf: $(DAY1)/slides.Rnw
	cd $(DAY1); make

day2: $(DAY2)/slides.pdf

$(DAY2)/slides.pdf: $(DAY2)/slides.Rnw
	cd $(DAY2); make

day3: $(DAY3)/slides.pdf

$(DAY3)/slides.pdf: $(DAY3)/slides.Rnw
	cd $(DAY3); make

day4: $(DAY4)/slides.pdf

$(DAY4)/slides.pdf: $(DAY4)/slides.Rnw
	cd $(DAY4); make
