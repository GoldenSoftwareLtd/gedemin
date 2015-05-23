unit Test_SWIProlog_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, gsPLClient, dbclient, DB,
  Sysutils, PLIntf, PLHeader, ActiveX, gdcBaseInterface;

type
   Test_SWIProlog = class(TgsDBTestCase)
   published
     procedure TestPLClient;
     procedure TestPLTermv; 
   end;

implementation

procedure Test_SWIProlog.TestPLTermv;
var
  PLClient: TgsPLClient;
  PLTermv: TgsPLTermv;
  DT: TDateTime;
  D: Double;
  I: Integer;
begin
  PLClient := TgsPLClient.Create;
  try
    Check(PLClient.Initialise, 'Not Initialise Prolog!');

    PLTermv := TgsPLTermv.CreateTermv(8);
    try
      Check(PLTermv.Size = 8);

      PLTermv.PutInteger(0, MaxInt);
      Check(PLTermv.DataType[0] = PL_INTEGER);
      Check(PLTermv.ReadInteger(0) = MaxInt);

      PLTermv.PutString(1, 'Test');
      Check(PLTermv.DataType[1] = PL_STRING);
      Check(PLTermv.ReadString(1) = 'Test');

      D := 3.14;
      PLTermv.PutFloat(2, D);
      Check(PLTermv.DataType[2] = PL_FLOAT); 
      Check(PLTermv.ReadFloat(2) = D);

      DT := Now;
      PLTermv.PutDateTime(3, DT);
      Check(PLTermv.DataType[3] = PL_ATOM);
      Check(FormatDateTime('yyyy-mm-dd hh:nn:ss', PLTermv.ReadDateTime(3)) = FormatDateTime('yyyy-mm-dd hh:nn:ss', DT));

      PLTermv.PutDate(4, DT);
      Check(PLTermv.DataType[4] = PL_ATOM);
      Check(FormatDateTime('yyyy-mm-dd', PLTermv.ReadDateTime(4)) = FormatDateTime('yyyy-mm-dd', DT));

      PLTermv.PutInt64(5, High(Int64));
      Check(PLTermv.DataType[5] = PL_INTEGER);
      Check(PLTermv.ReadInt64(5) = High(Int64));

      PLTermv.PutAtom(6, 'Test');
      Check(PLTermv.DataType[6] = PL_ATOM);
      Check(PLTermv.ReadAtom(6) = 'Test');

      PLTermv.PutVariable(7);
      Check(PLTermv.DataType[7] = PL_VARIABLE);

      PLTermv.Reset;
      for I := 0 to PLTermv.Size - 1 do
        Check(PLTermv.DataType[I] = PL_VARIABLE);

    finally
      PLTermv.Free;
    end;
  finally
    PLClient.Free;
  end;
end;  

procedure Test_SWIProlog.TestPLClient;
const
  SQL_contact = 'SELECT id, placekey, name FROM gd_contact';
  SQL_place = 'SELECT id, name FROM gd_place';
  Pred =
    'bycity(City, Name) :- ' +
    '  gd_place(CityID, City), ' +
    '  gd_contact(_, CityID, Name).';
  City = 'Минск';
  
var
  PLClient: TgsPLClient;
  cds: TClientDataSet;
  PLTermv: TgsPLTermv;
  V: Variant;
  SL: TStringList;
  I, Idx: Integer;
  PLQuery: TgsPLQuery;
  PredCount: Integer;
begin 
  PLClient := TgsPLClient.Create;
  try
    Check(PLClient.Initialise, 'Not Initialise Prolog!');
    Check(PLClient.Call2('true'));
    FQ.Close;
    FQ.SQL.Text := 'SELECT count(id) FROM gd_contact';
    FQ.ExecQuery;
    Check(not FQ.Eof);

    PredCount := PLClient.MakePredicatesOfSQLSelect(SQL_contact, FTr, 'gd_contact', 'gd_contact');
    Check(PredCount = FQ.FieldByName('count').AsInteger, 'Error predicate count!');

    FQ.Close;
    FQ.SQL.Text := 'SELECT count(id) FROM gd_place';
    FQ.ExecQuery;
    Check(not FQ.Eof);

    PredCount := PLClient.MakePredicatesOfSQLSelect(SQL_place, FTr, 'gd_place', 'gd_place');
    Check(PredCount = FQ.FieldByName('count').AsInteger, 'Error predicate count!');

    FQ.Close;

    PLTermv := TgsPLTermv.CreateTermv(2);
    cds := TClientDataSet.Create(nil);
    try
      cds.FieldDefs.Add('City', ftString, 60, True);
      cds.FieldDefs.Add('Name', ftString, 60, True);
      cds.CreateDataSet;
      cds.Open;

      PLTermv.PutString(0, 'pred');
      PLTermv.PutString(1, Pred);
      Check(PLClient.Call('load_atom', PLTermv), 'Error predicate ''load_atom''!');

      PLTermv.Reset;
      PLTermv.PutString(0, City);

      PLClient.ExtractData(cds, 'bycity', PLTermv);


      FQ.Close;
      FQ.SQL.Text := 'SELECT count(c.name) ' +
        'FROM gd_contact c ' +
        '  JOIN gd_place p ' +
        '    ON p.id = c.placekey ' +
        'WHERE p.name = ''Минск''';
      FQ.ExecQuery;
      Check(not FQ.Eof);
      Check(FQ.FieldByName('count').AsInteger = cds.RecordCount, 'Error number of records!');
      FQ.Close;

      {*
      FQ.SQL.Text := 'SELECT id, name FROM gd_curr WHERE id < 147000000';
      FQ.ExecQuery;


      if not FQ.Eof then
      begin
        SL := TStringList.Create;
        try
          while not FQ.Eof do
          begin
            SL.Add(FQ.FieldByName('id').AsString + '=' + FQ.FieldByName('name').AsString);
            FQ.Next;
          end;

          V := VarArrayCreate([0, SL.Count - 1], varInteger);
          for I := 0 to SL.Count - 1 do
            V[I] := StrToInt(SL.Names[I]);


          PLClient.MakePredicatesOfObject('TgdcCurr', '', 'ByID', V, nil, 'ID,Name', FTr,
            'gd_curr', 'gd_curr');


          PLTermv.Reset;
          PLQuery := TgsPLQuery.Create;
          try
            PLQuery.PredicateName := 'gd_curr';
            PLQuery.Termv := PLTermv;
            PLQuery.OpenQuery;
            Check(not PLQuery.Eof, 'Error recordcount ''gd_curr''!');

            while not PLQuery.Eof do
            begin
              Idx := SL.IndexOf(IntToStr(PLQuery.Termv.ReadInteger(0)) + '=' + PLQuery.Termv.ReadString(1));
              Check(Idx > -1);
              SL.Delete(Idx);
              PLQuery.NextSolution;
            end;
            Check(SL.Count = 0);
            FQ.Close;

            PLQuery.Close;
          finally
            PLQuery.Free;
          end;
        finally
          SL.Free;
        end;
      end;
      *}
    finally
      PLTermv.Free;
      cds.Free;
    end;
  finally
    PLClient.Free;
  end;
end;

initialization
  RegisterTest('Internals\Prolog', Test_SWIProlog.Suite);

end.
