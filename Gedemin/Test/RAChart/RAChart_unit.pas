unit RAChart_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gsRAChart, ExtCtrls, StdCtrls, ActnList, Menus, gsPeriodEdit, xSpin,
  ImgList;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    rachart: TgsRAChart;
    Panel2: TPanel;
    Button1: TButton;
    pm: TPopupMenu;
    ActionList1: TActionList;
    actAction: TAction;
    actAction1: TMenuItem;
    lblNotify: TLabel;
    lblClick: TLabel;
    gspe: TgsPeriodEdit;
    spCellWidth: TxSpinEdit;
    spRowHeight: TxSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblDblClick: TLabel;
    lblDragDrop: TLabel;
    rbDays: TRadioButton;
    rbMonthes: TRadioButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure rachartChange(Sender: TObject);
    procedure rachartClick(Sender: TObject);
    procedure rachartDblClick(Sender: TObject);
    procedure rachartDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure gspeChange(Sender: TObject);
    procedure spCellWidthChange(Sender: TObject);
    procedure spRowHeightChange(Sender: TObject);
    procedure rbMonthesClick(Sender: TObject);
    procedure rbDaysClick(Sender: TObject);
  private
    FNotifyCnt: Integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
  V, V2: Variant;
begin
  rachart.MinValue := EncodeDate(2016, 04, 20);
  rachart.MaxValue := EncodeDate(2018, 05, 10);

  rachart.AddRowHead('Номер', 120);
  rachart.AddRowHead('Класс', 80);

  rachart.AddRowTail('Итого', 60);
  rachart.AddRowTail('Всего', 60);

  for I := 1 to 200 do
  begin
    rachart.AddResource(I, 'Номер №' + IntToStr(I), '"Люкс"');
  end;

  rachart.AddSubResource(1000, 3, 'Место 1', '');
  rachart.AddSubResource(1001, 3, 'Место 2', '');
  rachart.AddSubResource(1002, 3, 'Место 3', '');

  rachart.AddSubResource(10000, 1001, 'Одеяло', 'Теплое');

  V := VarArrayCreate([0, 4], varVariant);

  V[0] := 'Бронирование 100000';
  V[1] := 100;
  V[2] := 200;
  V[3] := 'ABC';

  V2 := VarArrayCreate([0, 1], varInteger);
  V2 := 1000;
  V2 := 2000;

  V[4] := V2;
  
  rachart.AddInterval(100000, 2, EncodeDate(2017, 4, 25), EncodeDate(2017, 4, 30) + EncodeTime(2, 0, 0, 0),
    V, 'Комментарий', clTeal, clWhite, 0, 0);
  rachart.AddInterval(100005, 2, EncodeDate(2017, 4, 30) + 0.2, EncodeDate(2017, 5, 7),
    'Бронирование 100005', 'Комментарий', clRed, clWhite, 33);
  rachart.AddInterval(100001, 5, EncodeDate(2017, 5, 1), EncodeDate(2017, 5, 2),
    '', 'Комментарий'#13#10'в'#13#10'три строки', clPurple, clWhite, 0, 0);
  rachart.AddInterval(100002, 5, EncodeDate(2017, 5, 4), EncodeDate(2017, 5, 4) + 0.2,
    'Бронирование 100002', 'Комментарий'#13#10'в'#13#10'три строки', clPurple, clWhite, 33);
  rachart.AddInterval(100003, 7, EncodeDate(2017, 5, 3) + EncodeTime(5, 30, 30, 0),
    EncodeDate(2017, 5, 5) + EncodeTime(11, 10, 0, 0),
    'Бронирование 100003', 'Комментарий'#13#10'в'#13#10'три строки', clPurple, clWhite, 0);
  rachart.AddInterval(100004, 9, EncodeDate(2017, 5, 3) + EncodeTime(5, 30, 30, 0),
    EncodeDate(2017, 5, 5) + EncodeTime(11, 10, 0, 0),
    'Бронирование 100004', 'Комментарий'#13#10'в'#13#10'три строки', clPurple, clWhite, 33);
  rachart.AddInterval(100006, 11, EncodeDate(2017, 5, 3) + 0.5,
    EncodeDate(2017, 5, 4) + 0.5,
    'Бронирование 100006', 'Комментарий'#13#10'в'#13#10'три строки', clBlue, clWhite, 33);
  rachart.AddInterval(100007, 11, EncodeDate(2017, 5, 4) + 0.5,
    EncodeDate(2017, 5, 5) + 0.5,
    'Бронирование 1000007', 'Комментарий'#13#10'в'#13#10'три строки', clRed, clWhite, 33);
  rachart.AddInterval(100008, 11, EncodeDate(2017, 5, 5) + 0.5,
    EncodeDate(2017, 5, 6) + 0.5,
    'Бронирование 1000008', 'Комментарий'#13#10'в'#13#10'три строки', clGreen, clWhite, 33);
  rachart.AddInterval(100009, 11, EncodeDate(2017, 5, 6) + 0.5,
    EncodeDate(2017, 5, 7) + 0.5,
    'Бронирование 1000009', 'Комментарий'#13#10'в'#13#10'три строки', clMaroon, clWhite, 33);
  rachart.AddInterval(100010, 11, EncodeDate(2017, 5, 7) + 0.5,
    EncodeDate(2017, 5, 8) + 0.5,
    'Бронирование 1000010', 'Комментарий'#13#10'в'#13#10'три строки', clNavy, clWhite, 33);

  rachart.AddInterval(100011, 12, EncodeDate(2017, 5, 1) + 0.1,
    EncodeDate(2017, 5, 1) + 0.3,
    'Бронирование 1000011', 'Комментарий'#13#10'в'#13#10'три строки', clNavy, clWhite, 0);
  rachart.AddInterval(100012, 12, EncodeDate(2017, 5, 1) + 0.4,
    EncodeDate(2017, 5, 1) + 0.6,
    'Бронирование 1000012', 'Комментарий'#13#10'в'#13#10'три строки', clRed, clWhite, 0);
  rachart.AddInterval(100013, 12, EncodeDate(2017, 5, 1) + 0.7,
    EncodeDate(2017, 5, 1) + 0.9,
    'Бронирование 100013', 'Комментарий'#13#10'в'#13#10'три строки', clYellow, clWhite, 0);


  rachart.FirstVisibleValue := EncodeDate(2017, 04, 25);
  rachart.Value := EncodeDate(2017, 05, 01);
  rachart.ResourceID := 10;

  spCellWidth.Value := rachart.CellWidth;
  spRowHeight.Value := rachart.RowHeight
end;

procedure TForm1.rachartChange(Sender: TObject);
begin
  Inc(FNotifyCnt);
  lblNotify.Caption :=
    'ResourceID: ' + IntToStr(rachart.ResourceID) +
    ';   Value: ' + VarAsType(rachart.Value, varString) +
    ';   IntervalID: ' + IntToStr(rachart.IntervalID) +
    ';   Selected count: ' + IntToStr(rachart.SelectedCount) +
    ';   NotifyCnt: ' + IntToStr(FNotifyCnt);
end;

procedure TForm1.rachartClick(Sender: TObject);
begin
  lblClick.Caption :=
    'Click:   ResourceID: ' + IntToStr(rachart.ResourceID) +
    ';   Value: ' + VarAsType(rachart.Value, varString) +
    ';   IntervalID: ' + IntToStr(rachart.IntervalID) +
    ';   Selected count: ' + IntToStr(rachart.SelectedCount);
end;

procedure TForm1.rachartDblClick(Sender: TObject);
begin
  lblDblClick.Caption :=
    'DblClick:   ResourceID: ' + IntToStr(rachart.ResourceID) +
    ';   Value: ' + VarAsType(rachart.Value, varString) +
    ';   IntervalID: ' + IntToStr(rachart.IntervalID) +
    ';   Selected count: ' + IntToStr(rachart.SelectedCount);
end;

procedure TForm1.rachartDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  lblDragDrop.Caption := 'Drag drop:   SourceID: ' + IntToStr(rachart.DragResourceID) +
    ';   SourceValue: ' + VarAsType(rachart.DragValue, varString) +
    ';   IntervalID: ' + IntToStr(rachart.IntervalID) +
    ';   DragIntervalID: ' + IntToStr(rachart.DragIntervalID);
end;

procedure TForm1.gspeChange(Sender: TObject);
begin
  rachart.MinValue := gspe.Date;
  rachart.MaxValue := gspe.EndDate;
end;

procedure TForm1.spCellWidthChange(Sender: TObject);
begin
  rachart.CellWidth := Round(spCellWidth.Value);
end;

procedure TForm1.spRowHeightChange(Sender: TObject);
begin
  rachart.RowHeight := Round(spRowHeight.Value);
end;

procedure TForm1.rbMonthesClick(Sender: TObject);
begin
  rachart.ScaleKind := scMonthes or scYears;
end;

procedure TForm1.rbDaysClick(Sender: TObject);
begin
  rachart.ScaleKind := scMonthes or scDays;
end;

end.
