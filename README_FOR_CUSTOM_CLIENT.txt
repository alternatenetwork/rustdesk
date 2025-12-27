cp /ANT.png /flutter/assets/logo.png

Powershell:
python .\build.py --flutter --skip-portable-pack

Rename
'C:\Users\John\Documents\Git\rustdesk\flutter\build\windows\x64\runner\Release\ANTConnect.exe'

cd res\msi
python preprocess.py -d ..\..\flutter\build\windows\x64\runner\Release --app-name "ANTConnect" --manufacturer "Alternate Network Technologies"

Clean the MSI build:
  cd /mnt/c/Users/John/Documents/Git/rustdesk/res/msi
  rm -Rf Package/bin
  rm -Rf x64

Visual studio tools:
cd C:\Users\John\Documents\Git\rustdesk\res\msi
.\nuget.exe restore
msbuild msi.sln /p:Configuration=Release

File:
C:\Users\John\Documents\Git\rustdesk\res\msi\Package\bin\x64\Release\en-us