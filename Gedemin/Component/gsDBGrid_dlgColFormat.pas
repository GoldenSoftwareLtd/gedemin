unit gsDBGrid_dlgColFormat;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Controls,
  ExtCtrls, Grids, DB;



type
  TdlgColFormat = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    btnHelp: TButton;
    sgFormat: TStringGrid;
    Bevel1: TBevel;
    Label1: TLabel;

  private
    FField: TField;

    function GetDisplayFormat: String;

  protected

  public
    constructor Create(AnOwner: TComponent; AField: TField); reintroduce;
    destructor Destroy; override;

    function ShowModal: Integer; override;

    // Возвращает выбранный формат
    property DisplayFormat: String read GetDisplayFormat;

  end;

var
  dlgColFormat: TdlgColFormat;

implementation

{$R *.DFM}

constructor TdlgColFormat.Create(AnOwner: TComponent; AField: TField);
begin
  inherited Create(AnOwner);

  FField := AField;
end;

destructor TdlgColFormat.Destroy;
begin
  inherited Destroy;
end;

function TdlgColFormat.ShowModal: Integer;
var
  TempHeight: Integer;
  I: Integer;

  procedure AddFormat(Index: Integer; S1, S2: String);
  begin
    if sgFormat.RowCount < Index + 1 then
      sgFormat.RowCount := Index + 1;

    sgFormat.Cells[0, Index] := S1;
    sgFormat.Cells[1, Index] := S2;
  end;

begin
  sgFormat.RowCount := 2;

  if FField is TNumericField then
  begin
    sgFormat.Cells[0, 0] := ' Формат';
    sgFormat.Cells[1, 0] := ' Пример: 1234.5';

    AddFormat(1, 'Без формата', FloatToStr(1234.5));
    AddFormat(2, '0', FormatFloat('0', 1234.5));
    AddFormat(3, '0.00', FormatFloat('0.00', 1234.5));
    AddFormat(4, '#.##', FormatFloat('#.##', 1234.5));
    AddFormat(5, '#,##0.00', FormatFloat('#,##0.00', 1234.5));
    AddFormat(6, '#,###.##', FormatFloat('#,###.##', 1234.5));
    AddFormat(7, '#,##0.##', FormatFloat('#,##0.##', 1234.5));

  end else if FField is TDateField then
  begin
    sgFormat.Cells[0, 0] := ' Формат';
    sgFormat.Cells[1, 0] := ' Пример: ' + DateToStr(Date);

    AddFormat(1, 'Без формата', DateToStr(Date));
    AddFormat(2, 'dd.mm.yy', FormatDateTime('dd.mm.yy', Date));
    AddFormat(3, 'dd.mm.yyyy', FormatDateTime('dd.mm.yyyy', Date));
    AddFormat(4, 'dd.mmm.yyyy', FormatDateTime('dd.mmm.yyyy', Date));
    AddFormat(5, 'dd.mmmm.yyyy', FormatDateTime('dd.mmmm.yyyy', Date));
    AddFormat(6, 'dddd', FormatDateTime('dddd', Date));
    AddFormat(7, 'mmmm', FormatDateTime('mmmm', Date));
    AddFormat(8, 'dddd, mmmm', FormatDateTime('dddd, mmmm', Date));
  end else if FField is TTimeField then
  begin
    sgFormat.Cells[0, 0] := ' Формат';
    sgFormat.Cells[1, 0] := ' Пример: ' + TimeToStr(Time);

    AddFormat(1, 'Без формата', TimeToStr(Time));
    AddFormat(2, 'hh:nn', FormatDateTime('hh:nn', Time));
    AddFormat(3, 'hh:nn:ss', FormatDateTime('hh:nn:ss', Time));
    AddFormat(4, 'hh:nn:ss:z', FormatDateTime('hh:nn:ss:z', Time));
    AddFormat(5, 'hh:nn am/pm', FormatDateTime('hh:nn am/pm', Time));
    AddFormat(6, 'hh:nn:ss am/pm', FormatDateTime('hh:nn:ss am/pm', Time));
  end else if FField is TDateTimeField then
  begin
    sgFormat.Cells[0, 0] := ' Формат';
    sgFormat.Cells[1, 0] := ' Пример: ' + TimeToStr(Time);

    AddFormat(1, 'Без формата', DateTimeToStr(Now));
    AddFormat(2, 'dd.mm.yy', FormatDateTime('dd.mm.yy', Date));
    AddFormat(3, 'dd.mm.yyyy', FormatDateTime('dd.mm.yyyy', Date));
    AddFormat(4, 'hh:nn', FormatDateTime('hh.nn', Time));
    AddFormat(5, 'hh:nn:ss', FormatDateTime('hh.nn.ss', Time));
    AddFormat(6, 'hh:nn am/pm', FormatDateTime('hh:nn am/pm', Time));
    AddFormat(7, 'hh:nn:ss am/pm', FormatDateTime('hh:nn:ss am/pm', Time));

    AddFormat(8, 'dd.mm.yy hh:nn', FormatDateTime('dd.mm.yy hh:nn', Date));
    AddFormat(9, 'dd.mm.yyyy hh:nn', FormatDateTime('dd.mm.yyyy hh:nn', Date));
    AddFormat(10, 'dd.mm.yyyy hh:nn:ss', FormatDateTime('dd.mm.yyyy hh:nn:ss', Date));
    AddFormat(11, 'hh:nn am/pm hh:nn', FormatDateTime('hh:nn am/pm hh:nn', Time));
    AddFormat(12, 'hh:nn:ss am/pm hh:nn:ss', FormatDateTime('hh:nn:ss am/pm hh:nn:ss', Time));

    AddFormat(13, 'dddd', FormatDateTime('dddd', Date));
    AddFormat(14, 'mmmm', FormatDateTime('mmmm', Date));
    AddFormat(15, 'dddd, mmmm', FormatDateTime('dddd, mmmm', Date));
  end;

  sgFormat.Row := 1;
  sgFormat.Col := 0;

  if sgFormat.VisibleRowCount < sgFormat.RowCount then
  begin
    TempHeight := 0;

    for I := 0 to sgFormat.VisibleRowCount do
      Inc(TempHeight, sgFormat.RowHeights[I] + sgFormat.GridLineWidth);

    if sgFormat.BorderStyle = bsSingle then
      if sgFormat.Ctl3D then
        Inc(TempHeight, 4)
      else
        Inc(TempHeight, 2);

    sgFormat.Height := TempHeight;
  end;

  Result := inherited ShowModal;
end;

{
  Возвращает формат отображения.
}

function TdlgColFormat.GetDisplayFormat: String;
begin
  if sgFormat.Row = 1 then
    Result := ''
  else
    Result := sgFormat.Cells[0, sgFormat.Row];
end;

end.
