// ShlTanya, 24.02.2019

{++

   Copyright © 2000-2013 by Golden Software

   Модуль

     dlgCurrRate_unit

   Описание

     Добавление курса валюты

   Автор

     Smirnov Anton
     

   История

     ver    date         who    what

     1.00 - 27.08.2000 - SAI - Первая версия
     2.00 - 18.06.2002 - Julie - Modification

 --}

unit gdc_dlgCurrRate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, IBCustomDataSet, IBUpdateSQL, Db, IBQuery, ActnList,
  DBCtrls, xDateEdits, ExtCtrls, IBDatabase, gd_resourcestring,
  gsIBLookupComboBox, gdcBase, gdcCurr, Menus,
  gdc_dlgTR_unit, xCalculatorEdit;

type
  Tgdc_dlgCurrRate = class(Tgdc_dlgTR)
    Label1: TLabel;
    xdbForDate: TxDateDBEdit;
    Label3: TLabel;
    dbeVal: TxDBCalculatorEdit;
    dblcbFromCurr: TgsIBLookupComboBox;
    dblcbToCurr: TgsIBLookupComboBox;
    Label2: TLabel;
    chbxTime: TCheckBox;
    xdeTime: TxDateEdit;
    iblkupRegulator: TgsIBLookupComboBox;
    xdbeAmount: TxDBCalculatorEdit;
    Label4: TLabel;
    Label5: TLabel;
    procedure chbxTimeClick(Sender: TObject);

  public
    procedure SetupRecord; override;
    procedure BeforePost; override;
  end;

var
  gdc_dlgCurrRate: Tgdc_dlgCurrRate;

implementation

uses
  gd_ClassList;

{$R *.DFM}

procedure Tgdc_dlgCurrRate.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DT: TDateTime;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCURRRATE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCURRRATE', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCURRRATE',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCURRRATE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if chbxTime.Visible then
  begin
    DT := gdcObject.FieldByName('fordate').AsDateTime;
    ReplaceTime(DT, xdeTime.Time);
    gdcObject.FieldByName('fordate').AsDateTime := DT;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCURRRATE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCURRRATE', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCurrRate.chbxTimeClick(Sender: TObject);
begin
  xdeTime.Visible := chbxTime.Checked;
end;

procedure Tgdc_dlgCurrRate.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  var
    T: TDateTime;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCURRRATE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCURRRATE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCURRRATE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCURRRATE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCURRRATE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  T := Frac(gdcObject.FieldByName('fordate').AsDateTime);
  if T = 0 then
  begin
    chbxTime.Checked := False;
    xdeTime.Visible := False;
  end else
  begin
    chbxTime.Checked := True;
    xdeTime.Visible := True;
    xdeTime.Time := T;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCURRRATE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCURRRATE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgCurrRate);

finalization
  UnRegisterFrmClass(Tgdc_dlgCurrRate);
end.
