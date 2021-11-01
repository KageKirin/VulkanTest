--
-- Broadway build configuration script
--
-------------------------------------------------------------------------------
--
-- Maintainer notes
--
-- - we're not using the regular _scaffolding_ for this project
--   mostly b/c it's too bloated
-- - scaffolds are still used though
--
-------------------------------------------------------------------------------
--
-- Use the --to=path option to control where the project files get generated. I use
-- this to create project files for each supported toolset, each in their own folder,
-- in preparation for deployment.
--
	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}
-------------------------------------------------------------------------------
--
-- Use the --tooolchain=identifier option to control which toolchain is used
--
	newoption {
		trigger = "toolchain",
		value   = "string",
		description = "Set the toolchain to use for compilation"
	}


-------------------------------------------------------------------------------
if not _ACTION then
	return true
end


-------------------------------------------------------------------------------
--
-- Pull in dependencies
--
	dofile("functions.lua") -- from scaffolding/system/functions.lua
	dofile("cppsettings.lua") -- from scaffolding/system/settings.lua

-------------------------------------------------------------------------------
--
-- Solution wide settings
--

local thisscriptpath = path.getabsolute(path.getdirectory(_SCRIPT))
local rootpath       = path.getabsolute(path.join(thisscriptpath, '..'))
local locationpath = path.join(os.getcwd(), _OPTIONS["to"] or path.join('build/projects'))
local targetpath   = path.join(locationpath, '../bin')
local objectpath   = path.join(locationpath, '../obj')
local librarypath   = path.join(locationpath, '../lib')

	solution "Broadway"
		configurations {
			"Debug",
			"Release"
		}
		location (locationpath)

		configuration { "Debug" }
			targetsuffix ""
			defines    { "DEBUG", "_DEBUG" }

		configuration { "Release" }
			targetsuffix ""
			defines    { "RELEASE", "NDEBUG" }

		configuration { "windows" }
			targetdir (path.join(targetpath, "windows"))
			objdir    (path.join(objectpath, "windows"))

		configuration { "linux*" }
			targetdir (path.join(targetpath, "linux"))
			objdir    (path.join(objectpath, "linux"))

		configuration { "macosx" }
			targetdir (path.join(targetpath, "darwin"))
			objdir    (path.join(objectpath, "darwin"))

		configuration { "asmjs" }
			targetdir (path.join(targetpath, "asmjs"))
			objdir    (path.join(objectpath, "asmjs"))

		configuration { "wasm*" }
			targetdir (path.join(targetpath, "wasm"))
			objdir    (path.join(objectpath, "wasm"))

		configuration { "Debug" }
			defines     { "_DEBUG", }
			flags       { "Symbols" }

		configuration { "Release" }
			defines     { "NDEBUG", }
			flags       { "OptimizeSize" }

		configuration { "Debug", "windows" }
			linkoptions { "-Wl,/DEBUG:FULL" }

		configuration {}

		flags {
			"ExtraWarnings",
			"No64BitChecks",
			"StaticRuntime",
		}

		buildoptions {
			--"-fdiagnostics-show-hotness",
			"-fdiagnostics-fixit-info",
			"-fdiagnostics-color",
			"-fdiagnostics-show-note-include-stack",
			"-Wextra-tokens",
			"-Wno-undef",
		}

	if _OPTIONS.toolchain == 'windows' then
		applytoolchain('clang-windows')
	elseif _OPTIONS.toolchain == 'macosx' then
		applytoolchain('clang-macos')
	elseif _OPTIONS.toolchain == 'linux' then
		applytoolchain('clang-linux')
	elseif _OPTIONS.toolchain == 'asmjs' then
		applytoolchain('emscripten-asmjs')
	elseif _OPTIONS.toolchain == 'wasm' then
		applytoolchain('emscripten-wasm')
	end

	startproject "broadway-test"

	configuration { "ios*" }
		defines { "USE_GLES3=1" }
	configuration { "android-*" }
		defines { "USE_GLES3=1" }
	configuration { "asmjs" }
		defines { "USE_GLES3=1" }
	configuration { "wasm*" }
		defines { "USE_GLES3=1" }
	configuration {}

