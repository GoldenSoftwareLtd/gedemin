
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
  gd_ClassList, gdcClasses, gd_directories_const, gdcTableCalendar;

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
  I, J, Cnt: Integer;
  Obj: TgdcBase;
  SL: TStringList;
  F: TForm;
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
            Obj := C.CreateSubType(nil, SL[J])
          else
            Obj := C.Create(nil);
          try
            Inc(Cnt);
            OutputDebugString(PChar(IntToStr(I) + ': ' + C.ClassName +
              ' (' + IntToStr(J) + ': ' + Obj.SubType + '), ' + IntToStr(Cnt)));

            if (Obj.GetListTable(SL[J]) > '') and
              ((not (Obj is TgdcDocument)) or (TgdcDocument(Obj).DocumentTypeKey > -1)) then
            begin
              Obj.Open;

              {Obj.Insert;
              Obj.Cancel;

              if not Obj.EOF then
              begin
                Obj.Edit;
                Obj.Post;
              end;}

              F := TgdcBaseCrack(Obj).CreateDialogForm;
              F.Free;

              F := Obj.CreateViewForm(nil, '', Obj.SubType);
              F.Free;

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
