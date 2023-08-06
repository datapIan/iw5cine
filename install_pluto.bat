@echo off
md "%localappdata%\Plutonium\storage\iw5\mods"
xcopy /s "%cd%\iw5cine" "%localappdata%\Plutonium\storage\iw5\mods\iw5cine\"
echo iw5cine (pluto) installed successfully.
pause