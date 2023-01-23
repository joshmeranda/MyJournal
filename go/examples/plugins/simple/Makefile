all: plugin loader

plugin: plugin.so

plugin.so: plugin.go
	go build -buildmode plugin -o plugin.so plugin.go

loader: loader.go
	go build -o loader loader.go

clean:
	rm --force --recursive loader plugin.so