program IBReplicator;


uses
  FastMM4,
  FastMove,
  Forms,
  Windows,
  main_frmIBReplicator_unit in 'main_frmIBReplicator_unit.pas' {mainIBReplicator},
  rpl_DBRegistrar_unit in 'rpl_DBRegistrar_unit.pas',
  rpl_ReplicationServer_unit in 'rpl_ReplicationServer_unit.pas',
  rpl_ReplicationManager_unit in 'rpl_ReplicationManager_unit.pas',
  rpl_mnRelations_unit in 'rpl_mnRelations_unit.pas',
  rpl_GlobalVars_unit in 'rpl_GlobalVars_unit.pas',
  rpl_DropDownForm_unit in 'rpl_DropDownForm_unit.pas' {DropDownForm},
  XPComboBox in '..\XPComponents\XPComboBox.pas',
  XPTreeView in '..\XPComponents\XPTreeView.pas',
  XPListView in '..\XPComponents\XPListView.pas',
  rpl_dlg_ConflictResolution_unit in 'rpl_dlg_ConflictResolution_unit.pas' {dlgConflictResolution},
  rpl_frameTable_unit in 'rpl_frameTable_unit.pas' {frameTable: TFrame},
  rpl_frameTableData_unit in 'rpl_frameTableData_unit.pas' {frameTableData: TFrame},
  rpl_frameFormView_unit in 'rpl_frameFormView_unit.pas' {frameFormView: TFrame},
  rpl_frameFormViewLine_unit in 'rpl_frameFormViewLine_unit.pas' {frameFormViewLine},
  rpl_CommandLineInterpreter_unit in 'rpl_CommandLineInterpreter_unit.pas',
  xp_frmDropDown_unit in '..\XPDBComponents\xp_frmDropDown_unit.pas' {frmDropDown},
  xp_frmFKDropDown_unit in '..\XPDBComponents\xp_frmFKDropDown_unit.pas' {frmFKDropDown},
  xp_frmCalcDropDown_unit in '..\XPDBComponents\xp_frmCalcDropDown_unit.pas' {frmCalcDropDown},
  xp_frmMemoDropDown_unit in '..\XPDBComponents\xp_frmMemoDropDown_unit.pas' {frmMemoDropDown},
  xp_frmDateTimeDropDown_unit in '..\XPDBComponents\xp_frmDateTimeDropDown_unit.pas' {frmDateTimeDropDown},
  rpl_ManagerRegisterDB_unit in 'rpl_ManagerRegisterDB_unit.pas' {frmManagerRegisterDB},
  rpl_dmImages_unit in 'rpl_dmImages_unit.pas' {dmImages: TDataModule},
  rpl_frmBackUp_unit in 'rpl_frmBackUp_unit.pas' {frmBackup},
  rpl_frmRestore_unit in 'rpl_frmRestore_unit.pas' {frmRestore},
  rpl_ViewRPLLog_unit in 'rpl_ViewRPLLog_unit.pas' {frmRPLLog},
  rpl_ViewRPLFile_unit in 'rpl_ViewRPLFile_unit.pas' {frmViewRPLFile},
  rpl_frmEditTrigger_unit in 'rpl_frmEditTrigger_unit.pas' {frmEditTrigger};

//{$R *.TLB}

{$R *.res}
begin
  if not CommandLineInterpreter.Execute then
  begin
    Application.Initialize;
    Application.Title := 'ИБ репликатор';
    Application.CreateForm(TdmImages, dmImages);
  Application.CreateForm(TmainIBReplicator, mainIBReplicator);
  if CommandLineInterpreter.NoWallImage then
      mainIBReplicator.imgWall.Picture:= nil;
    Application.Run;
  end;
end.
