unit xFRepView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, ActnList, TB2Item, TB2Dock, TB2Toolbar, StdCtrls, Printers;

type
  TxFRepView = class(TCreateableForm)
    TBDock1: TTBDock;
    tbtMain: TTBToolbar;
    ActionList: TActionList;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    actPrint: TAction;
    actClose: TAction;
    PrintDialog: TPrintDialog;
    Memo: TMemo;
    actHelp: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem3: TTBItem;
    procedure actPrintExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FIsPrint: Boolean;
    { Private declarations }
    procedure PassThroughFile(const FileName: String);
    procedure SetIsPrint(const Value: Boolean);
  public
    { Public declarations }
    property IsPrint: Boolean read FIsPrint write SetIsPrint;
  end;

var
  xFRepView: TxFRepView;

implementation
const
  cst_FileName = 'temp.rpt';

{$R *.DFM}

{ TxFRepView }

procedure TxFRepView.PassThroughFile(const FileName: String);
type
  PR = ^TR;
  TR = record
    Size: Word;
    Data: array[0..0] of Char;
  end;

var
  F: File;
  P: PR;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  try
    GetMem(P, FileSize(F) + SizeOf(Word));
    try
      P^.Size := FileSize(F);
      BlockRead(F, P^.Data, P^.Size);
      CharToOemBuff(@(P^.Data), @(P^.Data), P^.Size);

      Printer.BeginDoc;
      Escape(Printer.Handle, PASSTHROUGH, 0, Pointer(P), nil);
      Printer.EndDoc;
    finally
      FreeMem(P, P^.Size + SizeOf(Word));
    end;
  finally
    CloseFile(F);
  end;
end;

procedure TxFRepView.SetIsPrint(const Value: Boolean);
begin
  FIsPrint := Value;
end;

procedure TxFRepView.actPrintExecute(Sender: TObject);
var
  i: Integer;
begin
  if isPrint then
  begin
    if PrintDialog.Execute then
    begin
      Memo.Lines.SaveToFile(cst_FileName);
      for i := 1 to PrintDialog.Copies do
        PassThroughFile(cst_FileName);
    end;
  end;
end;

procedure TxFRepView.FormCreate(Sender: TObject);
begin
  FIsPrint := False;
  ShowSpeedButton := True;
end;

procedure TxFRepView.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TxFRepView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  if (Action = caHide) and FShiftDown then
    Action := caFree;
//  FShiftDown := False;
end;

end.
