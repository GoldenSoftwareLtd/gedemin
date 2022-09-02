// ShlTanya, 09.03.2019

unit gd_frmShowSQLObjects_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls, ComCtrls;

type
  Tgd_frmShowSQLObjects = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Timer: TTimer;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    sg: TStringGrid;
    sg2: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    procedure Refresh;
  end;

var
  gd_frmShowSQLObjects: Tgd_frmShowSQLObjects;

implementation

{$R *.DFM}

uses
  gdcBaseInterface, IBCustomDataSet, IBSQL;

procedure Tgd_frmShowSQLObjects.FormCreate(Sender: TObject);
begin
  Refresh;
  Timer.Enabled := True;
end;

procedure Tgd_frmShowSQLObjects.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure Tgd_frmShowSQLObjects.Refresh;
var
  I, J, M: Integer;
begin
  for I := 0 to sg.ColCount - 1 do
    for J := 0 to sg.RowCount - 1 do
      sg.Cells[I, J] := '';

  for I := 0 to sg2.ColCount - 1 do
    for J := 0 to sg2.RowCount - 1 do
      sg2.Cells[I, J] := '';

  if Assigned(gdcBaseManager) and Assigned(gdcBasemanager.database) then
  begin
    with gdcBaseManager.Database do
    begin
      M := 0;
      for I := 0 to TransactionCount - 1 do
      begin
        if Transactions[I] <> nil then
        begin
          sg.Cells[0, M + 1] := Transactions[I].Name;
          if Transactions[I].Owner <> nil then
          begin
            sg.Cells[1, M + 1] := Transactions[I].Owner.Name; 
            sg.Cells[2, M + 1] := Transactions[I].Owner.ClassName;
          end;
          if Transactions[I].Active then
            sg.Cells[3, M + 1] := 'Active'
          else
            sg.Cells [3, M + 1] := 'Closed';
          M := M + 1;
        end;
      end;
    end;


    with gdcBaseManager.Database do
    begin
      M := 0;
      for I := 0 to SQLObjectCount - 1 do
        if (SQLObjects[I] <> nil) and (SQLObjects[I].Owner <> nil) then
        begin 
          if SQLObjects[I].Owner is TComponent then
            sg2.Cells[0, M + 1] := TComponent(SQLObjects[I].Owner).Name;
          sg2.Cells[1, M + 1] := SQLObjects[I].Owner.ClassName;
          if SQLObjects[I].Owner is TComponent then
            if TComponent(SQLObjects[I].Owner).Owner <> nil then
            begin
              if TComponent(SQLObjects[I].Owner).Owner is TComponent then
                sg2.Cells[2, M + 1] := TComponent(TComponent(SQLObjects[I].Owner).Owner).Name; 
              sg2.Cells[3, M + 1] := TComponent(SQLObjects[I].Owner).Owner.ClassName;
            end;
          if SQLObjects[I].Owner is TIBCustomDataSet then
          begin
            sg2.Cells[4, M + 1] := IntToStr(Integer(TIBCustomdataset(SQLObjects[I].Owner).Active)); 
            sg2.Cells[5, M + 1] := IntToStr(Integer(TIBCustomdataset(SQLObjects[I].Owner).CacheSize));
          end;
          if SQLObjects[I].Owner is TIBSQL then
          begin
            sg2.Cells[4, M + 1] := IntToStr(Integer(TIBSQL(SQLObjects[I].Owner).Open));
            sg2.Cells[5, M + 1] := TIBSQL(SQLObjects[I].Owner).SQL.Text;
          end;
          M := M + 1;
        end;
    end;
  end;
end;

procedure Tgd_frmShowSQLObjects.Button1Click(Sender: TObject);
begin
  Refresh;
end;

procedure Tgd_frmShowSQLObjects.TimerTimer(Sender: TObject);
begin
  Refresh;
end;

procedure Tgd_frmShowSQLObjects.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  Timer.Enabled := False;
  CanClose := True;
end;

end.
