unit xBulbLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TxBulbLabel = class(TLabel)
  private
    FBulbFont: TFont;
    NormFont: TFont;

    procedure SetBulbFont(ABulbFont: TFont);
  protected
    procedure Loaded; override;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
    property BulbFont: TFont read FBulbFont write SetBulbFont;
  end;

procedure Register;

implementation

{TxBulbLabel ---------------------------------------------}

constructor TxBulbLabel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FBulbFont := TFont.Create;
  FBulbFont.Color := RGB(99, 97, 198);
  NormFont := TFont.Create;
end;

destructor TxBulbLabel.Destroy;
begin
  NormFont.Free;
  FBulbFont.Free;
  inherited Destroy;
end;

procedure TxBulbLabel.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if not MouseCapture then
  begin
    MouseCapture := True;
    Font.Assign(FBulbFont);
    Repaint;
  end
  else
    if (Message.XPos < 0) or (Message.XPos > Width) or
       (Message.YPos < 0) or (Message.YPos > Height) then
    begin
      MouseCapture := False;
      Font.Assign(NormFont);
      Repaint;
    end;
end;

procedure TxBulbLabel.Loaded;
begin
  inherited Loaded;

  NormFont.Assign(Font);
end;

procedure TxBulbLabel.SetBulbFont(ABulbFont: TFont);
begin
  FBulbFont.Assign(ABulbFont);
end;

procedure TxBulbLabel.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  Font.Assign(NormFont);
//  Font.Color := clBlack;
  Repaint;
end;

procedure Register;
begin
  RegisterComponents('x-Misk', [TxBulbLabel]);
end;

end.
