{
  Товары
}
unit boGoods;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  boObject, DBTables;

type
  TboGoods = class(TboObject)
  public
    function AddGoods(name: String; parent: Integer; var Key: Integer): Boolean;
    function EditGoods(Goodskey: Integer): Boolean;
    function DeleteGoods(Goodskey: Integer): Boolean;
    function ReplaceGoods(GoodsKey, GroupGoods: Integer): Boolean;
  end;

procedure Register;

implementation

uses
  dlgGoods_unit;

function TboGoods.AddGoods(name: String; parent: Integer;
  var Key: Integer): Boolean;
var
  dlgGoods: TdlgGoods;
begin
  dlgGoods := TdlgGoods.Create(nil);
  try
    dlgGoods.tblGoods.Open;
    dlgGoods.tblGoods.Append;
    if Parent <> 0 then
      dlgGoods.tblGoods.FieldByName('parent').AsInteger := Parent;
    dlgGoods.Parent := Parent;
    dlgGoods.tblGoods.FieldByName('name').AsString := name;
    Result := dlgGoods.ShowModal = mrOk;
    if Result then
    begin
      dlgGoods.tblGoods.Refresh;
      Key := dlgGoods.tblGoods.FieldByName('id').AsInteger
    end;
  finally
    dlgGoods.Free;
  end;
end;

function TboGoods.EditGoods(Goodskey: Integer): Boolean;
var
  dlgGoods: TdlgGoods;
begin
  dlgGoods := TdlgGoods.Create(nil);
  try
    dlgGoods.tblGoods.Open;
    dlgGoods.mbbNext.Visible := False;
    if dlgGoods.tblGoods.FindKey([Goodskey]) then
    begin
      dlgGoods.xdblParent.Enabled := False;
      dlgGoods.tblGoods.Edit;
      Result := dlgGoods.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgGoods.Free;
  end;
end;

function TboGoods.DeleteGoods(Goodskey: Integer): Boolean;
var
  tblGoods: TTable;
begin
  Result := False;
  tblGoods := TTable.Create(Self);
  try
    tblGoods.DatabaseName := DataBaseName;
    tblGoods.TableName := 'fin_Goods';
    tblGoods.Open;
    if tblGoods.FindKey([Goodskey]) and
      (MessageBox(Application.Handle, 'Удалить запись?', 'Внимание',
          MB_ICONQUESTION + MB_YESNO) = mrYes) then
    begin
      try
        tblGoods.Delete;
        Result := True;
      except
        MessageBox(Application.Handle, 'Данная запись уже где-то используется!', 'Внимание',
          MB_ICONEXCLAMATION);
      end;
    end
  finally
    tblGoods.Free;
  end;
end;

function TboGoods.ReplaceGoods(GoodsKey, GroupGoods: Integer): Boolean;
var
  spTestReplaceGoods: TStoredProc;
  qryGoods: TQuery;

begin
  Result := GoodsKey = GroupGoods;
  if not Result then
  begin
    spTestReplaceGoods := TStoredProc.Create(Self);
    try
      spTestReplaceGoods.DataBaseName := DataBaseName;
      if GroupGoods <> 0 then
      begin
        spTestReplaceGoods.StoredProcName := 'fin_p_testreplaceGoods';
        spTestReplaceGoods.Prepare;
        spTestReplaceGoods.ParamByName('Goodskey').AsInteger := GoodsKey;
        spTestReplaceGoods.ParamByName('groupGoods').AsInteger := GroupGoods;
        spTestReplaceGoods.ExecProc;
        Result := spTestReplaceGoods.ParamByName('replace').AsInteger = 1;
      end
      else
        Result := True;
      if Result then
      begin
        qryGoods := TQuery.Create(Self);
        try
          qryGoods.DatabaseName := DataBaseName;
          if groupGoods <> 0 then
            qryGoods.SQL.Text := Format('UPDATE fin_Goods SET fin_Goods.parent = %d ' +
              'WHERE fin_Goods.id = %d ', [groupGoods, Goodskey])
          else
            qryGoods.SQL.Text := Format('UPDATE fin_Goods SET fin_Goods.parent = NULL ' +
              'WHERE fin_Goods.id = %d ', [Goodskey]);
          qryGoods.ExecSQL;
        finally
          qryGoods.Free;
        end;
      end;
    finally
      spTestReplaceGoods.Free;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsBORent', [TboGoods]);
end;

end.
