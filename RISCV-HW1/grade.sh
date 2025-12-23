#!/bin/bash

export PATH=$PATH:image/bin
test_dir="sample_testcases" 
exe="b12902075.s"

for i in {1..5}; do
	jupiter $exe < "$test_dir/$i.in" | head -n 1 > tmp.txt
	if diff tmp.txt "$test_dir/$i.out" > /dev/null; then
		echo -e "\e[32mPASS\e[0m testcase$i"
	else
		echo -e "\e[31mFAIL\e[0m testcase$i"
	fi
done
	