-------------------------------------------------------------------------------
--
-- External 'scaffold' projects
--

local external_scaffolds = {
	--keep
	--this
	--line
	['khr'] = dofile(path.join(rootpath, "libs", "khr", "khr.lua")),
	--keep
	--this
	--line
	['glad'] = dofile(path.join(rootpath, "libs", "glad", "glad.lua")),
	--keep
	--this
	--line
	['glew'] = dofile(path.join(rootpath, "libs", "glew", "glew.lua")),
	--keep
	--this
	--line
	['sdl'] = dofile(path.join(rootpath, "libs", "sdl", "sdl1-prebuilt.lua")),
	--keep
	--this
	--line
	['sdl2'] = dofile(path.join(rootpath, "libs", "sdl", "sdl2-prebuilt.lua")),
	--keep
	--this
	--line
	['stb'] = dofile(path.join(rootpath, "libs", "stb", "stb.lua")),
	--keep
	--this
	--line
	['cimgui'] = dofile(path.join(rootpath, "libs", "cimgui", "cimgui.lua")),
	--keep
	--this
	--line
	['win-unistd'] = dofile(path.join(rootpath, "libs", "win-unistd", "win-unistd.lua")),
	--keep
	--this
	--line
}

create_packages_projects(external_scaffolds)

-------------------------------------------------------------------------------
--
-- Main project
--

