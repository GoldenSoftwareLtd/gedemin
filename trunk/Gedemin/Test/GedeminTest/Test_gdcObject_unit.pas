
unit Test_gdcObject_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  Tgs_gdcObjectTest = class(TgsDBTestCase)
  published
    procedure Test_gdcObject;
  end;

implementation

uses
  Forms, SysUtils, IBSQL, gdcBase, gdcBaseInterface, gd_ClassList,
  gdcClasses, gd_directories_const;

type
  TgdcBaseCrack = class(TgdcBase)
  end;

procedure Tgs_gdcObjectTest.Test_gdcObject;
var
  C: CgdcBase;
  I, J: Integer;
  Obj: TgdcBase;
  SL: TStringList;
  F: TForm;
begin
  SL := TStringList.Create;
  try
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
            if (Obj.GetListTable(SL[J]) > '') and
              ((not (Obj is TgdcDocument)) or (TgdcDocument(Obj).DocumentTypeKey > -1)) then
            begin
              Obj.Open;

              F := TgdcBaseCrack(Obj).CreateDialogForm;
              F.Free;

              {F := Obj.CreateViewForm(nil);
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
