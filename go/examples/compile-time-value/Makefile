ctv: pkg/values.go pkg/cmd/main.go
	go build -ldflags "-X ctv/pkg.String=hello -X ctv/pkg.Int=5" -o ctv ./pkg/cmd/main.go

clean:
	rm --force --recursive ctv/