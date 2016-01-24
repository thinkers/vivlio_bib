#!/usr/bin/awk -f

BEGIN {
	prefix = "outline/"
	format = ".html"
}

$1 == "<section" {
	if (file) close(file)

	ch = $0
	n = split(ch, arr, /[[:space:]]+/)
	ch = arr[3]
	ch = substr(ch, 2 + index(ch, "="))
	ch = substr(ch, 1, length(ch) - 2)
	file = prefix ch format
}

file {
	print $0 > file
}

