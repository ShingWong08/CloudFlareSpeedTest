@echo off
chcp 65001 > nul
CloudflareST.exe ^
-n 1000 ^
-t 3 ^
-dn 15 ^
-dt 7 ^
-tp 443 ^
-p 15 ^
-f IPv4.txt ^
-o Result-IPv4.csv