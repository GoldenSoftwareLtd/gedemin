
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Dialog template              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_PageF;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TfrPageForm = class(TForm)
  private
    { Private declarations }
    procedure TWMMove(var Message: TMessage); message WM_MOVE;
  public
    { Public declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  end;


implementation

{$R *.DFM}

uses FR_Class;

procedure TfrPageForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := frDesigner.Handle;
end;

procedure TfrPageForm.TWMMove(var Message: TMessage);
begin
  inherited;
  if Assigned(OnResize) then
    OnResize(nil);
end;

end.
