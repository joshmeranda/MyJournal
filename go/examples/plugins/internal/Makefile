.PHONY: all plugins
all: loader plugins

loader: ./pkg/cmd/*.go ./pkg/*.go
	go build -o loader ./pkg/cmd/main.go

plugins:
	cd plugins && make plugins

clean:
	cd plugins && make clean
	rm --recursive --force loader
