
z:
cd \dcu
del *.dcu

d:
cd \golden\bpl
del greference.*
del gdpkmessage.*
del gdpkwage.*
del replication.*

cd \golden\gedemin\greference
delphi32 -b greference.dpk
delphi32 -b gdpkmessage.dpk
delphi32 -b gdpkwage.dpk

rem cd \golden\gedemin\replication
rem delphi32 -b replication.dpk

pause

cd \golden\gedemin
delphi32 -b work.bpg

pause
delphi32 -b gedemin.bpg
