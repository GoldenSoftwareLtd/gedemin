// ShlTanya, 30.01.2019

unit rp_dlgCountCopy_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, StdCtrls, ExtCtrls;

type
  Trp_dlgCountCopy = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    btnPlus: TButton;
    btnMinus: TButton;
    pnDoc: TPanel;
    pnCopy: TPanel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnMinusClick(Sender: TObject);
    procedure btnPlusClick(Sender: TObject);
  private
  public
    function GetCountCopy(ACaption: String): Integer;
  end;

var
  rp_dlgCountCopy: Trp_dlgCountCopy;

implementation

uses
  dmDataBase_unit;

{$R *.DFM}

function Trp_dlgCountCopy.GetCountCopy(ACaption: String): Integer;
begin
  Caption := ACaption;
  pnDoc.Caption := ACaption;

  if ShowModal = mrOk then
    Result := StrToInt(pnCopy.Caption)
  else
    Result := -1;
end;

procedure Trp_dlgCountCopy.FormCreate(Sender: TObject);
begin
  if Assigned(UserStorage) then
    pnCopy.Caption := UserStorage.ReadString('\Print', 'CountCopy', pnCopy.Caption);
end;

procedure Trp_dlgCountCopy.FormDestroy(Sender: TObject);
begin
  if Assigned(UserStorage) then
    UserStorage.WriteString('\Print', 'CountCopy', pnCopy.Caption);
end;

procedure Trp_dlgCountCopy.btnMinusClick(Sender: TObject);
begin
  if pnCopy.Caption <> '1' then
    pnCopy.Caption := IntToStr(StrToInt(pnCopy.Caption) - 1)
end;

procedure Trp_dlgCountCopy.btnPlusClick(Sender: TObject);
begin
  pnCopy.Caption := IntToStr(StrToInt(pnCopy.Caption) + 1)
end;

end.
