unit grt_main_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    Button1: TButton;
    mLog: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  flt_sql_parser, JclStrings;

procedure TForm1.Button1Click(Sender: TObject);
var
  Input, Output, Etalon: TStringList;
  I: Integer;
  InputFileName, OutputFileName: String;
begin
  mLog.Lines.Clear;
  
  // ����������� ������� ��� ������ ��� �� ���� ��������� �����
  // ������� ExtractTablesList
  // ������� ������ ������ � ������ � ���������� SQLParser
  // ����� � �������: input.000, input.001, ...
  // ����� � ��������� �������: output.000, output.001

  mLog.Lines.Add('[Ok] ����� ���� SQL ������');

  Input := TStringList.Create;
  Output := TStringList.Create;
  Etalon := TStringList.Create;
  try

    for I := 0 to MAXINT do
    begin

      InputFileName := Format('%s\SQLParser\input.%.3d', [
        ExcludeTrailingBackSlash(ExtractFilePath(Application.EXEName)), I]);
      OutputFileName := Format('%s\SQLParser\output.%.3d', [
        ExcludeTrailingBackSlash(ExtractFilePath(Application.EXEName)), I]);

      if (not FileExists(InputFileName)) or (not FileExists(OutputFileName)) then
        break;

      Input.LoadFromFile(InputFileName);
      TrimStrings(Input);

      Etalon.LoadFromFile(OutputFileName);
      TrimStrings(Etalon);

      ExtractTablesList(Input.Text, Output);
      TrimStrings(Output);

      if AnsiCompareText(Output.Text, Etalon.Text) <> 0 then
        mLog.Lines.Add(Format('[Error] �� ������ ����: %d', [I]))
      else
        mLog.Lines.Add(Format('[Ok] ������ ����: %d', [I]))
    end;

  finally
    Input.Free;
    Output.Free;
    Etalon.Free;
  end;

  mLog.Lines.Add('[Ok] �������� ���� SQL ������');
end;

end.
