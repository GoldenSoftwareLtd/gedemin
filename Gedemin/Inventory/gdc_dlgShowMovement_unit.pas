unit gdc_dlgShowMovement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_createable_form, Storages, 
  StdCtrls, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, Db,
  IBCustomDataSet, IBDatabase, gdcClasses, ActnList;

type
  Tgdc_dlgShowMovement = class(TgdcCreateableForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Panel5: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ibgrDocument: TgsIBGrid;
    ibgrEntry: TgsIBGrid;
    Button1: TButton;
    Button2: TButton;
    ibgrLine: TgsIBGrid;
    dsLine: TDataSource;
    dsDocument: TDataSource;
    dsEntry: TDataSource;
    ibdsDocument: TIBDataSet;
    ibdsEntry: TIBDataSet;
    ibtrCommon: TIBTransaction;
    Button3: TButton;
    ActionList1: TActionList;
    Action1: TAction;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
  private
    FgdcDocumentLine: TgdcDocument;
    procedure Run;
    procedure SetgdcDocumentLine(const Value: TgdcDocument);
    { Private declarations }
  public
    { Public declarations }
    procedure LoadSettings; override;
    procedure SaveSettings; override;


    property gdcDocumentLine: TgdcDocument read FgdcDocumentLine write SetgdcDocumentLine;

  end;

var
  gdc_dlgShowMovement: Tgdc_dlgShowMovement;

implementation

{$R *.DFM}

{ Tgdc_dlgShowMovement }

uses gdcBaseInterface, gdcBase, gd_ClassList, gdc_dlgInvDocument_unit;

procedure Tgdc_dlgShowMovement.Run;
begin
  if Assigned(gdcDocumentLine) then
  begin
    ibdsEntry.Close;
    ibdsDocument.Close;
    SetTID(ibdsDocument.ParamByName('dockey'), GetTID(gdcDocumentLine.FieldByName('id')));
    ibdsDocument.Open;
    ibdsEntry.Open;
  end;
end;

procedure Tgdc_dlgShowMovement.FormCreate(Sender: TObject);
begin
  ibtrCommon.DefaultDatabase := gdcBaseManager.Database;
  ibtrCommon.StartTransaction;
end;

procedure Tgdc_dlgShowMovement.SetgdcDocumentLine(
  const Value: TgdcDocument);
var
  Stream: TMemoryStream;
  gdcDataSet: TgdcBase;
begin
  FgdcDocumentLine := Value;
  if Assigned(FgdcDocumentLine) then
  begin
    dsLine.DataSet := FgdcDocumentLine;
    if Assigned(FgdcDocumentLine.MasterSource) and Assigned(FgdcDocumentLine.MasterSource.DataSet) then
    begin
      gdcDataSet := FgdcDocumentLine.MasterSource.DataSet as TgdcBase;
      if gdcDataSet.GetDlgForm is TdlgInvDocument then
      begin
        Stream := TMemoryStream.Create;
        try
          (gdcDataSet.GetDlgForm as TdlgInvDocument).TopGrid.SaveToStream(Stream);
          Stream.Position := 0;
          ibgrLine.LoadFromStream(Stream);
          ibgrLine.ShowFooter := False;
          ibgrLine.ShowTotals := False;
          ibgrLine.Options := ibgrLine.Options - [dgEditing];
          ibgrLine.ReadOnly := True;
        finally
          Stream.Free;
        end;
      end;
    end;
    Run;
  end;

end;

procedure Tgdc_dlgShowMovement.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSHOWMOVEMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSHOWMOVEMENT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSHOWMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSHOWMOVEMENT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSHOWMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;


  UserStorage.LoadComponent(ibgrDocument, ibgrDocument.LoadFromStream,
      '');

  UserStorage.LoadComponent(ibgrEntry, ibgrEntry.LoadFromStream,
      '');

{  UserStorage.LoadComponent(ibgrLine, ibgrLine.LoadFromStream,
      '');}

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSHOWMOVEMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSHOWMOVEMENT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgShowMovement.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSHOWMOVEMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSHOWMOVEMENT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSHOWMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSHOWMOVEMENT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSHOWMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  UserStorage.SaveComponent(ibgrDocument, ibgrDocument.SaveToStream,
      '');

  UserStorage.SaveComponent(ibgrEntry, ibgrEntry.SaveToStream,
      '');

  UserStorage.SaveComponent(ibgrLine, ibgrLine.SaveToStream,
      '');

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSHOWMOVEMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSHOWMOVEMENT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgShowMovement.Action1Execute(Sender: TObject);
var
  gdcDocument: TgdcDocument;
begin
  gdcDocument := TgdcDocument.Create(Self);
  try
    gdcDocument.SubSet := 'ByID';
    gdcDocument.ID := GetTID(ibdsDocument.FieldByName('id'));
    gdcDocument.Open;
    gdcDocument.EditDialog;
  finally
    gdcDocument.Free;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgShowMovement);
finalization
  UnRegisterFrmClass(Tgdc_dlgShowMovement);


end.
