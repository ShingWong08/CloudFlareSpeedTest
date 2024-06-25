@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

title WARP Endpoint IP 一鍵優選腳本

echo 1. WARP IPv4 Endpoint IP 優選
echo 2. WARP IPv6 Endpoint IP 優選
echo -------------
echo -1. 退出

REM 提示用戶輸入選項
choice /c 12N /N /M "請輸入選項："

REM 如果用戶選擇1，設置Version為IPv4
if "%errorlevel%"=="1" set Version=IPv4

REM 如果用戶選擇2，設置Version為IPv6
if "%errorlevel%"=="2" set Version=IPv6

REM 如果用戶選擇N，退出程序
if "%errorlevel%"=="3" exit

echo %Version% 選擇成功，正在優選中...

REM 根據Version設置FileName為IPv4.txt或IPv6.txt
set FileName=%Version%.txt

REM 跳轉到對應的GetIPv4或GetIPv6標籤
goto Get%Version%

:GetIPv4
REM 遍歷 IPv4 文件中的每一行
for /f "delims=" %%i in (%FileName%) do (
    set /a rand=!random!
    set !rand!_%%i=randomsort
)

REM 對 randomsort 變量進行排序
for /f "tokens=2,3,4 delims=_.=" %%i in ('set ^| findstr =randomsort ^| sort /+11') do (
    REM 調用 RandomIPv4CIDR 子程序生成隨機的 IPv4 CIDR
    call :RandomIPv4CIDR

    REM 如果該 IPv4 地址和 CIDR 未定義，則設置為 anycastip，並增加計數器
    if not defined %%i.%%j.%%k.!CIDR! (
        set %%i.%%j.%%k.!CIDR!=anycastip
        set /a n+=1
    )

    REM 如果計數器達到 100，則跳轉到 GetIP
    if !n! EQU 100 (
        goto GetIP
    )
)
goto GetIPv4

:GetIPv6
REM 遍歷 IPv6 文件中的每一行
for /f "delims=" %%i in (%FileName%) do (
    set /a rand=!random!
    set !rand!_%%i=randomsort
)

REM 對 randomsort 變量進行排序
for /f "tokens=2,3,4 delims=_:=" %%i in ('set ^| findstr =randomsort ^| sort /+11') do (
    REM 調用 RandomIPv6CIDR 子程序生成隨機的 IPv6 CIDR
    call :RandomIPv6CIDR

    REM 如果該 IPv6 地址和 CIDR 未定義，則設置為 anycastip，並增加計數器
    if not defined [%%i:%%j:%%k::!CIDR!] (
        set [%%i:%%j:%%k::!CIDR!]=anycastip
        set /a n+=1
    )

    REM 如果計數器達到 100，則跳轉到 GetIP
    if !n! EQU 100 (
        goto GetIP
    )
)
goto GetIPv6

:RandomIPv4CIDR
set /a CIDR=%random%%%256
goto :EOF

:RandomIPv6CIDR
set String=0123456789abcdef
set CIDR=
for /L %%i in (1,1,4) do (
    set /a r=%random%%%16
    set CIDR=!CIDR!!String:~%r%,1!
)
goto :EOF

:GetIP
REM 刪除 IP.txt 文件 和 Result.csv 文件
del IP.txt > nul 2>&1
del Result.csv > nul 2>&1

REM 清空 randomsort 變量
for /f "tokens=1 delims==" %%i in ('set ^| findstr =randomsort') do (
    set %%i=
)

REM 將 anycastip 寫入 IP.txt 文件
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
    echo %%i>>IP.txt
)

REM 清空 anycastip 變量
for /f "tokens=1 delims==" %%i in ('set ^| findstr =anycastip') do (
    set %%i=
)

Warp -max 1000 --output Result.csv
del IP.txt > nul 2>&1
