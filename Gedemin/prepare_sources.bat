for /R %%f in (*.sample) do copy /Y %%f %%~dpnf

md DCU
md BPL
cd EXE
md UDF
cd ..

echo Don't forget change Delphi path in *.cfg files!
