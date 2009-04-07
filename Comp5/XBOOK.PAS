unit Xbook;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, {ChConst,} xCommon_anj, xbkIni;

type
  TxBookkeep = class(TComponent)
  private
    { Private declarations }
    FDebet: String;
    FKredit: String;
    FDebetKAU: String;
    FKreditKAU: String;
    FDebetKAUName: String;
    FKreditKAUName: String;
    FStopKAU: TKAUtypes;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent);
      override;
    function ShowConstractDlg: Boolean;
  published
    { Published declarations }
    property Debet: String read FDebet write FDebet;
    property Kredit: String read FKredit write FKredit;
    property DebetKAU: String read FDebetKAU write FDebetKAU;
    property KreditKAU: String read FKreditKAU write FKreditKAU;
    property DebetKAUName: String read FDebetKAUName;
    property KreditKAUName: String read FKreditKAUName;
    property StopKAU: TKAUtypes read FStopKAU write FStopKAU;
  end;

procedure Register;

implementation

constructor TxBookkeep.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FDebet:= '';
  FKredit:= '';
  FDebetKAU:= '';
  FKreditKAU:= '';
  FDebetKAUName:= '';
  FKreditKAUName:= '';
end;

function TxBookkeep.ShowConstractDlg: Boolean;
begin
  Result:= false;
{  ChooseConstractForm:= TChooseConstractForm.Create(Self);
  try
    ChooseConstractForm.StopKAU:= StopKAU;
    ChooseConstractForm.Debet:= Debet;
    ChooseConstractForm.Kredit:= Kredit;
    ChooseConstractForm.DebetKAU:= DebetKAU;
    ChooseConstractForm.KreditKAU:= KreditKAU;
    if ChooseConstractForm.ShowModal = mrOk then
    begin
      Result:= true;
      FDebet:= ChooseConstractForm.Debet;
      FKredit:= ChooseConstractForm.Kredit;
      FDebetKAU:= ChooseConstractForm.DebetKAU;
      FKreditKAU:= ChooseConstractForm.KreditKAU;
      FDebetKAUName:= ChooseConstractForm.DebetKAUName;
      FKreditKAUName:= ChooseConstractForm.KreditKAUName;
    end;
  finally
    ChooseConstractForm.Free;
  end;}
end;

procedure Register;
begin
  RegisterComponents('xTool', [TxBookkeep]);
end;

end.
