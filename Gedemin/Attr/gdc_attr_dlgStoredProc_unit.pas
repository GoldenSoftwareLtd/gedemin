// ShlTanya, 03.02.2019

unit gdc_attr_dlgStoredProc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, ComCtrls, DBCtrls, Mask, ExtCtrls,
  SynEdit, SynMemo, SynEditHighlighter, SynHighlighterSQL, at_Classes, IBSQL,
  IBDatabase, Menus, gdc_dlgG_unit, TB2Item, TB2Dock, TB2Toolbar,
  gsSearchReplaceHelper;

type
  Tgdc_attr_dlgStoredProc = class(Tgdc_dlgGMetaData)
    SynSQLSyn: TSynSQLSyn;
    IBTransaction: TIBTransaction;
    actSearch: TAction;
    actReplace: TAction;
    actSearchNext: TAction;
    pnlBack: TPanel;
    pcStoredProc: TPageControl;
    tsNameSP: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    dbedProcedureName: TDBEdit;
    dbmDescription: TDBMemo;
    tsBodySP: TTabSheet;
    tbdText: TTBDock;
    tbtText: TTBToolbar;
    tbiSearch: TTBItem;
    tbiReplace: TTBItem;
    smProcedureBody: TSynMemo;
    procedure pcStoredProcChange(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actSearchUpdate(Sender: TObject);
    procedure actSearchNextExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure smProcedureBodySpecialLineColors(Sender: TObject;
      Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure smProcedureBodyChange(Sender: TObject);
    procedure smProcedureBodyEnter(Sender: TObject);
    procedure smProcedureBodyExit(Sender: TObject);

  private
    FSearchReplaceHelper: TgsSearchReplaceHelper;

  protected
    procedure BeforePost; override;
    procedure InvalidateForm; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gdc_attr_dlgStoredProc: Tgdc_attr_dlgStoredProc;

implementation

{$R *.DFM}

uses
  gdcBase,
  gdcMetaData,
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , ib;

{ Tgdc_attr_dlgStoredProc }

procedure Tgdc_attr_dlgStoredProc.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  ClearError;

  if smProcedureBody.Text = '' then
  begin
    (gdcObject as TgdcStoredProc).CheckObjectName;
    smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetProcedureText;
  end;

  gdcObject.FieldByName('rdb$procedure_source').AsString := smProcedureBody.Text;

  inherited;

  q := TIBSQL.Create(nil);
  IBTransaction.StartTransaction;
  try
    q.Transaction := IBTransaction;
    q.SQL.Text := gdcObject.FieldByName('rdb$procedure_source').AsString;
    q.ParamCheck := False;
    try
      q.Prepare;
      q.CheckValidStatement;
    except
      on E: Exception do
      begin
        ExtractErrorLine(E.Message);
        raise EgdcIBError.Create(Format('При сохранении процедуры возникла следующая ошибка: %s',
          [E.Message]));
      end;
    end;
  finally
    q.Free;
    IBTransaction.RollBack;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.pcStoredProcChange(Sender: TObject);
begin
  if pcStoredProc.ActivePage = tsBodySP then
  begin
    if smProcedureBody.Text = '' then
    begin
      (gdcObject as TgdcStoredProc).CheckObjectName;
      smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetProcedureText;
    end;
  end;
end;

constructor Tgdc_attr_dlgStoredProc.Create(AnOwner: TComponent);
begin
  inherited;
  FSearchReplaceHelper := TgsSearchReplaceHelper.Create(smProcedureBody);
end;

destructor Tgdc_attr_dlgStoredProc.Destroy;
begin
  FreeAndNil(FSearchReplaceHelper);
  inherited;
end;

procedure Tgdc_attr_dlgStoredProc.actSearchExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Search;
end;

procedure Tgdc_attr_dlgStoredProc.actReplaceExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Replace;
end;

procedure Tgdc_attr_dlgStoredProc.actSearchUpdate(Sender: TObject);
begin
  actSearch.Enabled := smProcedureBody.Lines.Count > 0;
  actSearchNext.Enabled := actSearch.Enabled;
  actReplace.Enabled := actSearch.Enabled;
end;

procedure Tgdc_attr_dlgStoredProc.actSearchNextExecute(Sender: TObject);
begin
  FSearchReplaceHelper.SearchNext;
end;

procedure Tgdc_attr_dlgStoredProc.InvalidateForm;
begin
  smProcedureBody.Invalidate;
end;

procedure Tgdc_attr_dlgStoredProc.smProcedureBodySpecialLineColors(
  Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
begin
  if Line = FErrorLine then
  begin
    Special := True;
    BG := clRed;
    FG := clWhite;
  end;  
end;

procedure Tgdc_attr_dlgStoredProc.smProcedureBodyChange(Sender: TObject);
begin
  ClearError;
end;

procedure Tgdc_attr_dlgStoredProc.smProcedureBodyEnter(Sender: TObject);
begin
  btnOk.Default := False;
end;

procedure Tgdc_attr_dlgStoredProc.smProcedureBodyExit(Sender: TObject);
begin
  btnOk.Default := True;
end;

initialization
  RegisterFrmClass(Tgdc_attr_dlgStoredProc);

finalization
  UnRegisterFrmClass(Tgdc_attr_dlgStoredProc);
end.
