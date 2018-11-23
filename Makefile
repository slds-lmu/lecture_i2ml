#!/bin/bash

all: day1 day2 day3 day4 exercise

all_sources: day1 day2 day3-all day4-all exercise

sources: day3-rsrc day4-rsrc

DAY1=01-intro
DAY2=02-classification
DAY3=03-performance
DAY4=04-trees

day1:
	cd $(DAY1); make

day2:
	cd $(DAY2); make

day3:
	cd $(DAY3); make

day4:
	cd $(DAY4); make

exercise:
	cd exercises; make

# with rsrc

day3-all:
	cd $(DAY3); make all_sources

day4-all:
	cd $(DAY4); make all_sources

# only rsrc

day3-rsrc:
	cd $(DAY3); make sources

day4-rsrc:
	cd $(DAY4); make sources
