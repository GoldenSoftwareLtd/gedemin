
unit Test_gdcObject_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  Tgs_gdcObjectTest = class(TgsDBTestCase)
  published
    procedure Test_gdcObject;
    procedure Test_gdcHoliday;
    procedure Test_gdcGoodGroup;
  end;

implementation

uses
  Windows, Forms, SysUtils, IBSQL, gdcBase, gdcBaseInterface,
  gd_ClassList, gdcClasses, gd_directories_const, gdcTableCalendar,
  gdcInvMovement, Test_Global_unit, gdcGood, IB, gd_security,
  at_frmSQLProcess;

type
  TgdcBaseCrack = class(TgdcBase)
  end;

procedure Tgs_gdcObjectTest.Test_gdcGoodGroup;
var
  Obj: TgdcGoodGroup;
begin
  Obj := TgdcGoodGroup.Create(nil);
  try
    Obj.ExtraConditions.Add('UPPER(z.name)=:n');
    Obj.ParamByName('n').AsString := 'ÒÀÐÀ';
    Obj.Open;

    Check(not Obj.EOF);
    try
      Obj.Delete;
      Check(False);
    except
      on E: EIBError do ;
    end;

    Obj.Close;
    Obj.ParamByName('n').AsString := 'ÑÒÅÊËÎÏÎÑÓÄÀ';
    Obj.Open;

    Check(not Obj.EOF);
    try
      Obj.Delete;
      Check(False);
    except
      on E: EIBError do ;
    end;

    try
      Obj.Edit;
      Obj.FieldByName('parent').Clear;
      Obj.Post;
      Check(False);
    except
      on E: EIBError do ;
    end;

    Obj.Close;
    Obj.ParamByName('n').AsString := 'ÄÐÀÃÌÅÒÀËËÛ';
    Obj.Open;

    Check(not Obj.EOF);
    try
      Obj.Delete;
      Check(False);
    except
      on E: EIBError do ;
    end;
  finally
    Obj.Free;
  end;
end;

procedure Tgs_gdcObjectTest.Test_gdcHoliday;
const
  HolidayName = 'test holiday name';
var
  Obj: TgdcHoliday;
begin
  Obj := TgdcHoliday.Create(nil);
  try
    Obj.Open;

    if Obj.EOF then
      Check(Obj.IsHoliday(EncodeDate(2010, 1, 1)) = False);

    Obj.Insert;
    Obj.FieldByName('holidaydate').AsDateTime := Date;
    Obj.FieldByName('name').AsString := HolidayName;
    Obj.Post;

    Check(Obj.IsHoliday(Date));
    Check(Obj.QIsHoliday(Date));
    Check(Obj.FieldByName('name').AsString = HolidayName);

    FQ.SQL.Text := 'SELECT * FROM gd_ruid WHERE id = :id AND xid = :id AND dbid = :dbid';
    FQ.ParamByName('id').AsInteger := Obj.ID;
    FQ.ParamByName('dbid').AsInteger := IBLogin.DBID;
    FQ.ExecQuery;
    Check(not FQ.EOF);
    FQ.Close;

    Obj.Edit;
    Obj.FieldByName('disabled').AsInteger := 1;
    Obj.Post;

    Check(not Obj.IsHoliday(Date));
    Check(not Obj.QIsHoliday(Date));

    Obj.Delete;
    Check(not Obj.IsHoliday(Date));
    Check(not Obj.QIsHoliday(Date));
  finally
    Obj.Free;
  end;
end;

procedure Tgs_gdcObjectTest.Test_gdcObject;
var
  C: CgdcBase;
  I, J, Cnt, P: Integer;
  Obj: TgdcBase;
  SL, Output: TStringList;
  F: TForm;
  SS, DN: String;
