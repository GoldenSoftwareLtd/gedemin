unit at_frmNSObjects_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, Db, IBCustomDataSet, IBDatabase, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, ActnList, TB2Dock, TB2Toolbar, dmDatabase_unit,
  dmImages_unit, TB2Item, gdcBase, gdcBaseInterface;

type
  Tat_frmNSObjects = class(TCreateableForm)
    TBDock: TTBDock;
    tb: TTBToolbar;
    ActionList: TActionList;
    sb: TStatusBar;
    gsIBGrid1: TgsIBGrid;
    ibtr: TIBTransaction;
    ibds: TIBDataSet;
    ds: TDataSource;
    actOpenObject: TAction;
    TBItem1: TTBItem;
    actAddToNamespace: TAction;
    TBItem2: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actOpenObjectUpdate(Sender: TObject);
    procedure actOpenObjectExecute(Sender: TObject);
    procedure dsDataChange(Sender: TObject; Field: TField);
    procedure actAddToNamespaceUpdate(Sender: TObject);
    procedure actAddToNamespaceExecute(Sender: TObject);

  private
    procedure DoOnClick(Sender: TObject);
    function GetObject: TgdcBase;

  public
    constructor Create(AnOwner: TComponent); override;
  end;

var
  at_frmNSObjects: Tat_frmNSObjects;

implementation

{$R *.DFM}

uses
  gd_classlist, gdcNamespace, IBSQL, at_AddToSetting;

procedure Tat_frmNSObjects.FormCreate(Sender: TObject);
begin
  ibtr.StartTransaction;
  ibds.Open;
end;

procedure Tat_frmNSObjects.actOpenObjectUpdate(Sender: TObject);
begin
  actOpenObject.Enabled := not ibds.EOF;
end;

procedure Tat_frmNSObjects.actOpenObjectExecute(Sender: TObject);
var
  Obj: TgdcBase;
begin
  Obj := GetObject;
  if Obj <> nil then
  try
    Obj.EditDialog;
  finally
    Obj.Free;
  end;
end;

procedure Tat_frmNSObjects.dsDataChange(Sender: TObject; Field: TField);
var
  I: Integer;
  SL: TStringList;
  TBI: TTBItem;
begin
  for I := tb.Items.Count - 1 downto 0 do
  begin
    if tb.Items[I].Tag > 0 then
      tb.Items[I].Free;
  end;

  SL := TStringList.Create;
  try
    SL.Text := StringReplace(ibds.FieldByName('ns_list').AsString,
      ',', #13#10, [rfReplaceAll]);
    for I := 0 to Sl.Count - 1 do
    begin
      TBI := TTBItem.Create(nil);
      TBI.Tag := StrToInt(SL.Names[I]);
      TBI.Caption := SL.Values[SL.Names[I]];
      TBI.OnClick := DoOnClick;
      tb.Items.Add(TBI);
    end;
  finally
    SL.Free;
  end;
end;

procedure Tat_frmNSObjects.DoOnClick(Sender: TObject);
var
  Obj: TgdcNamespace;
begin
  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByID';
    Obj.ID := (Sender as TComponent).Tag;
    Obj.Open;
    if not Obj.EOF then
      Obj.EditDialog;
  finally
    Obj.Free;
  end;
end;

constructor Tat_frmNSObjects.Create(AnOwner: TComponent);
begin
  inherited;
  ShowSpeedButton := True;
end;

procedure Tat_frmNSObjects.actAddToNamespaceUpdate(Sender: TObject);
begin
  actAddToNamespace.Enabled := ibds.Active
    and (not ibds.EOF);
end;

function Tat_frmNSObjects.GetObject: TgdcBase;
var
  FC: TgdcFullClassName;
  C: CgdcBase;
begin
  FC.gdClassName := ibds.FieldByName('objectclass').AsString;
  FC.SubType := ibds.FieldByName('subtype').AsString;
  C := gdcClassList.GetGdcClass(FC);
  if C = nil then
    Result := nil
  else begin
    Result := C.Create(nil);
    Result.SubType := FC.SubType;
    Result.SubSet := 'ByID';
    Result.ID := gdcBaseManager.GetIDByRUID(ibds.FieldByName('xid').AsInteger,
      ibds.FieldByName('dbid').AsInteger);
    Result.Open;
    if Result.EOF then
    begin
      MessageBox(Self.Handle,
        'Объект для такого РУИДа не найден в базе данных.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      FreeAndNil(Result);  
    end;
  end;
end;

procedure Tat_frmNSObjects.actAddToNamespaceExecute(Sender: TObject);
var
  Obj: TgdcBase;
begin
  Obj := GetObject;
  if Obj <> nil then
  try
    AddToSetting(False, '', '', Obj, nil);
  finally
    Obj.Free;
  end;
end;

end.
