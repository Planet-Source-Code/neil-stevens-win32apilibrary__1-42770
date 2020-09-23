mc %1.mc
rc -r -fo %1.res %1.rc
link -dll -noentry -out:%2.dll %1.res
del %SystemRoot%\system32\%2.dll
copy %2.dll %SystemRoot%\system32\