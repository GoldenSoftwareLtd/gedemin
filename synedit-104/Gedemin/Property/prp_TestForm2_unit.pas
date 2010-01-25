unit prp_TestForm2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TTestForm2 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  TestForm2: TTestForm2;

implementation

uses
  evt_i_base;

{$R *.DFM}

{ TTestForm2 }

constructor TTestForm2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  EventControl.SetEvents(Self);
end;

destructor TTestForm2.Destroy;
begin
  EventControl.ResetEvents(Self);

  inherited Destroy;
end;

end.
