{
  Form file for xMemo.pas
  Copyright c) 1996 - 97 by Golden Software
  Author: Vladimir Belyi
}

unit xMemoEdF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls, Tabs,
  Buttons, ExtCtrls, SysUtils, Dialogs,
  xBasics;

type
  TxMemoLinesForm = class(TForm)
    ButtonPanel: TPanel;
    Languages: TTabSet;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Panel1: TPanel;
    Memo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure LanguagesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LanguagesChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateChanges;
  public
    { Public declarations }
    LinesList: TClassList;
    function LanguageIndex(Name: string): Integer;
    procedure SetLanguage(Name: string);
  end;

var
  xMemoLinesForm: TxMemoLinesForm;

implementation

uses
  xMemo;

{$R *.DFM}

procedure TxMemoLinesForm.FormCreate(Sender: TObject);
begin
  LinesList := TClassList.Create;
end;

procedure TxMemoLinesForm.LanguagesClick(Sender: TObject);
begin
  UpdateChanges;
end;

procedure TxMemoLinesForm.FormDestroy(Sender: TObject);
begin
  LinesList.Free;
end;

procedure TxMemoLinesForm.FormActivate(Sender: TObject);
begin
  Memo.Lines.Assign(TxMemoLang(LinesList[Languages.TabIndex]).Lines);
end;

procedure TxMemoLinesForm.LanguagesChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  if Languages.TabIndex >= 0 then
    TxMemoLang(LinesList[Languages.TabIndex]).Lines.Assign(Memo.Lines);
end;

function TxMemoLinesForm.LanguageIndex(Name: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Languages.Tabs.Count - 1 do
   if CompareText(Languages.Tabs[i], Name) = 0 then
    begin
      Result := i;
      exit;
    end;
end;

procedure TxMemoLinesForm.SetLanguage(Name: string);
begin
  Languages.TabIndex := LanguageIndex(Name);
end;

procedure TxMemoLinesForm.OKBtnClick(Sender: TObject);
begin
  UpdateChanges;
end;

procedure TxMemoLinesForm.UpdateChanges;
begin
  Memo.Lines.Assign(TxMemoLang(LinesList[Languages.TabIndex]).Lines);
end;

end.
