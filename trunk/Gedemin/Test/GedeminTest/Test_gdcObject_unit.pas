
unit Test_gdcObject_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  Tgs_gdcObjectTest = class(TgsDBTestCase)
  published
    procedure Test_gdcObject;
    procedure Test_gdcHoliday;
  end;

implementation

uses
  Windows, Forms, SysUtils, IBSQL, gdcBase, gdcBaseInterface,
  gd_ClassList, gdcClasses, gd_directories_const, gdcTableCalendar,
  gdcInvMovement, Test_Global_unit;

type
  TgdcBaseCrack = class(TgdcBase)
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
  SL: TStringList;
  F: TForm;
  SS: String;
begin
  SL := TStringList.Create;
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
          if SL[J] > '' then
          begin
            P := Pos('=', SL[J]);
            if P = 0 then
              SS := SL[J]
            else
              SS := System.Copy(SL[J], P + 1, 1024);
            Obj := C.CreateSubType(nil, SS);
          end else
            Obj := C.Create(nil);
          try
            Inc(Cnt);
            OutputDebugString(PChar(IntToStr(I) + ': ' + C.ClassName +
              ' (' + IntToStr(J) + ': ' + Obj.SubType + '), ' + IntToStr(Cnt)));

            if (Obj.GetListTable(Obj.SubType) > '')
              and ((not (Obj is TgdcDocument)) or (TgdcDocument(Obj).DocumentTypeKey > -1)) then
            begin
              Obj.Open;

              if not Obj.InheritsFrom(TgdcInvBaseRemains)
                and (not Obj.ClassNameIs('TgdcInvCard'))
                and (not Obj.ClassNameIs('TgdcUserDocumentLine'))
                and (not Obj.ClassNameIs('TgdcBankStatementLine'))
                and (not Obj.ClassNameIs('TgdcAcctDocument'))
                and (not Obj.ClassNameIs('TgdcAcctEntryRegister')) then
              begin
                if Obj.CanCreate then
                begin
                  Obj.Insert;
                  Obj.Cancel;

                  if Obj.GetDialogFormClassName(Obj.SubType) <> 'Tgdc_dlgObjectProperties' then
                  begin
                    DUnit_Process_Form_Flag := True;
                    try
                      Obj.CreateDialog;
                    finally
                      DUnit_Process_Form_Flag := False;
                    end;
                  end;
                end;

                {if (not Obj.EOF) and Obj.CanEdit then
                begin
                  Obj.Edit;
                  Obj.Post;
                end;}
              end;

              F := TgdcBaseCrack(Obj).CreateDialogForm;
              F.Free;

              {F := Obj.CreateViewForm(nil, '', Obj.SubType);
              F.Free;}

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
      end;
    end;
  finally
    SL.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_gdcObjectTest.Suite);
end.
