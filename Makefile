# All real work lives in make.sh; the Makefile just delegates to it so the
# build logic stays in one shell script.
.PHONY: all install dev build preview clean

all: build

install:
	./make.sh install

dev:
	./make.sh dev

build:
	./make.sh build

preview:
	./make.sh preview

clean:
	./make.sh clean
