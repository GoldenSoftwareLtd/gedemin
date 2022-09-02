// ShlTanya, 24.02.2019

unit gd_dlgEditStringList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ActnList, Grids;

type
  TdlgEditStringList = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    StringGrid: TStringGrid;
    ActionList1: TActionList;
    actNew: TAction;
    actDelete: TAction;
    Button1: TButton;
    Button2: TButton;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    Button3: TButton;
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  public
    function GetElement(Values: TStrings): String;
  end;

var
  dlgEditStringList: TdlgEditStringList;

implementation

{$R *.DFM}

uses
  gd_dlgEditMemo;

function TdlgEditStringList.GetElement(Values: TStrings): String;
begin
  Assert(Values <> nil, 'Нельзя передавать NIL');
  StringGrid.ColWidths[0] := StringGrid.Width;
  StringGrid.RowCount := Values.Count;
  StringGrid.Cols[0].Assign(Values);

  Result := '';
  if ShowModal = mrOk then
  begin
    if StringGrid.Row <> -1 then
      Result := StringGrid.Cells[0, StringGrid.Row];
    Values.Assign(StringGrid.Cols[0]);
  end;
end;

procedure TdlgEditStringList.actDeleteExecute(Sender: TObject);
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
     S.Assign(StringGrid.Cols[0]);
     S.Delete(StringGrid.Row);
     StringGrid.RowCount := StringGrid.RowCount - 1;
     StringGrid.Cols[0].Assign(S);
  finally
    S.Free;
  end;
end;

procedure TdlgEditStringList.actDeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := StringGrid.Row <> - 1;
end;

procedure TdlgEditStringList.actNewExecute(Sender: TObject);
begin
  StringGrid.RowCount := StringGrid.RowCount + 1;
  StringGrid.Row := StringGrid.RowCount - 1;
  StringGrid.Cells[0, StringGrid.RowCount - 1] := '';
  StringGrid.SetFocus;
end;

procedure TdlgEditStringList.Button3Click(Sender: TObject);
begin
  with TdlgEditMemo.Create(Self) do
  try
    Memo.Lines.Assign(StringGrid.Cols[0]);
    if ShowModal = mrOk then
    begin
      StringGrid.RowCount := Memo.Lines.Count;
      StringGrid.Cols[0].Assign(Memo.Lines)
    end;
  finally
    Free;
  end;
end;

end.
