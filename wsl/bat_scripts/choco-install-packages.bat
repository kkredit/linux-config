:: Cycle through and install the packages
for /F "eol=#" %%G in (C:\Users\%USERNAME%\Desktop\packages.txt) do choco install %%G -fy
