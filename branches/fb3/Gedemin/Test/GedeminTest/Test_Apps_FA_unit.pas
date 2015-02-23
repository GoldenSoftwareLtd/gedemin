unit Test_Apps_FA_unit;

interface

uses
  TestFrameWork, gsTestFrameWork;

type
  TgsTestAppsFA = class(TgsDBTestCase)
  published
    procedure DoTest;
  end;

implementation

uses
  SysUtils;

procedure TgsTestAppsFA.DoTest;
begin
  Check(SettingsLoaded);

  FQ.SQL.Text := 'SELECT * FROM rdb$procedures WHERE rdb$procedure_name = ''USR$FA_P_YEAR_BETWEEN'' ';
  FQ.ExecQuery;
  Check(not FQ.EOF, 'Procedure USR$FA_P_YEAR_BETWEEN not found.');

  FQ.Close;
  FQ.SQL.Text := 'SELECT * FROM USR$FA_P_YEAR_BETWEEN(:D1, :D2)';

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2010, 1, 2);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2010, 2, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2012, 1, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 12, 31);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 12, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 1);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 11, 2);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 1);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 11, 30);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 1);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 11, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 2);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 1, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 1, 2);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 11);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 2, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 1, 1);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 11);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2000, 11, 11);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 11, 11);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 10);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2000, 11, 12);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 11, 11);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 9);
  Check(FQ.Fields[1].AsInteger = 11);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2000, 11, 10);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2010, 11, 11);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 10);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2009, 5, 1);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2009, 5, 31);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 0);
  Check(FQ.Fields[1].AsInteger = 0);

  FQ.Close;
  FQ.ParamByName('D1').AsDateTime := EncodeDate(2012, 2, 29);
  FQ.ParamByName('D2').AsDateTime := EncodeDate(2013, 2, 28);
  FQ.ExecQuery;
  Check(FQ.Fields[0].AsInteger = 1);
  Check(FQ.Fields[1].AsInteger = 0);
end;

initialization
  RegisterTest('Apps', TgsTestAppsFA.Suite);
end.