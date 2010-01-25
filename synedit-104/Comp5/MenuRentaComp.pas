
unit MenuRentaComp;     

interface
                                          
uses
  Classes,           xUpgTable,    xDBLookupStored,
  xDBLookU,          mmComboBox,   xCtrlTreeGrid,    xCtrlGrid,
  xDBDateTimePicker, UserLogin,    mTabSetVer,
  mTabSetHor,        mmTopPanel,   mmStateMenu,      mmRadioButtonEx,
  mmRunTimeStore,    mmOptions,    mmJumpController, mmLabel,
  mmDBSearch,        mmDBListView, mmDBGridTreeEx,   mBitButton,
  CompGrid,          mmCheckBoxEx, mmDBGrid,         mmDBGridCheck,
  mmDBGridTree,      xDBCheck,     xDBCGrid,         Operation,
  xnextcod,     gsGanttCalendar,  gsAbout,
  gsAboutBase;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('x-DataBase',      [TxCompDBGrid]);
  RegisterComponents('x-Button',        [TmBitButton]);
  RegisterComponents('x-VisualControl', [TmmCheckBoxEx]);
  RegisterComponents('x-VisualControl', [TmmDBCheckBoxEx]);
  RegisterComponents('x-VisualControl', [TmmComboBox]);
  RegisterComponents('x-VisualControl', [TmmDBComboBox]);
  RegisterComponents('x-DataBase',      [TmmDBGrid]);
  RegisterComponents('x-DataBase',      [TmmDBGridCheck]);
  RegisterComponents('x-DataBase',      [TmmDBGridTree]);
  RegisterComponents('x-DataBase',      [TmmDBGridTreeEx]);
  RegisterComponents('x-DataBase',      [TmmDBListView]);
  RegisterComponents('x-NonVisual',     [TmmDBSearch]);
  RegisterComponents('x-NonVisual',     [TmmJumpController]);
  RegisterComponents('x-DataBase',      [TmmLabel]);
  RegisterComponents('x-DataBase',      [TmmCheckBox]);
  RegisterComponents('x-DataBase',      [TmmOptions]);
  RegisterComponents('x-VisualControl', [TmmRadioButtonEx]);
  RegisterComponents('x-VisualControl', [TmmRadioGroup]);
  RegisterComponents('x-VisualControl', [TmmDBRadioGroup]);
  RegisterComponents('x-DataBase',      [TmmRunTimeStore]);
  RegisterComponents('x-VisualControl', [TmmStateMenu]);
  RegisterComponents('x-Misc',          [TmmInterfaceManager]);
  RegisterComponents('x-Misc',          [TmmTopPanel]);
  RegisterComponents('x-Misc',          [TmmBottomPanel]);
  RegisterComponents('x-Misc',          [TmmLeftPanel]);
  RegisterComponents('x-Misc',          [TmmFormPanel]);
  RegisterComponents('x-VisualControl', [TmTabSetHor]);
  RegisterComponents('x-VisualControl', [TmTabSetVer]);
  RegisterComponents('gsNV',            [TUserLogin]);
  RegisterComponents('x-DataBase',      [TxCtrlGrid]);
  RegisterComponents('x-DataBase',      [TxCtrlGridTree]);
  RegisterComponents('x-DataBase',      [TxDBCheckGrid]);
  RegisterComponents('x-DataBase',      [TxDBDateTimePicker]);
  RegisterComponents('x-DataBase',      [TxDBLookupCombo]);
  RegisterComponents('x-DataBase',      [TxDBLookupCombo2]);
  RegisterComponents('x-DataBase',      [TxDBNextCode]);
  RegisterComponents('gsDB',            [TxUpgTable]);
  RegisterComponents('gsDB',            [TxUpgQuery]);
  RegisterComponents('gsNV',            [TgsGantt]);
  RegisterComponents('gsNV',            [TgsAbout]);
end;

end.
