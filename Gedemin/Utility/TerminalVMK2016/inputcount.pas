unit InputCount;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, 
    BaseAddInformation;

type

  { TBaseAddInformation1 }

  TInputCount = class(TBaseAddInformation)
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    class function Execute: String; override;
  end;

var
  BaseAddInformation1: TInputCount;

implementation

{$R *.lfm}

{ TBaseAddInformation1 }

procedure TInputCount.FormCreate(Sender: TObject);
begin
  inherited;

  lInfo.Caption := 'Введите количество товара: ';
end;

class function TInputCount.Execute: String;
begin
  Result := '';
  with TInputCount.Create(nil) do
  try
    ShowModal;
    Result := Data;
  finally
    Free;
  end;
end;

end.

