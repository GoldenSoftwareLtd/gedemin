program Install;

uses
  Forms,
  jclSysInfo,
  gdHelp_body,
  Windows,
  Appevnts,
  InstallMainFrom_unit in 'InstallMainFrom_unit.pas' {InstallMainFrom},
  gsGedeminInstall in 'gsGedeminInstall.pas',
  gsSysUtils in 'gsSysUtils.pas',
  inst_files in 'inst_files.pas',
  inst_dlgSelectDatabase_unit in 'inst_dlgSelectDatabase_unit.pas' {dlgSelectDatabase},
  inst_const in 'inst_const.pas',
  inst_InstallList in 'inst_InstallList.pas',
  gsShortCut in 'gsShortCut.pas',
  inst_var in 'inst_var.pas',
  inst_frmBackGround_unit in 'inst_frmBackGround_unit.pas' {frmBackGround},
  inst_dlgRenameFile_unit in 'inst_dlgRenameFile_unit.pas' {dlgRenameFile},
  inst_frmProgress_unit in 'inst_frmProgress_unit.pas' {frmProgress},
  inst_service_config2 in 'inst_service_config2.pas',
  inst_memsize in 'inst_memsize.pas',
  inst_dlgChooseDB_unit in 'inst_dlgChooseDB_unit.pas' {dlgChooseDB},
  inst_dlgSelfExtrInfo_unit in 'inst_dlgSelfExtrInfo_unit.pas' {inst_dlgSelfExtrInfo},
  gdApplicationEventsHandler in '..\Gedemin\gdApplicationEventsHandler.pas';

{$R *.RES}

  const
    sWinVer: String = '';

  var
    ApplicationEventsHandler: TgdApplicationEventsHandler;
    FApplicationEvents: TApplicationEvents;

begin

  if IsWin95 or IsWin95OSR2 then
    sWinVer := 'Windows 95'
  else                              
    if IsWinNT3 or IsWinNT4 then
      sWinVer := 'Windows NT';
                            
  if sWinVer > '' then
  begin                     
    MessageBox(0, PChar(sWinVer + ' не поддерживается! ' + #13#10 +
                        'Установка комплекса Гедымин невозможна.'),
      'Внимание!', mb_OK or mb_IconStop or mb_TaskModal);
    Exit;
  end;
  
  ApplicationEventsHandler := TgdApplicationEventsHandler.Create;
  try
    FApplicationEvents := TApplicationEvents.Create(Application);
//    FApplicationEvents.OnException := ApplicationEventsHandler.ApplicationEventsException;
    FApplicationEvents.OnHelp := ApplicationEventsHandler.ApplicationEventsHelp;
//    FApplicationEvents.OnShortCut :=  ApplicationEventsHandler.ApplicationEventsShortCut;

    Application.Initialize;
    Application.Title := 'Установка комплекса Гедымин';
    Application.HelpFile := 'Gedemin\Help\GedyminGS.chm';
    Application.CreateForm(TfrmBackGround, frmBackGround);
  Application.Run;

  finally
    ApplicationEventsHandler.Free;
  end;

end.
