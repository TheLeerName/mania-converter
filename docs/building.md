# Building Mania Converter CMD Version
1. Install [**nodejs**](https://nodejs.org)
2. Type in cmd these commands, or just open `docs/prebuild.bat` file in folder with source code:
- `powershell -command "Set-ExecutionPolicy Unrestricted -Force"`
- `powershell -command "iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))"`
- `powershell -command "Install-BoxstarterPackage https://raw.githubusercontent.com/nodejs/node/master/tools/bootstrap/windows_boxstarter -DisableReboots"`
- `npm i nexe -g`
- `npm install`
3. Compile it with command: `nexe -t x86-6.0.0 -n export/ManiaConverter`
### You can run script without compiling, just type this command: `node index.js`