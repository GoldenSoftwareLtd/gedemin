// ShlTanya, 09.03.2019

unit wiz_frMultiEditFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frEditFrame_unit, StdCtrls, ComCtrls, wiz_FunctionBlock_unit,
  ExtCtrls, Math;

type
  TfrMultiEditFrame = class(TfrEditFrame)
  private
    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); override;

    function CanEdit(V: TVisualBlock): boolean; virtual;
    procedure CreateEditSheet(V: TvisualBlock);
  public
    { Public declarations }
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frMultiEditFrame: TfrMultiEditFrame;

implementation

{$R *.DFM}

{ TfrMultiEditFrame }

function TfrMultiEditFrame.CanEdit(V: TVisualBlock): boolean;
begin
  Result := True;
end;

function TfrMultiEditFrame.CheckOk: Boolean;
var
  I: Integer;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    for I := 1 to ComponentCount - 1 do
    begin
      if Components[I] is TfrEditFrame then
      begin
        Result := TfrEditFrame(Components[I]).CheckOk;
        if not Result then Exit;
      end;
    end;
  end;
end;

procedure TfrMultiEditFrame.CreateEditSheet(V: TvisualBlock);
var
  I: Integer;
  F: TVisualBlock;
  TS: TTabSheet;
  Fr: TfrEditFrame;
  P: TPanel;
begin
  for I := 0 to V.ControlCount - 1 do
  begin
    F := TVisualBlock(V.Controls[I]);
    if CanEdit(F) then
    begin
      TS := TTabSheet.Create(Self);
      TS.PageControl := PageControl;
      TS.Parent := PageControl;
      TS.Caption := F.Header;

      P := TPanel.Create(Self);
      P.Parent := TS;
      P.Align := alClient;
      P.BevelOuter := bvLowered;

      Fr := TfrEditFrame(F.GetEditFrame.Create(Self));
      Fr.Name := '';
      Fr.Parent := P;
      Fr.Block := F;
      Fr.Top := 0;
      Fr.Left := 0;
//      Height := Max(Fr.Constraints.MinHeight, Height);
    end;
    CreateEditSheet(F);
  end;
end;

procedure TfrMultiEditFrame.SaveChanges;
var
  I: Integer;
begin
  inherited;

  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TfrEditFrame then
    begin
      TfrEditFrame(Components[I]).SaveChanges;
    end;
  end;
end;

procedure TfrMultiEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  CreateEditSheet(Value);
end;

end.
