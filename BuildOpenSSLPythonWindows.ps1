##### ----------------------------------
###    Run this script as administrator
##### ----------------------------------

##### ----------------------------------
#
# BuildPython.ps1
#
# This script downloads and installs the
# necessary prerequisites to build Python 
# with a custom OpenSSL version
#
# This script is intended to be run on a
# build machine or VM and not on a 
# production server
#
##### ----------------------------------

##### ----------------------------------
#
# Table of Contents:
# |- 0. Script Configuration
# |- 1. Install Chocolatey
# |- 2. Install Git, Perl and Visual Studio Build Tools with Chocolatey
# |- 3. Install 7-Zip
# |- 4. Build/Install OpenSSL
# |- 5. Build Python
#
##### ----------------------------------

### 0. Script Configuration
$7z_ver      = "2301-x64" # 7-Zip   - sourced from https://www.7-zip.org/a/7z$7z_ver.exe
$openssl_ver = "3.0.8"    # OpenSSL - sourced from https://www.openssl.org/source/openssl-$openssl_ver.tar.gz
$python_ver  = "3.11.3"   # Python  - sourced from https://www.python.org/ftp/python/$python_ver/Python-$python_ver.tgz

# Directories
$openssl_dir = "$base_dir\OpenSSL\"
# $python_dir = "$base_dir\" # NOTE: not implemented

$download_files = $true  # download OpenSSL and Python ($true/$false)
$preserve_files = $true  # preserve or delete downloaded OpenSSL and Python .tar.gz and .tgz files ($true/$false)

$base_dir = "$HOME\NCPA-Building_Python"
if (-not (Test-Path -Path $base_dir)){
    New-Item -ItemType Directory -Path $base_dir | Out-Null
}
cd $base_dir

# If OpenSSL is already built/installed in $openssl_dir, give option to not build
$build_openssl = $false
if ($download_files){
    if (Test-Path -Path "$openssl_dir\bin\openssl.exe"){
        $installed_version = & "$openssl_dir\bin\openssl.exe" version
        $installed_version = $installed_version -replace 'OpenSSL\s*','' -replace 's*([^\s]*).*','$1'
        $userInput = Read-Host -Prompt "`nOpenSSL $installed_version already installed. Do you want to download/build/install OpenSSL version $openssl_ver`? `n(y/n)"
        if ($userInput -eq "yes" -or $userInput -eq "y"){
            $build_openssl = $true
        }
    } else { $build_openssl = $true }
}

# Force PowerShell to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not $download_files){
    if (-not (Test-Path -Path "$base_url\OpenSSL")){ # check ssl
        Write-Host "OpenSSL not found, setting $download_files to $true"
        $download_files = $true
    }
    if (-not (Test-Path -Path "$base_url\Python-$python_ver")){
        Write-Host "Python not found, setting $download_files to $true"
        $download_files = $true
    }
}

### 1. Install Chocolatey
try {
    choco -v
    Write-Host "Chocolatey already installed, passing..."
} catch {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Add Chocolatey to system path just in case
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\ProgramData\chocolatey\bin", "Machine")

### 2. Install Git, Perl and Visual Studio Build Tools
Write-Host "Chocolatey installing prerequisites"
choco install git -y
choco install strawberryperl -y
#choco install visualstudio2019buildtools -y --add Microsoft.VisualStudio.Component.VC.140 -y #TODO: remove (Not found?)
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.Windows10SDK.18362"
choco install visualstudio2022community -y
choco install nasm -y

$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Add Perl, NASM, Git and nmake to the PATH
Write-Host "Adding prerequisites to PATH"
$env:Path += ";C:\Strawberry\perl\bin"
$env:Path += ";C:\Program Files\NASM"
$env:Path += ";C:\Program Files\Git\bin"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin"

if ($LASTEXITCODE -ne 0) { 
    Write-Host "Error details: $($Error[0])"
    Throw "Failed to add dependencies to Path"
}

### 3. Download and install 7-zip
if (Test-Path -Path "C:\Program Files\7-Zip"){
    Write-Host "7-Zip already installed"
} else {
    Write-Host "Installing 7-Zip..."
    $7ZipInstaller = "$base_dir\7z$7z_ver.exe"
    Invoke-WebRequest -Uri https://www.7-zip.org/a/7z$7z_ver.exe -Outfile $7ZipInstaller -UseBasicParsing
    Start-Process $7ZipInstaller -ArgumentList "/S" -Wait
    Remove-Item -Path $7ZipInstaller
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "Error details: $($Error[0])"
        Throw "Error downloading/installing/configuring 7-Zip"
    }
}
$env:Path += ";C:\Program Files\7-Zip"
refreshenv

