// ShlTanya, 02.02.2019

unit at_dlgNamespaceRemoveList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, TB2Item, TB2Dock, TB2Toolbar, ActnList, CheckLst, ExtCtrls,
  ContNrs;

type
  Tat_dlgNamespaceRemoveList = class(TForm)
    pnlTop: TPanel;
    mInfo: TMemo;
    pnlBottom: TPanel;
    TBDock: TTBDock;
    List: TCheckListBox;
    ActionList: TActionList;
    actAll: TAction;
    TBToolbar: TTBToolbar;
    tbiAll: TTBItem;
    actNone: TAction;
    tbiNone: TTBItem;
    actObject: TAction;
    tbiObject: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    btnDel: TButton;
    actDel: TAction;
    btnCancel: TButton;
    actCancel: TAction;
    procedure actDelExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actDelUpdate(Sender: TObject);
    procedure actNoneUpdate(Sender: TObject);
    procedure actAllUpdate(Sender: TObject);
    procedure actObjectUpdate(Sender: TObject);
    procedure actAllExecute(Sender: TObject);
    procedure actNoneExecute(Sender: TObject);
    procedure actObjectExecute(Sender: TObject);

  public
    RemoveList: TObjectList;

    procedure DoDialog;
  end;

var
  at_dlgNamespaceRemoveList: Tat_dlgNamespaceRemoveList;

implementation

{$R *.DFM}

uses
  gdcNamespaceLoader, gdcBaseInterface, gdcBase;

procedure Tat_dlgNamespaceRemoveList.actDelExecute(Sender: TObject);
var
  I: Integer;
begin
  Assert(RemoveList <> nil);
  Assert(RemoveList.Count = List.Items.Count);

  for I := List.Items.Count - 1 downto 0 do
    if not List.Checked[I] then
      RemoveList.Delete(I);
  ModalResult := mrOK;
end;

procedure Tat_dlgNamespaceRemoveList.actCancelExecute(Sender: TObject);
begin
  RemoveList.Clear;
  ModalResult := mrCancel;
end;

procedure Tat_dlgNamespaceRemoveList.actDelUpdate(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to List.Items.Count - 1 do
    if List.Checked[I] then
    begin
      actDel.Enabled := True;
      exit;
    end;
  actDel.Enabled := False;
end;

procedure Tat_dlgNamespaceRemoveList.actNoneUpdate(Sender: TObject);
begin
  actNone.Enabled := List.Items.Count > 0;
end;

procedure Tat_dlgNamespaceRemoveList.actAllUpdate(Sender: TObject);
begin
  actAll.Enabled := List.Items.Count > 0;
end;

procedure Tat_dlgNamespaceRemoveList.actObjectUpdate(Sender: TObject);
begin
  actObject.Enabled := List.ItemIndex > -1;
end;

procedure Tat_dlgNamespaceRemoveList.DoDialog;
var
  I: Integer;
  S: String;
  RR: TatRemoveRecord;
begin
  Assert(RemoveList <> nil);
  Assert(RemoveList.Count > 0);

  for I := 0 to RemoveList.Count - 1 do
  begin
    RR := RemoveList[I] as TatRemoveRecord;
    if RR.ObjectName > '' then
      S := RR.ObjectName + ', '
    else
      S := '';
    List.Items.Add(S + RR.ObjectClass.ClassName + RR.ObjectSubType + ', ' +
      RUIDToStr(RR.RUID));
    List.Checked[List.Items.Count - 1] := True;
  end;

  ShowModal;
end;

procedure Tat_dlgNamespaceRemoveList.actAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to List.Items.Count - 1 do
    List.Checked[I] := True;
end;

procedure Tat_dlgNamespaceRemoveList.actNoneExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to List.Items.Count - 1 do
    List.Checked[I] := False;
end;

procedure Tat_dlgNamespaceRemoveList.actObjectExecute(Sender: TObject);
var
  Obj: TgdcBase;
  RR: TatRemoveRecord;
begin
  Assert(RemoveList <> nil);
  Assert(RemoveList.Count = List.Items.Count);

  RR := RemoveList[List.ItemIndex] as TatRemoveRecord;
  Obj := RR.ObjectClass.Create(nil);
  try
    Obj.SubType := RR.ObjectSubType;
    Obj.SubSet := 'ByID';
    Obj.ID := gdcBaseManager.GetIDByRUID(RR.RUID.XID, RR.RUID.DBID);
    Obj.Open;
    if not Obj.EOF then
      Obj.EditDialog('');
  finally
    Obj.Free;
  end;
end;

end.