core_projects = {
	["shaders"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() links { "shaders" } end,
		_create_projects = function()
			project "shaders"
				language "C++"
				kind "StaticLib"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_cppfwd()
				add_packages {
					external_scaffolds['khr'],
				}

				add_packages_conditional(
					function()
						return not( _OPTIONS.toolchain == 'asmjs' or
									_OPTIONS.toolchain == 'wasm')
					end, {
					external_scaffolds['glad'],
				})

				includedirs {
					"../Decoder/inc",
					"../Decoder/src/shaders",
					"../Decoder/src/utils",
				}

				defines {}

				removedefines {}

				files {
					"../Decoder/src/shaders/**.h",
					"../Decoder/src/shaders/**.cpp",
					"../Decoder/src/shaders/**.c",
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}
		end, -- _create_projects()
	},
	["gitrev"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() links { "gitrev" } end,
		_create_projects = function()
			project "gitrev"
				language "C"
				kind "StaticLib"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				files {
					"../Decoder/src/gitrev.c",
				}

				prebuildcommands {
					'make -C ' .. rootpath .. ' -f projgen.make generate',
				}

		end, -- _create_projects()
	},
	["broadway"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "broadway"
			project "broadway"
				targetname "broadway"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				add_packages {
					external_scaffolds['khr'],
					external_scaffolds['sdl2'],
					external_scaffolds['stb'],
					external_scaffolds['cimgui'],
					external_scaffolds['win-unistd'],
				}

				add_packages_conditional(
					function()
						return not( _OPTIONS.toolchain == 'asmjs' or
									_OPTIONS.toolchain == 'wasm')
					end, {
					external_scaffolds['glad'],
				})

				defines {
					"H264DEC_TRACE",
					"_ASSERT_USED",
					"_RANGE_CHECK",
					"_DEBUG_PRINT",
					"_ERROR_PRINT",
					"_SAFE_OPENGL",
					"BROADWAY_IMPL",
					"RENDER=1",
				}
				removedefines {
					"DECODER_IMPL",
				}

				links {
					"shaders",
					"gitrev",
				}

				includedirs {
					"../Decoder/inc",
					"../Decoder/src",
					"../Decoder/src/utils",
				}

				files {
					'../Decoder/src/**.h',
					'../Decoder/inc/**.h',
					--'../Decoder/src/**.c',
					'../Decoder/src/missing.c',
					'../Decoder/src/Broadway.c',
					'../Decoder/src/Broadway_*.c',
					'../Decoder/src/brdw_*.c',
					'../Decoder/src/brdw_*.h',
					'../Decoder/src/h264bsd_*.h',
					'../Decoder/src/h264bsd_compare.c',
					'../Decoder/src/h264bsd_render*.c',
					'../Decoder/src/h264bsd_resolve.h',
					'../Decoder/src/h264bsd_resolve*.c',
					'../Decoder/src/utils/*.h',
					'../Decoder/src/utils/*.c',
				}

				-- implementation
				files {
					"../Decoder/src/h264bsd_transform.c",
					"../Decoder/src/h264bsd_util.c",
					"../Decoder/src/h264bsd_byte_stream.c",
					"../Decoder/src/h264bsd_seq_param_set.c",
					"../Decoder/src/h264bsd_pic_param_set.c",
					"../Decoder/src/h264bsd_slice_header.c",
					"../Decoder/src/h264bsd_slice_data.c",
					"../Decoder/src/h264bsd_macroblock_*.c",
					"../Decoder/src/h264bsd_stream.c",
					"../Decoder/src/h264bsd_vlc.c",
					"../Decoder/src/h264bsd_cavlc.c",
					"../Decoder/src/h264bsd_nal_unit.c",
					"../Decoder/src/h264bsd_neighbour.c",
					"../Decoder/src/h264bsd_storage.c",
					"../Decoder/src/h264bsd_slice_group_map.c",
					"../Decoder/src/h264bsd_intra_prediction.c",
					"../Decoder/src/h264bsd_inter_prediction.c",
					"../Decoder/src/h264bsd_reconstruct.c",
					"../Decoder/src/h264bsd_dpb.c",
					"../Decoder/src/h264bsd_image.c",
					"../Decoder/src/h264bsd_deblocking.c",
					"../Decoder/src/h264bsd_conceal.c",
					"../Decoder/src/h264bsd_vui.c",
					"../Decoder/src/h264bsd_pic_order_cnt.c",
					"../Decoder/src/h264bsd_decoder.c",
					"../Decoder/src/extraFlags.c",
					"../Decoder/src/H264SwDecApi.c",
				}

				buildoptions {
					"-fblocks",
					"-Wno-undef",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					defines     { "PLATFORM_WINDOWS" }
					links       { "OpenGL32" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "macosx" }
					defines      { "PLATFORM_MACOS" }

				configuration { "linux*" }
					defines      { "PLATFORM_LINUX" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration { "asmjs" }
					defines {
					}
					linkoptions {
						"-s INITIAL_MEMORY=40304640",
						"--embed-file " .. path.join(rootpath, "samples", "illusion.h264@test.h264"),
					}
				configuration { "wasm*" }
					defines {
					}
					linkoptions {
						"-s INITIAL_MEMORY=40304640",
						"--embed-file " .. path.join(rootpath, "samples", "illusion.h264@test.h264"),
					}
				configuration {}

				debugargs {
					"play",
					"-F",
					"../../samples/illusion.h264",
				}

		end, -- _create_projects()
	},
	["sdltest"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "test"
			project "sdltest"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				add_packages {
					external_scaffolds['khr'],
					external_scaffolds['sdl2'],
					external_scaffolds['glew'],
					external_scaffolds['win-unistd'],
				}

				defines {
					"USE_GLEW=1",
				}

				links {}

				includedirs {}

				files {
					'../Decoder/src/sdltest.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Wno-unused-parameter",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					links       { "OpenGL32" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
	["sdltest2"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "test"
			project "sdltest2"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				add_packages {
					external_scaffolds['khr'],
					external_scaffolds['sdl2'],
					external_scaffolds['win-unistd'],
				}

				add_packages_conditional(
					function()
						return not( _OPTIONS.toolchain == 'asmjs' or
									_OPTIONS.toolchain == 'wasm')
					end, {
					external_scaffolds['glad'],
				})

				defines {}

				links {}

				includedirs {}

				files {
					'../Decoder/src/sdltest2.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Wno-unused-parameter",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					links       { "OpenGL32" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
	["sdltest3"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "test"
			project "sdltest3"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				add_packages {
					external_scaffolds['khr'],
					external_scaffolds['sdl2'],
					external_scaffolds['win-unistd'],
				}

				add_packages_conditional(
					function()
						return not( _OPTIONS.toolchain == 'asmjs' or
									_OPTIONS.toolchain == 'wasm')
					end, {
					external_scaffolds['glad'],
				})

				defines {
					"_ASSERT_USED",
					"_RANGE_CHECK",
					"_DEBUG_PRINT",
					"_ERROR_PRINT",
					"_SAFE_OPENGL",
				}

				links {}

				includedirs {
					'../Decoder/inc',
					'../Decoder/src/',
				}

				files {
					'../Decoder/src/sdltest3.c',
					'../Decoder/src/utils/*.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
					"-Wno-unused-parameter",
					"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					links       { "OpenGL32" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
	["index2mb"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "test"
			project "index2mb"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				--add_packages {}

				defines {}

				links {}

				includedirs {}

				files {
					'../Decoder/src/index2mb.c',
					'../Decoder/src/utils/morton.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
	["mb2index"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			group "test"
			project "mb2index"
				language "C"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
				}

				build_c99()
				--add_packages {}

				defines {}

				links {}

				includedirs {}

				files {
					'../Decoder/src/mb2index.c',
					'../Decoder/src/utils/morton.c',
				}

				configuration {}

				buildoptions {
					"-fblocks",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "linux*" }
					links        { "dl", "m" }
					buildoptions { "-stdlib=libc++" }
					linkoptions  { "-rdynamic" }

				configuration {}

				debugargs {}

		end, -- _create_projects()
	},
}

create_packages_projects(core_projects)

-------------------------------------------------------------------------------
--
-- Patch _some_ of the scaffolded projects with different properties
--

local projectkinds = {
	"consoleapp",
	"windowedapp",
	"sharedlib",
}

for _,p in ipairs(solution().projects) do
	project (p.name)
	for __,blk in ipairs(p.blocks) do
		if blk.kind and table.icontains(projectkinds, blk.kind:lower()) then
			printf("configuring targetdir for project %s %s", colorize(ansicolors.cyan, p.name), colorize(ansicolors.green, blk.kind))
			configuration {}
			configuration { blk.keywords , "windows" }
				targetdir    (path.join(rootpath, "bin/windows"))
			configuration { blk.keywords , "linux*" }
				targetdir    (path.join(rootpath, "bin/linux"))
			configuration { blk.keywords , "macosx" }
				targetdir    (path.join(rootpath, "bin/darwin"))
			configuration { blk.keywords , "asmjs" }
				targetdir    (path.join(rootpath, "bin/asmjs"))
			configuration { blk.keywords , "wasm*" }
				targetdir    (path.join(rootpath, "bin/wasm"))
			configuration {}
		end
	end
end


-------------------------------------------------------------------------------
--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
-------------------------------------------------------------------------------
--
-- Use the release action to prepare source and binary packages for a new release.
-- This action isn't complete yet; a release still requires some manual work.
--
	dofile("release.lua")

	newaction {
		trigger     = "release",
		description = "Prepare a new release (incomplete)",
		execute     = dorelease
	}

-------------------------------------------------------------------------------
--
-- Use the embed action to refresh embed source.
--
	dofile("embed.lua")

	newaction {
		trigger     = "embed",
		description = "Refresh 'embed' sources",
		execute     = doembed
	}
-------------------------------------------------------------------------------
--
-- Use the generate action to generate sources that are generated from templates.
--
	dofile("generate.lua")

	newaction {
		trigger     = "generate",
		description = "Refresh generated sources",
		execute     = dogenerate
	}
-------------------------------------------------------------------------------
--
-- Use the emsdk action to install/update Emscripten SDK.
--
	dofile("emsdk.lua")
-------------------------------------------------------------------------------
--
-- Use the format action to format source files
--
	dofile("format.lua")

	newaction {
		trigger     = "format",
		description = "Format sources",
		execute     = doformat
	}
-------------------------------------------------------------------------------
--
-- Use the load-packages to load 3rd party packages
--
	function doloadpackages()
		load_packages(external_scaffolds)
	end

	newaction {
		trigger     = "loadpackages",
		description = "Load 3rd party packages",
		execute     = doloadpackages
	}
-------------------------------------------------------------------------------
