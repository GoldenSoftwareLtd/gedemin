// ShlTanya, 11.02.2019

unit gd_dlgCountCopy_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, xSpin;

type
  Tgd_dlgCountCopy = class(TForm)
    Label1: TLabel;
    xspeCopy: TxSpinEdit;
    bOk: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bOkClick(Sender: TObject);
  private
    function GetCountCopy: Integer;
    { Private declarations }
  public
    { Public declarations }
    property CountCopy: Integer read GetCountCopy;
  end;

var
  gd_dlgCountCopy: Tgd_dlgCountCopy;

implementation


{$R *.DFM}

uses
  Storages;

procedure Tgd_dlgCountCopy.FormCreate(Sender: TObject);
begin
  xspeCopy.IntValue := UserStorage.ReadInteger('xfreportopt', 'countcopy', 1);
end;

procedure Tgd_dlgCountCopy.bOkClick(Sender: TObject);
begin
  if Assigned(UserStorage) then
    UserStorage.WriteInteger('xfreportopt', 'countcopy', xspeCopy.IntValue);
end;

function Tgd_dlgCountCopy.GetCountCopy: Integer;
begin
  Result := xspeCopy.IntValue;
end;

end.
