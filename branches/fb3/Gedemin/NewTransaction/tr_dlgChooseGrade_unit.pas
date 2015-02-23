unit tr_dlgChooseGrade_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgChooseGrade = class(TForm)
    rgTypeRecord: TRadioGroup;
    bOk: TButton;
    bCancel: TButton;
    cbDontShow: TCheckBox;
  private
    { Private declarations }
    FFirstGrade: Integer;
    function GetGrade: Integer;
    procedure SetFirstGrade(const Value: Integer);
    function GetIsShow: Boolean;
  public
    { Public declarations }
    property Grade: Integer read GetGrade;
    property FirstGrade: Integer read FFirstGrade write SetFirstGrade;
    property IsShow: Boolean read GetIsShow;
  end;

var
  dlgChooseGrade: TdlgChooseGrade;

implementation

{$R *.DFM}

{ TdlgChooseGrade }

function TdlgChooseGrade.GetGrade: Integer;
begin
  Result := rgTypeRecord.ItemIndex + FFirstGrade;
end;

function TdlgChooseGrade.GetIsShow: Boolean;
begin
  Result := not cbDontShow.Checked;
end;

procedure TdlgChooseGrade.SetFirstGrade(const Value: Integer);
var
  i: Integer;
begin
  FFirstGrade := Value;
  for i:= 0 to FFirstGrade - 1 do
    rgTypeRecord.Items.Delete(0);
end;

end.
