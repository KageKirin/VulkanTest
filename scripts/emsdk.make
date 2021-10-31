## Makefile to install and update the Emscripten SDK

emsdk-update:
	$(GENIE) emsdk-update

emsdk-env:
	$(GENIE) emsdk-env

emsdk: emsdk-update emsdk-env
	@echo Installed the Emscripten SDK
