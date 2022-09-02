// ShlTanya, 09.03.2019

unit wiz_frQuantity_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, TB2Item, TB2Dock, TB2Toolbar, ActnList, wiz_FunctionBlock_unit,
  IBSQL, gdcBaseInterface, gdcConstants;

type
  TfrQuantity = class(TFrame)
    ActionList: TActionList;
    actAddQuantity: TAction;
    actDeleteQuantity: TAction;
    actEditQuantity: TAction;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem1: TTBItem;
    lvQuantity: TListView;
    procedure actAddQuantityExecute(Sender: TObject);
    procedure actDeleteQuantityExecute(Sender: TObject);
    procedure actDeleteQuantityUpdate(Sender: TObject);
    procedure actEditQuantityExecute(Sender: TObject);
    procedure actEditQuantityUpdate(Sender: TObject);
    procedure lvQuantityDblClick(Sender: TObject);
  private
    FBlock: TVisualBlock;
    FAccountKey: TID;
    procedure SetBlock(const Value: TVisualBlock);
    function GetQuantity: string;
    procedure SetQuantity(const Value: string);
    procedure SetAccountKey(const Value: TID);
    { Private declarations }
  public
    { Public declarations }
    property Block: TVisualBlock read FBlock write SetBlock;
    property Quantity: string read GetQuantity write SetQuantity;
    property AccountKey: TID read FAccountKey write SetAccountKey;
  end;

implementation
uses wiz_dlgQunatyForm_unit;
{$R *.DFM}

{ TfrQuantity }

function TfrQuantity.GetQuantity: string;
var
  S: TStrings;
  I: Integer;
begin
  Result := '';
  if lvQuantity.Items.Count > 0 then
  begin
    S := TStringList.Create;
    try
      for I := 0 to lvQuantity.Items.Count - 1 do
      begin
        S.Add(lvQuantity.Items[I].SubItems[1] + '=' +
          lvQuantity.Items[I].SubItems[0]);
      end;
      Result := S.Text;
    finally
      S.Free;
    end;
  end;
end;

procedure TfrQuantity.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

procedure TfrQuantity.SetQuantity(const Value: string);
var
  S: TStrings;
  SQL: TIBSQL;
  QName, Q, QScript: string;
  Id: TID;
  I: Integer;
  LI: TListItem;
begin
  lvQuantity.Items.BeginUpdate;
  try
    lvQuantity.Items.Clear;
    S := TStringList.Create;
    try
      S.Text := Value;
      for I := 0 to S.Count - 1 do
      begin
        QScript := S.Names[i];
        QName := QScript;
        Q := S.Values[QName];
        try
          id := gdcBaseManager.GetIdByRUIDString(QScript);
        except
          id := 0;
        end;

        if id > 0 then
        begin
          SQL := TIBSQL.Create(nil);
          try
            SQL.Transaction := gdcBaseManager.ReadTransaction;
            SQL.SQl.Text := 'SELECT name FROM gd_value WHERE id = :id';
            SetTID(SQL.ParamByName(fnId), id);
            SQL.ExecQuery;
            if SQl.RecordCount > 0 then
              QName := SQL.FieldByName(fnNAme).AsString;
          finally
            SQL.Free;
          end;
        end;

        LI := lvQuantity.Items.Add;
        Li.Caption := QName;
        LI.SubItems.Add(Q);
        LI.SubItems.Add(QScript);
      end;
    finally
      S.Free;
    end;
  finally
    lvQuantity.Items.EndUpdate;
  end;
end;

procedure TfrQuantity.actAddQuantityExecute(Sender: TObject);
var
  D: TdlgQuantiyForm;
  LI: TListItem;
begin
  D := TdlgQuantiyForm.Create(nil);
  try
    D.QUnit := '';
    D.Quantity := '';
    D.Block := FBlock;
    D.AccountKey := FAccountKey;
    if D.ShowModal = mrOk then
    begin
      LI := lvQuantity.Items.Add;
      LI.Caption := D.UnitName;
      LI.SubItems.Add(D.Quantity);
      LI.SubItems.Add(D.QUnit);
    end;
  finally
    D.Free;
  end;
end;

procedure TfrQuantity.actDeleteQuantityExecute(Sender: TObject);
var
  Index: Integer;
begin
  if lvQuantity.Selected <> nil then
  begin
    Index := lvQuantity.Selected.Index;
    lvQuantity.Selected.Delete;
    if Index > lvQuantity.Items.Count then
      lvQuantity.Selected := lvQuantity.Items[lvQuantity.Items.Count - 1]
    else
      lvQuantity.Selected := lvQuantity.Items[Index]
  end;
end;

procedure TfrQuantity.actDeleteQuantityUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvQuantity.Selected <> nil;
end;

procedure TfrQuantity.actEditQuantityExecute(Sender: TObject);
var
  D: TdlgQuantiyForm;
  LI: TListItem;
begin
  if lvQuantity.Selected <> nil then
  begin
    Li := lvQuantity.Selected;
    D := TdlgQuantiyForm.Create(nil);
    try
      D.QUnit := LI.SubItems[1];
      D.Quantity := LI.SubItems[0];
      D.Block := FBlock;
      D.AccountKey := FAccountKey;
      if D.ShowModal = mrOk then
      begin
        LI.Caption := D.UnitName;
        LI.SubItems[0] := D.Quantity;
        LI.SubItems[1] := D.QUnit;
      end;
    finally
      D.Free;
    end;
  end;
end;

procedure TfrQuantity.actEditQuantityUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvQuantity.Selected <> nil;
end;

procedure TfrQuantity.lvQuantityDblClick(Sender: TObject);
begin
  actEditQuantity.Execute;
end;

procedure TfrQuantity.SetAccountKey(const Value: TID);
begin
  FAccountKey := Value;
end;

end.
