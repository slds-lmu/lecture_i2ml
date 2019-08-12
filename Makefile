#!/bin/bash

all: day1 day2 day3 day4 day5 exercise

all_sources: day1 day2 day3-all day4-all day5 exercise

DAY1=01-intro
DAY2=02-classification
DAY3=03-performance
DAY4=04-trees
DAY5=05-tuning-nested

day1:
	cd $(DAY1); make

day2:
	cd $(DAY2); make

day3:
	cd $(DAY3); make

day4:
	cd $(DAY4); make

day5:
	cd $(DAY5); make

exercise:
	cd exercises; make

# with rsrc

day3-all:
	cd $(DAY3); make all_sources

day4-all:
	cd $(DAY4); make all_sources

# only rsrc

sources:
	cd $(DAY3); make sources
	cd $(DAY4); make sources
