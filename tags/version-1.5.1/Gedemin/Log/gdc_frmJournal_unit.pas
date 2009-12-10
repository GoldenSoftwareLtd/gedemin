
unit gdc_frmJournal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcJournal, Menus,
  ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ToolWin, ComCtrls,
  ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmJournal = class(Tgdc_frmSGR)
    gdcJournal: TgdcJournal;
    tbiCreateTrig: TTBItem;
    actCreateTriggers: TAction;
    actDropTriggers: TAction;
    tbiDelTrig: TTBItem;
    nTriggerSeparator: TMenuItem;
    nTriggersCreate: TMenuItem;
    nTriggersDrop: TMenuItem;
    actOpenObject: TAction;
    tbsepBefOpenObject: TTBSeparatorItem;
    tbiOpenObject: TTBItem;
    tbi_mm_sep5_2: TTBSeparatorItem;
    tbiOpenObj: TTBItem;
    tbiDelTrig2: TTBItem;
    tbiCreateTrig2: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actCreateTriggersUpdate(Sender: TObject);
    procedure actCreateTriggersExecute(Sender: TObject);
    procedure actDropTriggersUpdate(Sender: TObject);
    procedure actDropTriggersExecute(Sender: TObject);
    procedure actOpenObjectExecute(Sender: TObject);
    procedure actOpenObjectUpdate(Sender: TObject);
    procedure actDuplicateUpdate(Sender: TObject);
    procedure ibgrMainDblClick(Sender: TObject);
  end;

var
  gdc_frmJournal: Tgdc_frmJournal;

implementation

{$R *.DFM}

{ Tgdc_frmJournal }

uses
  gd_ClassList, gd_security;

procedure Tgdc_frmJournal.FormCreate(Sender: TObject);
begin
  gdcObject := gdcJournal;
  inherited;
end;

procedure Tgdc_frmJournal.actCreateTriggersUpdate(Sender: TObject);
begin
  actCreateTriggers.Enabled := Assigned(IBLogin) and (IBLogin.IsIBUserAdmin);
end;

procedure Tgdc_frmJournal.actCreateTriggersExecute(Sender: TObject);
begin
  gdcJournal.CreateTriggers;
end;

procedure Tgdc_frmJournal.actDropTriggersUpdate(Sender: TObject);
begin
  actDropTriggers.Enabled := Assigned(IBLogin) and (IBLogin.IsIBUserAdmin);
end;

procedure Tgdc_frmJournal.actDropTriggersExecute(Sender: TObject);
begin
  gdcJournal.DropTriggers;
end;

procedure Tgdc_frmJournal.actOpenObjectExecute(Sender: TObject);
var
  FC: TgdcFullClass;
  Obj: TgdcBase;
  C: TPersistentClass;
  S: String;
  P: Integer;
begin
  S := Trim(gdcObject.FieldByName('source').AsString);
  FC := GetBaseClassForRelation(S);
  if FC.gdClass <> nil then
  begin
    Obj := FC.gdClass.CreateWithID(nil,
      nil,
      nil,
      gdcObject.FieldByName('objectid').AsInteger,
      FC.SubType);
    try
      Obj.Open;
      if not Obj.IsEmpty then
        Obj.EditDialog;
    finally
      Obj.Free;
    end;
  end else
  begin
    P := Pos(' ', S);
    if P = 0 then
      C := GetClass(S)
    else
      C := GetClass(Copy(S, 1, P - 1));
    if (C <> nil) and C.InheritsFrom(TgdcBase) then
    begin
      if P > 0 then
        Delete(S, 1, P)
      else
        S := '';  
      Obj := CgdcBase(C).CreateWithID(nil,
        nil,
        nil,
        gdcObject.FieldByName('objectid').AsInteger,
        S);
      try
        Obj.Open;
        if not Obj.IsEmpty then
          Obj.EditDialog
        else
          MessageBox(Self.Handle,
            PChar('Запись была удалена. Тип объекта: ' + Obj.GetDisplayName(Obj.SubType) + '.'),
            'Информация',
            MB_OK or MB_TASKMODAL or MB_ICONINFORMATION);
      finally
        Obj.Free;
      end;
    end;
  end;
end;

procedure Tgdc_frmJournal.actOpenObjectUpdate(Sender: TObject);
begin
  actOpenObject.Enabled := gdcObject.Active
    and (not gdcObject.IsEmpty)
    and (gdcObject.FieldByName('source').AsString > '')
    and (gdcObject.FieldByName('objectid').AsInteger > 0);
end;

procedure Tgdc_frmJournal.actDuplicateUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := False;
end;

procedure Tgdc_frmJournal.ibgrMainDblClick(Sender: TObject);
const
  Counter: Integer = 0;
begin
  if Assigned(gdcObject) then
  begin
    if (ibgrMain.GridCoordFromMouse.X >= 0) and
       (ibgrMain.GridCoordFromMouse.Y >= 0) then
    begin
      if not gdcObject.IsEmpty then
        actOpenObject.Execute;
    end;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmJournal);

finalization
  UnRegisterFrmClass(Tgdc_frmJournal);
end.
