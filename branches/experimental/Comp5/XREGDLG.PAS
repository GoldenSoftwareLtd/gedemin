{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xregdlg.pas

  Abstract

    Диалог для получения регистрационного кода.

--}

unit Xregdlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, MakeRgn, xBulbBtn;

type
  TfrmMakeCode = class(TForm)
    Panel1: TPanel;
    edParametr: TEdit;
    Label4: TLabel;
    Panel2: TPanel;
    edCode: TEdit;
    Label5: TLabel;
    Label1: TLabel;
    edtCodeProgram: TEdit;
    Label2: TLabel;
    lblVersion: TLabel;
    Label7: TLabel;
    cbProgramName: TComboBox;
    xBulbOk: TxBulbButton;
    procedure xbbOkClick(Sender: TObject);
    procedure xbbCancelClick(Sender: TObject);
    procedure edCodeEnter(Sender: TObject);
    procedure cbProgramNameChange(Sender: TObject);
  public
    procedure MakeCode;
  end;

var
  frmMakeCode: TfrmMakeCode;

implementation

{$R *.DFM}

// Получение кода по входным параметрам
procedure TfrmMakeCode.MakeCode;
var
  Version, ProductID: Longint;
  Parametr, VersionStr: String;
  E: Integer;

begin
  Val(edtCodeProgram.Text, ProductID, E);
  if E = 0 then
  begin
    Parametr := edParametr.Text;
    TurnStr(Parametr);
    ConvertedValue(Parametr, edtCodeProgram.Text, False);
    VersionStr := Parametr[2];
    Delete(Parametr, 2, 1);
    Val(VersionStr, Version, E);
    lblVersion.Caption := VersionStr;
    case Version of
      1: edCode.Text := MakeRegCodeV1(Parametr, edtCodeProgram.Text);
    end;
  end
  else
    ShowMessage('Program code error');
end;

procedure TfrmMakeCode.xbbOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmMakeCode.xbbCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmMakeCode.edCodeEnter(Sender: TObject);
begin
  MakeCode;
end;

procedure TfrmMakeCode.cbProgramNameChange(Sender: TObject);
var
  S: String;
begin
  S := cbProgramName.Items[cbProgramName.ItemIndex];
  edtCodeProgram.Text := Copy(S, Pos(':', S) + 1, Length(S));
end;


end.
