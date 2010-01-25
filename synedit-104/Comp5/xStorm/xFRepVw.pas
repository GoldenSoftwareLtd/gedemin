{
  Form file for TxFastReport
  Copyright c) 1996 - 97 by Golden Software
  Author: Vladimir Belyi
}


unit xFRepVw;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, FrmPlSvr, Printers, Spin,
  xAppReg;

type
  TxReportView = class(TForm)
    GroupBox1: TGroupBox;
    Memo: TMemo;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    seCountCopy: TSpinEdit;
    procedure FormActivate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    procedure PassThroughFile(const FileName: String);

  public
    isPrint: Boolean;
  end;

var
  xReportView: TxReportView;

implementation

{$R *.DFM}

const
  cst_FileName = 'temp.rpt';

procedure TxReportView.PassThroughFile(const FileName: String);
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
      AnsiToOemBuff(@(P^.Data), @(P^.Data), P^.Size);

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

procedure TxReportView.FormActivate(Sender: TObject);
begin
  Memo.SetFocus;

end;

procedure TxReportView.BitBtn1Click(Sender: TObject);
var
  i: Integer;
begin
  if isPrint then
  begin
    Memo.Lines.SaveToFile(cst_FileName);
    for i := 1 to seCountCopy.Value do
      PassThroughFile(cst_FileName);
    AppRegistry.WriteInteger('Gedemin', 'xFRCountCopy', seCountCopy.Value);
  end;
end;

procedure TxReportView.FormCreate(Sender: TObject);
begin
  isPrint := False;
  seCountCopy.Value := AppRegistry.ReadInteger('Gedemin', 'xFRCountCopy', 1);
end;

procedure TxReportView.BitBtn2Click(Sender: TObject);
begin
  Close;
end;

end.
