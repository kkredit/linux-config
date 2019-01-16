:: Define programs to install
set PACKAGES= ^
    googlechrome ^
    firefox ^
    7zip.install ^
    windirstat ^
    notepadplusplus ^
    hexedit ^
    meld

:: Install all the packages
for %%G in (%PACKAGES%) do choco install %%G -fy
