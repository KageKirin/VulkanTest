--
-- Script to install and update Emscripten SDK from its git source repo
--

local script_path = path.getdirectory(_SCRIPT)
local emsdk_path = path.join(script_path, "..", "bin", "emsdk")
local emsdk_repo = "https://github.com/emscripten-core/emsdk.git"

function install_udpdate_emsdk()
	if not os.isdir(emsdk_path) then
        os.executef('git clone %s %s', emsdk_repo, emsdk_path)
    end
    assert(os.isdir(emsdk_path))
    if os.isdir(emsdk_path) then
        local pwd = os.getcwd()
        os.chdir(emsdk_path)
        os.execute('git pull')
        os.execute('emsdk install latest')
        os.execute('emsdk activate latest')
        os.chdir(pwd)
    end
end

function shell_emsdk()
    if os.is('windows') then
        os.executef('%s/emsdk_env.bat', emsdk_path)
    else
        os.executef('source %s/emsdk_env.sh', emsdk_path)
    end
end

newaction {
    trigger     = "emsdk-install",
    description = "Install Emscripten SDK",
    execute     = install_udpdate_emsdk
}

newaction {
    trigger     = "emsdk-update",
    description = "Update Emscripten SDK",
    execute     = install_udpdate_emsdk
}

newaction {
    trigger     = "emsdk-env",
    description = "Install/Update Emscripten SDK",
    execute     = shell_emsdk
}