### 4. Build OpenSSL
# OpenSSL takes three eternities to build, so we give the option to skip if they have it installed already
if ($build_openssl) {
    cd $base_dir
    ## 4.0 Download OpenSSL
    if($download_files){
        Write-Host "Downloading OpenSSL..."
        #TODO: uncomment Invoke-WebRequest -Uri https://www.openssl.org/source/openssl-$openssl_ver.tar.gz -OutFile $base_dir\openssl-$openssl_ver.tar.gz -ErrorAction Stop -UseBasicParsing
        if ($LASTEXITCODE -ne 0) { 
            Write-Host "Error details: $($Error[0])"
            Throw "Error downloading OpenSSL"
        }
    }

    Get-Command Start-Process

    if (Test-Path "C:\Program Files\7-Zip\7z.exe"){
        Write-Host "7z.exe found"
    } else {
        Write-Host "7z.exe not found"
    }

    Write-Host $env:Path

    ## 4.1 Extract OpenSSL
    Write-Host "Extracting OpenSSL..."
    # extract .tar.gz
    $openssl_tar = "$base_dir\openssl-$openssl_ver.tar.gz"
    Write-Host "Extracting $openssl_tar"
    try {
        Start-Process -FilePath "C:\Program Files\7-Zip\7z.exe" -ArgumentList "x `"$openssl_tar`" `-o`"$base_dir`" -y" -Wait
    } catch {
        Write-Host $_.Exception
    }
    while (Get-Process 7z -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 1
    }
    $openssl_tar_extracted = ($openssl_tar -replace '.tar.gz', '.tar')
    Start-Sleep -Seconds 30
    Do {
        Start-Sleep -Seconds 3
    }While(-not (Test-Path "$openssl_tar_extracted"))
    Write-Host "$openssl_tar_extracted found"
    # extract .tar
    Write-Host "Extracting $openssl_tar_extracted"
    try {
        Start-Process -FilePath '7z.exe' -ArgumentList "x `"$openssl_tar_extracted`" `-o`"$base_dir`" -y" -Wait
    } catch {
        Write-Host $_.Exception
    }
    while (Get-Process 7z -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 1
    }
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "Error details: $($Error[0])"
        Throw "Error extracting OpenSSL"
    }

    While(-not (Test-Path "openssl-$openssl_ver")){
        Start-Sleep -Seconds 1
    }
    cd "openssl-$openssl_ver\openssl-$openssl_ver" # $base_dir\openssl-$openssl_ver
    Write-Host "Path: $env:Path"

    ## 4.2 Build & Install OpenSSL
    Write-Host "Building and installing OpenSSL..."
    if(-not (Test-Path "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat")){
        Throw "Could not find Visual Studio VsDevCmd.bat"
    }
    cmd /c "`"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && perl Configure VC-WIN64A --prefix=$openssl_dir && nmake && nmake test && nmake install"
    $env:OPENSSL_ROOT_DIR = "$base_url\OpenSSL"
    $env:OPENSSL_DIR = "$base_url\OpenSSL"
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "Error details: $($Error[0])"
        Throw "Error configuring/building/installing OpenSSL"
    }

    # remove tarballs if set to
    if (-not $preserve_files){
        Remove-Item -Path $openssl_tar, ($openssl_tar -replace '\.tar.gz', '.tar')
    }
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "Error details: $($Error[0])"
        Throw "Error removing OpenSSL tarball"
    }
}

### 5. Build Python
cd $base_dir
if ($download_files -and $false){ #TODO: remove false
    ## 5.0 Download Python
    Write-Host "Downloading Python..."
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/$python_ver/Python-$python_ver.tgz -OutFile $base_dir\Python-$python_ver.tgz -ErrorAction Stop -UseBasicParsing
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "Error details: $($Error[0])"
        Throw "Error downloading Python"
    }

    ## 5.1 Extract Python
    Write-Host "Extracting Python..."
    $python_tar = "$base_dir\Python-$python_ver.tgz"
    Start-Process -FilePath '7z.exe' -ArgumentList "x `"$python_tar`" `-o`"$base_dir`" -y" -Wait
    $python_tar_extracted = $python_tar -replace '\.tgz$', '.tar'
    Start-Process -FilePath '7z.exe' -ArgumentList "x `"$python_tar_extracted`" `-o`"$base_dir\Python-$python_ver`" -y" -Wait
}

