unit TestForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, MSScriptControl_TLB, StdCtrls, Db, obj_IBQuery_unit, ActiveX,
  Grids, DBGrids, IBCustomDataSet, IBQuery, IBDatabase, ExtCtrls, xReport;

type
  TForm1 = class(TForm)
    ScriptControl1: TScriptControl;
    mmText: TMemo;
    dsResult: TDataSource;
    DBGrid1: TDBGrid;
    IBQuery1: TIBQuery;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    Panel1: TPanel;
    btnStart: TButton;
    Splitter1: TSplitter;
    xReport1: TxReport;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    FSCBase: TQueryList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBDatabase1.Connected := True;
  OleInitialize(nil);
  FSCBase := TQueryList.Create(IBDatabase1, IBTransaction1);
  ScriptControl1.AddObject('Base', FSCBase, False);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  OleUnInitialize;
//  FSCBase.ClearQuery;
//  FreeAndNil(FSCBase);
//  ScriptControl1.Reset;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  ScriptControl1.ExecuteStatement(mmText.Lines.Text);
  dsResult.DataSet := FSCBase.QueryList.Querys[FSCBase.ResultIndex].IBQuery;
  xReport1.Execute; 
end;

end.
