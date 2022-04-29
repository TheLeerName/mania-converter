powershell -command "Set-ExecutionPolicy Unrestricted -Force"
powershell -command "iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))"
powershell -command "Install-BoxstarterPackage https://raw.githubusercontent.com/nodejs/node/master/tools/bootstrap/windows_boxstarter -DisableReboots"
npm i nexe -g
npm install zip-local