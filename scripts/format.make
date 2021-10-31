## formatting makerules

ALL_SOURCE_FILES = \
	$(shell fd ".*\.h"   -- Decoder/inc)  \
	$(shell fd ".*\.c"   -- Decoder/inc)  \
	$(shell fd ".*\.cpp" -- Decoder/inc)  \
	$(shell fd ".*\.h"   -- Decoder/src)  \
	$(shell fd ".*\.c"   -- Decoder/src)  \
	$(shell fd ".*\.cpp" -- Decoder/src)

ALL_TRACKED_FILES = \
	$(shell git ls-files -- Decoder/inc | rg ".*\.h")    \
	$(shell git ls-files -- Decoder/inc | rg ".*\.c")    \
	$(shell git ls-files -- Decoder/inc | rg ".*\.cpp")  \
	$(shell git ls-files -- Decoder/src | rg ".*\.h")    \
	$(shell git ls-files -- Decoder/src | rg ".*\.c")    \
	$(shell git ls-files -- Decoder/src | rg ".*\.cpp")

ALL_MODIFIED_FILES = \
	$(shell git ls-files -m -- Decoder/inc) \
	$(shell git ls-files -m -- Decoder/src) \
	$(shell git ls-files -m -- Decoder/src/utils")


format-all: $(ALL_SOURCE_FILES)
	clang-format -i $^

format: $(ALL_TRACKED_FILES)
	clang-format -i $^
	#$(GENIE) format

q qformat: $(ALL_MODIFIED_FILES)
	clang-format -i $^
