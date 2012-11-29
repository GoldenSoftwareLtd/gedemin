
unit Test_AtSQLSetup_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  TSQLSetupTest = class(TgsDBTestCase)
  published
    procedure TestAtSQLSetup;
    procedure TestGetTableAliasOriginField;
    procedure TestIgnoresTable;
  end;

implementation

uses
  Forms, SysUtils, at_sql_setup, at_sql_parser,
  jclStrings, gdcBaseInterface, at_classes;

procedure TSQLSetupTest.TestAtSQLSetup;
var
  Input, Output, Etalon: TStringList;
  I: Integer;
  InputFileName, OutputFileName: String;
begin
  Check(SettingsLoaded, 'Должны быть загружены настройки');

  Input := TStringList.Create;
  Output := TStringList.Create;
  Etalon := TStringList.Create;
  try
    for I := 0 to MAXINT do
    begin
      InputFileName :=  Format(TestDataPath + '\AtSQLSetup\input.%.3d.sql', [I]);
      OutputFileName := Format(TestDataPath + '\AtSQLSetup\output.%.3d.sql', [I]);

      if I = 0 then
      begin
        Check(FileExists(InputFileName), 'Файл не найден: ' + InputFileName);
        Check(FileExists(OutputFileName), 'Файл не найден: ' + OutputFileName);
      end else
      begin
        if (not FileExists(InputFileName)) or (not FileExists(OutputFileName)) then
          break;
      end;

      Input.LoadFromFile(InputFileName);
      TrimStrings(Input);

      Etalon.LoadFromFile(OutputFileName);
      TrimStrings(Etalon);

      with TatSQLSetup.Create(nil) do
      try
        Output.Text := PrepareSQL(gdcBaseManager.ProcessSQL(Input.Text));
      finally
        Free;
      end;
      TrimStrings(Output);

      Check(AnsiCompareText(Output.Text, Etalon.Text) = 0, 'Error in test #' + IntToStr(I));
    end;

  finally
    Input.Free;
    Output.Free;
    Etalon.Free;
  end;
end;

procedure TSQLSetupTest.TestGetTableAliasOriginField;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    GetTableAliasOriginField('SELECT * FROM gd_contact', SL);
    Check(SL.CommaText = '*=.*');
    GetTableAliasOriginField('SELECT c.name FROM gd_contact c', SL);
    Check(AnsiCompareText(SL.CommaText, 'name=c.name') = 0);
    GetTableAliasOriginField('SELECT c.* FROM gd_contact c', SL);
    Check(AnsiCompareText(SL.CommaText, '*=c.*') = 0);
    GetTableAliasOriginField('SELECT c.name as n FROM gd_contact c', SL);
    Check(AnsiCompareText(SL.CommaText, 'n=c.name') = 0);
    GetTableAliasOriginField('SELECT name as n FROM gd_contact', SL);
    Check(AnsiCompareText(SL.CommaText, 'n=.name') = 0);
    GetTableAliasOriginField('SELECT c.name as c_n, co.name as co_n FROM gd_contact c JOIN gd_company co ON co.contactkey=c.id', SL);
    Check(AnsiCompareText(SL.CommaText, 'c_n=c.name,co_n=co.name') = 0);
  finally
    SL.Free;
  end;
end;

procedure TSQLSetupTest.TestIgnoresTable;
var
  Text: String;
begin
  Check(SettingsLoaded, 'Должны быть загружены настройки');

  with TatSQLSetup.Create(nil) do
  try
    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT * FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) > 0);
    Check(StrIPos('Z.NAME', Text) > 0);
    Check(StrIPos('JOIN', Text) > 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT Z.* FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) > 0);
    Check(StrIPos('Z.NAME', Text) > 0);
    Check(StrIPos('JOIN', Text) > 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT Z.ID FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) > 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.NAME', Text) = 0);
    Check(StrIPos('JOIN', Text) > 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT Z.ID, Z.NAME FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) > 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.NAME', Text) > 0);
    Check(StrIPos('Z.CONTACTTYPE', Text) = 0);
    Check(StrIPos('JOIN', Text) > 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL(
      'SELECT Z.ID, Z.NAME, CO.CONTACTKEY FROM GD_CONTACT Z JOIN GD_COMPANY CO ON CO.CONTACTKEY = Z.ID'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) > 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.NAME', Text) > 0);
    Check(StrIPos('Z.CONTACTTYPE', Text) = 0);
    Check(StrIPos('CO.CONTACTKEY', Text) > 0);
    Check(StrIPos('CO.FULLNAME', Text) = 0);
    Check(StrIPos('CO.USR$', Text) > 0);
    Check(StrIPos('JOIN', Text) > 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL(
      'SELECT Z.ID, Z.NAME FROM GD_CONTACT Z JOIN GD_COMPANY CO ON CO.CONTACTKEY = Z.ID'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) > 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.NAME', Text) > 0);
    Check(StrIPos('Z.CONTACTTYPE', Text) = 0);
    Check(StrIPos('CO.FULLNAME', Text) = 0);
    Check(StrIPos('CO.USR$', Text) > 0);
    Check(StrIPos('JOIN', Text) > 0);

    Ignores.AddAliasName('Z');

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT * FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) = 0);
    Check(StrIPos('Z.NAME', Text) = 0);
    Check(StrIPos('JOIN', Text) = 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT Z.* FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) > 0);
    Check(StrIPos('Z.USR$', Text) = 0);
    Check(StrIPos('Z.ID', Text) = 0);
    Check(StrIPos('Z.NAME', Text) = 0);
    Check(StrIPos('JOIN', Text) = 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT Z.ID FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) = 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.NAME', Text) = 0);
    Check(StrIPos('JOIN', Text) = 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL('SELECT Z.ID, Z.PLACEKEY FROM GD_CONTACT Z'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) = 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.PLACEKEY', Text) > 0);
    Check(StrIPos('Z.NAME', Text) = 0);
    Check(StrIPos('JOIN', Text) = 0);

    Text := PrepareSQL(gdcBaseManager.ProcessSQL(
      'SELECT Z.ID, Z.NAME FROM GD_CONTACT Z JOIN GD_COMPANY CO ON CO.CONTACTKEY = Z.ID'));
    Check(StrIPos('Z.*', Text) = 0);
    Check(StrIPos('Z.USR$', Text) = 0);
    Check(StrIPos('Z.ID', Text) > 0);
    Check(StrIPos('Z.NAME', Text) > 0);
    Check(StrIPos('Z.CONTACTTYPE', Text) = 0);
    Check(StrIPos('CO.FULLNAME', Text) = 0);
    Check(StrIPos('CO.USR$', Text) > 0);
    Check(StrIPos('JOIN', Text) > 0);
  finally
    Free;
  end;
end;

initialization
  RegisterTest('DB', TSQLSetupTest.Suite);
end.
