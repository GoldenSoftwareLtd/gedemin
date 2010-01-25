
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xtblcal2.pas

  Abstract

    Part of xTblCal component.

  Author

    Andrei Kireev

  Contact address

  Revisions history

    1.00    09-Sep-1996    andreik    Initial version.

--}

unit xTblCal2;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, xSpin, StdCtrls;

type
  TTableCalendarProperties = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    edName: TEdit;
    Bevel1: TBevel;
    Label3: TLabel;
    edAlias: TEdit;
    seYear: TxSpinEdit;
    procedure btnOkClick(Sender: TObject);

  private
    OldYear: Integer;

    function GetName: String;
    procedure SetName(const AName: String);
    function GetYear: Integer;
    procedure SetYear(AYear: Integer);
    function GetAlias: String;
    procedure SetAlias(const AnAlias: String);

  public
    constructor Create(AnOwner: TComponent); override;

    property Name: String read GetName write SetName;
    property Year: Integer read GetYear write SetYear;
    property Alias: String read GetAlias write SetAlias;
  end;

var
  TableCalendarProperties: TTableCalendarProperties;

implementation

{$R *.DFM}

constructor TTableCalendarProperties.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  edName.Text := '';
  seYear.Value := 0;
  edAlias.Text := '';

  OldYear := 0;
end;

function TTableCalendarProperties.GetName: String;
begin
  Result := edName.Text;
end;

procedure TTableCalendarProperties.SetName(const AName: String);
begin
  edName.Text := AName;
end;

function TTableCalendarProperties.GetYear: Integer;
begin
  Result := seYear.IntValue;
end;

procedure TTableCalendarProperties.SetYear(AYear: Integer);
begin
  seYear.IntValue := AYear;
  OldYear := AYear;
end;

function TTableCalendarProperties.GetAlias: String;
begin
  Result := edAlias.Text;
end;

procedure TTableCalendarProperties.SetAlias(const AnAlias: String);
begin
  edAlias.Text := AnAlias;
end;

procedure TTableCalendarProperties.btnOkClick(Sender: TObject);
const
  Message =
    'Изменен год рабочего графика.'#13#13 +
    'Выходные дни, которые привязаны к дням недели'#13 +
    '(например, воскресенье), а также некоторые религиозные'#13 +
    'праздники могут быть установлены неправильно.'#13#13 +
    'Исправьте их вручную или создайте новый график,'#13 +
    'указав необходимый год.'#0;
begin
  if OldYear <> Year then
    MessageBox(Handle, Message, 'Внимание', MB_OK or MB_ICONEXCLAMATION);
end;

end.

