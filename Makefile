CFLAGS  ?= -O2 -march=native
LDFLAGS ?= -Wl,-z,relro -Wl,-z,now

GNATMAKE  = gprbuild -dm -p
GNATCLEAN = gprclean -q
GNATINSTALL = gprinstall

PREFIX ?= /usr

includedir = $(PREFIX)/include
gprdir     = $(PREFIX)/share/gpr
libdir     = $(PREFIX)/lib
alidir     = $(libdir)

.PHONY: build tests debug clean coverage install

build:
	$(GNATMAKE) -P tools/json_ada.gpr -cargs $(CFLAGS) -largs $(LDFLAGS)

build_test:
	$(GNATMAKE) -P tests/unit/unit_tests.gpr -XMode=coverage -cargs -O0 -largs $(LDFLAGS)

debug:
	$(GNATMAKE) -P tools/json_ada.gpr -XMode=debug -cargs $(CFLAGS) -largs $(LDFLAGS)

clean:
	$(GNATCLEAN) -P tools/json_ada.gpr
	$(GNATCLEAN) -P tests/unit/unit_tests.gpr
	rm -rf build tests/unit/build test/cov TEST-*.xml

tests: build_test
	./tests/unit/test_bindings

coverage:
	mkdir -p tests/cov
	lcov -q -c -d tests/unit/build/obj -o tests/cov/unit.info
	lcov -q -r tests/cov/unit.info */adainclude/* -o tests/cov/unit.info
	lcov -q -r tests/cov/unit.info */tests/unit/* -o tests/cov/unit.info
	genhtml -q --ignore-errors source -o tests/cov/html tests/cov/unit.info
	lcov -l tests/cov/unit.info

install:
	$(GNATINSTALL) -p -q -f --install-name='json-ada' \
		--sources-subdir=$(includedir) \
		--project-subdir=$(gprdir) \
		--lib-subdir=$(libdir) \
		--ali-subdir=$(alidir) \
		--prefix=$(PREFIX) -P tools/json_ada.gpr
