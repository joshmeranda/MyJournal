example: example.y
	goyacc -l -o parse.go -v $(<:.y=.output) $<

clean:
	rm -rvf parse.go example.output