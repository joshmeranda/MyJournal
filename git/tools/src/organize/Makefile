ifndef GO
	GO=$(shell which go)
endif

VERSION=0.0.0

GO_BUILD=${GO} build -race
GO_FMT=${GO} fmt
GO_TEST=${GO} test

ifdef VERBOSE
        GO_BUILD += -v -x
        GO_TEST += -test.v

        RM += --verbose
endif

.PHONY: help

help:
	@echo "Available targets and values:"
	@echo "Targets:"
	@echo "  build         build binary"
	@echo "  test          run tests"
	@echo "  mostly-clean  clean source directory of inexpensive files"
	@echo "  clean         clean source directory"
	@echo ""
	@echo "Values:"
	@echo "  VERBOSE     run recipes with more verbose output if possible"

# # # # # # # # # # # # # # # # # # # #
# Build recipes                       #
# # # # # # # # # # # # # # # # # # # #

.PHONY: organize

SOURCES=$(shell find . -name '*.go' ! -name '*_test.go')

build: bin/organize

bin/organize: ${SOURCES}
	${GO_BUILD} -ldflags "-X main.Version=${VERSION}" -o $@ ./pkg/cmd/

# # # # # # # # # # # # # # # # # # # #
# Test recipes                        #
# # # # # # # # # # # # # # # # # # # #

.PHONY: test

TEST_PKGS=$(shell dirname $(shell find . -name '*_test.go') | sort | uniq)

test:
	${GO_TEST} ${TEST_PKGS}

# # # # # # # # # # # # # # # # # # # #
# Cleaning recipes                    #
# # # # # # # # # # # # # # # # # # # #

.PHONY: mostly-clean clean

mostly-clean:
	${RM} --recursive ./pkg/*.test

clean: mostly-clean
	${RM} --recursive bin