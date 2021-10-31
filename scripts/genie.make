
update-genie-darwin:
	curl -L -o ./bin/darwin/genie https://github.com/bkaradzic/bx/raw/master/tools/bin/darwin/genie

update-genie-windows:
	curl -L -o ./bin/windows/genie.exe https://github.com/bkaradzic/bx/raw/master/tools/bin/windows/genie.exe

update-genie-linux:
	curl -L -o ./bin/linux/genie https://github.com/bkaradzic/bx/raw/master/tools/bin/linux/genie

update-genie: update-genie-darwin update-genie-linux update-genie-windows
	@echo Updated genie binaries
