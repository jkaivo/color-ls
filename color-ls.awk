#!/bin/sh

# MIT License
#
# Copyright (c) 2018 Jakob Kaivo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function columns_down() {
	widest++;
	column = 0;
	columns = ENVIRON["COLUMNS"];
	if (columns == 0) {
		columns = 80;
	}
	ncolumns = columns / widest;

	for (i = 1; i <= NR; i++) {
		# FIXME: this is all jacked up
		printf("%-*s", widest, all[(row * ncolumns) + (i % ncolumns)]);
		column += widest;
		if (column > columns) {
			printf("\n");
			column = 0;
			row++;
		}
		i++;
	}

	if (column != 0) {
		printf("\n");
	}
}

function columns_across() {
	widest++;
	column = 0;
	columns = ENVIRON["COLUMNS"];
	if (columns == 0) {
		columns = 80;
	}

	for (i = 1; i <= NR; i++) {
		printf("%-*s", widest, all[i]);
		column += widest;
		if (column > columns) {
			printf("\n");
			column = 0;
		}
	}

	if (column != 0) {
		printf("\n");
	}
}

function long_output() {
	for (i = 1; i <= NR; i++) {
		printf("%s\n", file[i]);
	}
}

function comma_output() {
	for (i = 1; i <= NR; i++) {
		printf("%s%s", i == 1 ? "" : ", ", $0 );
	}
}

{ color=39; }
/\/$/ || (long && /^d/) || (long && $0 == $1) { color=34; }
/\*$/ || (long && /^-/ && $1 ~ /x/){ color=32; }
/\|$/ || (long && /^p/) { color=33; }
/@$/ || (long && /^l/) { color=35; }

{
	if (trim == 1) {
		gsub(/[\/\*\|@]$/, "");
	}

	if (length > widest) {
		widest = length;
	}

	file[NR] = "\033[" color "m" $0 "\033\[0m";
}

END {
	if (output == "-x") {
		columns_across();
	} else if (output == "-C") {
		columns_down();
	} else if (output == "-m") {
		commat_output();
	} else {
		long_output();
	}
}
