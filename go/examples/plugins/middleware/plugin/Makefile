plugin: plugin.so

plugin.so: plugin.go
	go build -buildmode plugin -o plugin.so plugin.go

clean:
	rm --recursive --force plugin.so
