#!/bin/bash

all: day1 day2 day3 day4

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
