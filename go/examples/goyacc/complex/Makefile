example: example.y
	goyacc -l -o parse.go -v $(<:.y=.output) $<

clean:
	rm -rvf example.go example.output