begin
  SL := TStringList.Create;
  Output := TStringList.Create;
  try
    Cnt := 0;
    for I := 0 to gdcClassList.Count - 1 do
    begin
      C := gdcClassList[I];
      if not C.IsAbstractClass then
      begin
        C.GetSubTypeList(SL);

        if SL.Count = 0 then
          SL.Add('');

        for J := 0 to SL.Count - 1 do
        begin
          DN := '';
          if SL[J] > '' then
          begin
            P := Pos('=', SL[J]);
            if P = 0 then
              SS := SL[J]
            else
            begin
              SS := System.Copy(SL[J], P + 1, 1024);
              DN := System.Copy(SL[J], 1, P - 1);
            end;
            Obj := C.CreateSubType(nil, SS);
          end else
            Obj := C.Create(nil);
          try
            Inc(Cnt);
            AddText(PChar(IntToStr(I) + ': ' + C.ClassName +
              ' (' + IntToStr(J) + ': ' + Obj.SubType + '), ' + IntToStr(Cnt)));

            if DN = '' then
            begin
              if Obj.GetDisplayName(Obj.SubType) <> Obj.GetListTable(Obj.SubType) then
                DN := Obj.GetDisplayName(Obj.SubType);
            end;
            Output.Add('| ' + IntToStr(Cnt) + ' || ' + C.ClassName + ' || ' + Obj.SubType + ' || ' +
              C.ClassParent.ClassName + ' || ' +
              '[[' + AnsiUpperCase(Obj.GetListTable(Obj.SubType)) + ']] || ' + DN);
            Output.Add('|-');

            if (Obj.GetListTable(Obj.SubType) > '')
              and ((not (Obj is TgdcDocument)) or (TgdcDocument(Obj).DocumentTypeKey > -1)) then
            begin
              FQ.Close;
              FQ.SQL.Text := TgdcBaseCrack(Obj).CheckTheSameStatement;
              if FQ.SQL.Text > '' then
                FQ.Prepare;
                
              Obj.Open;

              if not Obj.InheritsFrom(TgdcInvBaseRemains)
                and (not Obj.ClassNameIs('TgdcInvCard'))
                and (not Obj.ClassNameIs('TgdcLink'))
                and (not Obj.ClassNameIs('TgdcUserDocumentLine'))
                and (not Obj.ClassNameIs('TgdcBankStatementLine'))
                and (not Obj.ClassNameIs('TgdcAcctDocument'))
                and (not Obj.ClassNameIs('TgdcAcctEntryRegister')) then
              begin
                if Obj.CanCreate then
                begin
                  Obj.Insert;
                  Obj.Cancel;

                  if (Obj.GetDialogFormClassName(Obj.SubType) <> 'Tgdc_dlgObjectProperties') then
                  begin
                    DUnit_Process_Form_Flag := True;
                    try
                      Obj.CreateDialog;
                    finally
                      DUnit_Process_Form_Flag := False;
                    end;
                  end;
                end;
              end;

              F := Obj.CreateViewForm(nil, '', Obj.SubType);
              if F <> nil then
              begin
                DUnit_Process_Form_Flag := True;
                try
                  if not F.Visible then
                    F.ShowModal;
                finally
                  DUnit_Process_Form_Flag := False;
                  F.Free;
                end;
              end;

              FQ.Close;
              FQ.SQL.Text := TgdcBaseCrack(Obj).CheckTheSameStatement;
              if FQ.SQL.Text > '' then
                FQ.Prepare;

              if not Obj.EOF then
              begin
                Obj.Close;
                Obj.ExtraConditions.Add('z.id >= ' + IntToStr(cstUserIDStart));
                Obj.Open;

                FQ.Close;
                FQ.SQL.Text := TgdcBaseCrack(Obj).CheckTheSameStatement;
                if FQ.SQL.Text > '' then
                  FQ.Prepare;
              end;
            end;
          finally
            Obj.Free;
          end;
        end;
      end else
      begin
        Inc(Cnt);
        DN := C.GetDisplayName('');
        if DN = C.ClassName then
          DN := ''
        else
          DN := '''''''' + DN + '''''''';
        Output.Add('| ' + IntToStr(Cnt) + ' || ''''''' + C.ClassName + ''''''' ||  || ' +
          '''''''' + C.ClassParent.ClassName + ''''''' || ' +
          ' || ' + DN);
        Output.Add('|-');
      end;
    end;

    //Output.SaveToFile('c:\temp\list.txt');
  finally
    SL.Free;
    Output.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_gdcObjectTest.Suite);
end.