# Remove the .tgz and .tar files
if (-not $preserve_files){
    Remove-Item -Path $python_tar, $python_tar_extracted
}
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Error details: $($Error[0])"
    Throw "Error extracting Python"
}

$cpython_dir = "$base_dir\Python-$python_ver\Python-$python_ver\"

## 5.2 Add custom OpenSSL to the Python build
# 5.2.0 Copy OpenSSL files from 
#   $base_url\OpenSSL 
#     to
#   $base_url\Python-$python_ver\Python-$python_ver\externals\openssl-bin-version\your_cpu_architecture

Write-Host "Copying custom OpenSSL to Python build externals"
Copy-Item -Path "$base_dir\OpenSSL\include\openssl\applink.c" -Destination "$base_dir\OpenSSL\include\applink.c" -Force
$cpu_arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
switch($cpu_arch){
    "AMD64" { $cpu_arch = "amd64" }
    "x86"   { $cpu_arch = "win32" }
    "ARM64" { $cpu_arch = "arm64" }
}
$python_ssl_pattern = "openssl-bin-*"
$python_ssl = Get-ChildItem -Path "$cpython_dir\externals" `
    -Filter $python_ssl_pattern | Select-Object -ExpandProperty FullName
Copy-Item -Path "$python_ssl\$cpu_arch"     -Destination "$python_ssl\$cpu_arch-backup" -Force -Recurse
Copy-Item -Path "$base_dir\OpenSSL\include" -Destination "$python_ssl\$cpu_arch"        -Force -Recurse

$openssl_binfiles = "libcrypto-3-x64.dll", "libcrypto-3-x64.pdb", "libssl-3-x64.dll", "libssl-3-x64.pdb"
foreach ($binfile in $openssl_binfiles) {
    Copy-Item -Path "$base_dir\OpenSSL\bin\$binfile" -Destination "$python_ssl\$cpu_arch" -Force
}
$openssl_libfiles = "libcrypto.lib", "libssl.lib"
foreach ($libfile in $openssl_libfiles) {
    Copy-Item -Path "$base_dir\OpenSSL\lib\$libfile" -Destination "$python_ssl\$cpu_arch" -Force
}

# 5.2.1 Rewrite PCbuild\openssl.props to use our added OpenSSL 3 files instead of the old 1.1.1
Write-Host "Rewriting PCbuild\openssl.props"
$openssl_props = "$cpython_dir\PCbuild\openssl.props"
$content = Get-Content "$openssl_props" -Raw
$content = $content -replace '<_DLLSuffix>-1_1</_DLLSuffix>', '<_DLLSuffix>-3</_DLLSuffix>'
$content = $content -replace '<OpenSSLDLLSuffix>\$\(.*?\)</OpenSSLDLLSuffix>', '<_DLLSuffix Condition="$(Platform) == ''x64''">$(_DLLSuffix)-x64</_DLLSuffix>'
$content = $content -replace '<Target Name="_CopySSLDLL"\s+Inputs="\$\(.*?\)"\s+Outputs="\$\(.*?\)"\s+Condition="\$\(SkipCopySSLDLL\) == ''''"\s+AfterTargets="Build">', '<Target Name="_CopySSLDLL" Inputs="@(_SSLDLL)" Outputs="@(_SSLDLL->''$(OutDir)%(Filename)%(Extension)'')" AfterTargets="Build">'
$content = $content -replace '<Target Name="_CleanSSLDLL" Condition="\$\(SkipCopySSLDLL\) == ''''" BeforeTargets="Clean">', '<Target Name="_CleanSSLDLL" BeforeTargets="Clean">'
$content | Set-Content -Path $openssl_props


## 5.3 Build Python
# Add openssl to build:
Write-Host "Building Python..."
cmd /c "`"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && $cpython_dir\PCbuild\build.bat"
Write-Host $pwd
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Error details: $($Error[0])"
    Throw "Error building Python"
}

# return python executable for build_windows.bat
return "$cpython_dir\PCbuild\$cpu_arch\python.exe"
