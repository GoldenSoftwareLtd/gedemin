unit Test_SWIProlog_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, gsPLClient, dbclient, DB,
  Sysutils, PLIntf, PLHeader, ActiveX, gdcBaseInterface;

type
   Test_SWIProlog = class(TgsDBTestCase)
   published
     procedure TestSWIProlog;
   end;

implementation

procedure Test_SWIProlog.TestSWIProlog;
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
begin 
  PLClient := TgsPLClient.Create;
  try
    Check(PLClient.Initialise, 'Not Initialise Prolog!');
    Check(PLClient.Call2('true'));
    PLClient.MakePredicatesOfSQLSelect(SQL_contact, FTr, 'gd_contact', 'gd_contact');
    PLClient.MakePredicatesOfSQLSelect(SQL_place, FTr, 'gd_place', 'gd_place');

    PLTermv := TgsPLTermv.CreateTermv(2);
    cds := TClientDataSet.Create(nil);
    try
      cds.FieldDefs.Add('City', ftString, 60, True);
      CDS.FieldDefs.Add('Name', ftString, 60, True);
      CDS.CreateDataSet;
      CDS.Open;


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
          for I := 0 to Sl.Count - 1 do
            V[I] := StrToInt(SL.Names[I]);


          PLClient.MakePredicatesOfObject('TgdcCurr', '', 'ByID', V, nil, 'ID,Name', FTr,
            'gd_curr', 'gd_curr');

          PLTermv.Reset;
          PLQuery := TgsPLQuery.Create;
          try
            PLQuery.PredicateName := 'gd_curr';
            PLQuery.Termv := PLTermv;
            PLQuery.DeleteDataAfterClose := True;
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
          finally
            PLQuery.Free;
          end; 
        finally
          SL.Free;
        end;
      end;
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
