
unit gdcTableCalendar;

interface

uses
  Classes, Forms, Controls, gd_createable_form, gdcBase, gdcBaseInterface;

type
  TgdcHoliday = class(TgdcBase)
  protected
    function CreateDialogForm: TCreateableForm; override;
    procedure CustomInsert(Buff: Pointer); override;
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    // вяртае ці з'яўляецца перададзеная дата сьвяточным днем
    // пошук ідзе па адкрытаму датасету. Выкарыстоўваецца функцыя Locate.
    function IsHoliday(const TheDate: TDate): Boolean;

    // вяртае ці з'яўляецца перададзеная дата сьвяточным днём
    // для адказу на пытаньне стварае запыт да базы дадзеных
    class function QIsHoliday(const TheDate: TDate): Boolean;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcTableCalendar = class(TgdcBase)
  protected
    function CreateDialogForm: TCreateableForm; override;

  public
    procedure CalcSchedule(const DateBegin, DateEnd: TDateTime;
      const UseHolidays: Boolean);

    procedure GetDataForPeriod(const DateBegin, DateEnd: TDateTime;
      out TotalDays, WorkDays, WorkHours: Double);

    class procedure GetDataForPeriod2(const TableCalendarKey: TID;
      const DateBegin, DateEnd: TDateTime;
      out TotalDays, WorkDays, WorkHours: Double);

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcTableCalendarDay = class(TgdcBase)
  protected
    function CreateDialogForm: TCreateableForm; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;
    function GetNotCopyField: String; override;
    procedure DoBeforePost; override;

  public
    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  Windows, DB, SysUtils, IBSQL, IB, 
  gdc_wage_frmTableCalendarMain_unit,
  gdc_wage_dlgTableCalendar_unit,
  gdc_wage_frmHoliday_unit, IBErrorCodes,
  gdc_wage_dlgHoliday_unit,
  gdc_wage_dlgTableCalendarDay_unit,
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcHoliday, TgdcTableCalendar, TgdcTableCalendarDay]);
end;

{ TgdcTableCalendar }

procedure TgdcTableCalendar.CalcSchedule(const DateBegin,
  DateEnd: TDateTime; const UseHolidays: Boolean);
var
  d: TgdcTableCalendarDay;
  h: TgdcHoliday;
  B: TDateTime;
  F: TField;
  DidActivate: Boolean;
  I, DOW: Integer;
  T: TDateTime;

  procedure FillDate(aDOW, rDOW: Byte);
  var I, offset: Integer;

  procedure FillDays(fDOW: Byte);
  begin
    d.FieldByName(Format('wstart%d', [I])).AsDateTime :=
      FieldByName(Format('w%d_start%d', [fDOW, I])).AsDateTime+
      b + offset;
    if FieldByName(Format('w%d_start%d', [fDOW, I])).AsDateTime >
       FieldByName(Format('w%d_end%d', [fDOW, I])).AsDateTime then
      offset := offset + 1;        // переход даты внутри периода
    d.FieldByName(Format('wend%d', [I])).AsDateTime :=
      FieldByName(Format('w%d_end%d', [fDOW, I])).AsDateTime+
      b + offset;
    if (i < 4) and
       (FieldByName(Format('w%d_start%d', [fDOW, I + 1])).AsDateTime <
        FieldByName(Format('w%d_end%d', [fDOW, I])).AsDateTime) then
      offset := offset + 1;        // переход даты между периодами
  end;

  begin

    // offset - смещение дат
    if aDOW = rDOW then
      offset := FieldByName(Format('w%d_offset', [aDOW])).AsInteger
    else
      offset := FieldByName(Format('w%d_offset', [rDOW])).AsInteger;

    for I := 1 to 4 do
    begin
      if not ( (FieldByName(Format('w%d_start%d', [aDOW, I])).AsDateTime = 0) and
               (FieldByName(Format('w%d_end%d', [aDOW, I])).AsDateTime = 0) ) then
      begin
        FillDays(aDOW);
      end
      else
        if not ((aDOW <> rDOW) and (FieldByName(Format('w%d_start%d', [rDOW, I])).AsDateTime = 0) and
                (FieldByName(Format('w%d_end%d', [rDOW, I])).AsDateTime = 0) ) then
        begin
          FillDays(rDOW);
        end;
    end;

  end;

begin
  if (State in [dsInsert, dsInactive]) or IsEmpty then
    raise EgdcException.Create('error');

  T := Now;
  DidActivate := ActivateTransaction;
  try
    try
      if UseHolidays then
      begin
        h := TgdcHoliday.CreateWithParams(Self,
          Database,
          Transaction,
          '',
          'All');
        h.Open;
      end else
        h := nil;

      d := TgdcTableCalendarDay.CreateWithParams(Self,
        Database,
        Transaction,
        '',
        'ByTableCalendar,ByDateInterval');
      try
        d.UniDirectional := True;
        d.ParamByName('TblCalKey').AsInteger := ID;
        d.ParamByName('DateBegin').AsDateTime := DateBegin;
        d.ParamByName('DateEnd').AsDateTime := DateEnd;
        d.Open;

        while not d.IsEmpty do
        begin
          d.First;
          d.Delete;
        end;

        B := DateBegin;
        while B <= DateEnd do
        begin
          d.Insert;
          try
            d.FieldByName('theday').AsDateTime := B;
            d.FieldByName('tblcalkey').AsInteger := ID;

            F := d.FieldByName('workday');

            DOW := DayOfWeek(B) - 1;
            if DOW = 0 then DOW := 7;

            if Assigned(h) and h.IsHoliday(B) then
            begin
              d.FieldByName('workday').AsInteger := 0;

              for I := 1 to 4 do
              begin
                d.FieldByName(Format('wstart%d', [I])).AsDateTime :=
                  FieldByName(Format('w%d_start%d', [7, I])).AsDateTime;
                d.FieldByName(Format('wend%d', [I])).AsDateTime :=
                  FieldByName(Format('w%d_end%d', [7, I])).AsDateTime;
              end;
            end else begin
              case DOW of
                1: F.AsInteger := FieldByName('mon').AsInteger;
                2: F.AsInteger := FieldByName('tue').AsInteger;
                3: F.AsInteger := FieldByName('wed').AsInteger;
                4: F.AsInteger := FieldByName('thu').AsInteger;
                5: F.AsInteger := FieldByName('fri').AsInteger;
                6: F.AsInteger := FieldByName('sat').AsInteger;
                7: F.AsInteger := FieldByName('sun').AsInteger;
              end;
            end;

            if Assigned(h) and (F.AsInteger = 1) then
            begin
              if h.IsHoliday(B + 1) then
              begin  //Alexander: неправильно заполнит, если не заполним закладку работа перед праздниками
                FillDate(8, DOW);
{                // offset - смещение дат
                offset := FieldByName(Format('w%d_offset', [DOW, I])).AsInteger;
                for I := 1 to 4 do
                begin
                  if not ( (FieldByName(Format('w%d_start%d', [8, I])).AsDateTime = 0) and
                           (FieldByName(Format('w%d_end%d', [8, I])).AsDateTime = 0) ) then
                  begin
                    d.FieldByName(Format('wstart%d', [I])).AsDateTime :=
                      FieldByName(Format('w%d_start%d', [8, I])).AsDateTime+
                      b+offset;
                    if FieldByName(Format('w%d_start%d', [8, I])).AsDateTime >
                       FieldByName(Format('w%d_end%d', [8, I])).AsDateTime then
                      offset := offset+1;        // переход даты внутри периода
                    d.FieldByName(Format('wend%d', [I])).AsDateTime :=
                      FieldByName(Format('w%d_end%d', [8, I])).AsDateTime+
                      b+offset;
                    if (i < 4) and
                       (FieldByName(Format('w%d_start%d', [8, I+1])).AsDateTime <
                        FieldByName(Format('w%d_end%d', [8, I])).AsDateTime) then
                      offset := offset+1;        // переход даты между периодами
                  end;
                end;}
              end else
              begin
                FillDate(DOW, DOW);
{                // offset - смещение дат
                offset := FieldByName(Format('w%d_offset', [DOW, I])).AsInteger;
                for I := 1 to 4 do
                begin
                  if not ( (FieldByName(Format('w%d_start%d', [DOW, I])).AsDateTime = 0) and
                           (FieldByName(Format('w%d_end%d', [DOW, I])).AsDateTime = 0) ) then
                  begin
                    d.FieldByName(Format('wstart%d', [I])).AsDateTime :=
                      FieldByName(Format('w%d_start%d', [DOW, I])).AsDateTime+
                      b+offset;
                    if FieldByName(Format('w%d_start%d', [DOW, I])).AsDateTime >
                       FieldByName(Format('w%d_end%d', [DOW, I])).AsDateTime then
                      offset := offset+1;        // переход даты
                    d.FieldByName(Format('wend%d', [I])).AsDateTime :=
                      FieldByName(Format('w%d_end%d', [DOW, I])).AsDateTime+
                      b+offset;
                    if (i < 4) and
                       (FieldByName(Format('w%d_start%d', [DOW, I+1])).AsDateTime <
                        FieldByName(Format('w%d_end%d', [DOW, I])).AsDateTime) then
                      offset := offset+1;        // переход даты
                  end;
                end;}
              end;
            end
            //Alexander если не учитывать праздники
            else if not Assigned(h) and (F.AsInteger = 1) then
            begin
              FillDate(DOW, DOW);
            end else
            begin
              for I := 1 to 4 do
              begin
                d.FieldByName(Format('wstart%d', [I])).AsDateTime := 2;
                d.FieldByName(Format('wend%d', [I])).AsDateTime := 2;
{                d.FieldByName(Format('wstart%d', [I])).AsDateTime := 0;
                d.FieldByName(Format('wend%d', [I])).AsDateTime := 0;}
              end;
            end;

            d.Post;
          except
            d.Cancel;
            raise;
          end;
          
          B := B + 1;
        end;
      finally
        h.Free;
        d.Free;
      end;

      if sDialog in BaseState then
        MessageBox(ParentHandle,
          PChar(Format('График создан успешно.'#13#10'Время создания: %d сек.',
            [Round((Now - T) * 24 * 60 * 60)])),
          'Внимание',
          MB_OK or MB_ICONINFORMATION);
    except
      if DidActivate and Transaction.InTransaction then
        Transaction.Rollback;
      raise;
    end;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
  end;
end;

function TgdcTableCalendar.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCTABLECALENDAR', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLECALENDAR', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLECALENDAR') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLECALENDAR',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLECALENDAR' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_wage_dlgTableCalendar.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLECALENDAR', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLECALENDAR', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

procedure TgdcTableCalendar.GetDataForPeriod(const DateBegin,
  DateEnd: TDateTime; out TotalDays, WorkDays, WorkHours: Double);
begin
  GetDataForPeriod2(ID, DateBegin, DateEnd, TotalDays,
    WorkDays, WorkHours);
end;

class procedure TgdcTableCalendar.GetDataForPeriod2(
  const TableCalendarKey: TID; const DateBegin, DateEnd: TDateTime;
  out TotalDays, WorkDays, WorkHours: Double);
var
  q: TIBSQL;
  DidActivate: Boolean;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(Assigned(gdcBaseManager.ReadTransaction));
  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Database := gdcBaseManager.Database;
    q.Transaction := gdcBaseManager.ReadTransaction;
    DidActivate := not q.Transaction.InTransaction;
    if DidActivate then
      q.Transaction.StartTransaction;
    q.SQL.Text :=
      'SELECT ' +
      '  COUNT(theday), SUM(wduration), ' +
      '  (SELECT COUNT(theday) FROM wg_tblcalday WHERE tblcalkey = :K AND theday >= :DB AND theday <= :DE) ' +
      'FROM ' +
      '  wg_tblcalday ' +
      'WHERE ' +
      '  workday=1 AND tblcalkey = :K theday >= :DB AND theday <= :DE';
    q.Prepare;
    q.ParamByName('K').AsInteger := TableCalendarKey;
    q.ParamByName('DB').AsDateTime := DateBegin;
    q.ParamByName('DE').AsDateTime := DateEnd;
    q.ExecQuery;
    if q.EOF then
      raise EgdcException.Create('Invalid table calendar key');
    WorkDays := q.Fields[0].AsInteger;
    WorkHours := q.Fields[1].AsFloat;
    TotalDays := q.Fields[2].AsInteger;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;
    q.Free;
  end;
end;

class function TgdcTableCalendar.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcTableCalendar.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'WG_TBLCAL';
end;

class function TgdcTableCalendar.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_wage_frmTableCalendarMain';
end;

{ TgdcTableCalendarDay }

function TgdcTableCalendarDay.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCTABLECALENDARDAY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLECALENDARDAY', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLECALENDARDAY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLECALENDARDAY',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLECALENDARDAY' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_wage_dlgTableCalendarDay.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLECALENDARDAY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLECALENDARDAY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

function TgdcTableCalendarDay.GetNotCopyField: String; 
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCTABLECALENDARDAY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try 
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLECALENDARDAY', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLECALENDARDAY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLECALENDARDAY',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLECALENDARDAY' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
                                                                                 
  // tblcalkey - ссылка на график раб. времени
  Result := inherited GetNotCopyField + ',tblcalkey';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLECALENDARDAY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLECALENDARDAY', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;
   
procedure TgdcTableCalendarDay.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
const
  InfoFields: array[1..8] of String = (
    'wstart1', 'wstart2', 'wstart3', 'wstart4', 'wend1', 'wend2', 'wend3', 'wend4');
var
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCTABLECALENDARDAY', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLECALENDARDAY', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLECALENDARDAY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLECALENDARDAY',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLECALENDARDAY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if FieldByName('workday').AsInteger = 0 then
    begin
      if not FieldByName('THEDAY').IsNull then
      begin
        for I := Low(InfoFields) to High(InfoFields) do
          FieldByName(InfoFields[I]).AsDateTime := FieldByName('THEDAY').AsDateTime;
      end else
      begin
        for I := Low(InfoFields) to High(InfoFields) do
          FieldByName(InfoFields[I]).AsDateTime := 2;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLECALENDARDAY', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLECALENDARDAY', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcTableCalendarDay.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'theday';
end;

class function TgdcTableCalendarDay.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'WG_TBLCALDAY';
end;

function TgdcTableCalendarDay.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCTABLECALENDARDAY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTABLECALENDARDAY', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTABLECALENDARDAY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTABLECALENDARDAY',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTABLECALENDARDAY' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'ORDER BY z.theday ASC';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTABLECALENDARDAY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTABLECALENDARDAY', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcTableCalendarDay.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByTableCalendar;ByDateInterval;';
end;

procedure TgdcTableCalendarDay.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByTableCalendar') then
    S.Add('z.tblcalkey=:TblCalKey');
  if HasSubSet('ByDateInterval') then
    S.Add('z.theday >= :DateBegin AND z.theday <= :DateEnd');  
end;

{ TgdcHoliday }

function TgdcHoliday.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCHOLIDAY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCHOLIDAY', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCHOLIDAY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCHOLIDAY',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCHOLIDAY' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := Tgdc_wage_dlgHoliday.CreateSubType(ParentForm, SubType);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCHOLIDAY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCHOLIDAY', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function TgdcHoliday.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcHoliday.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'WG_HOLIDAY';
end;

class function TgdcHoliday.QIsHoliday(const TheDate: TDate): Boolean;
var
  q: TIBSQL;
  DidActivate: Boolean;
//  Y, M, D: Word;
begin
  Assert(Assigned(gdcBaseManager));
  Assert(Assigned(gdcBaseManager.ReadTransaction));

{  DecodeDate(TheDate, Y, M, D);
  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Database := gdcBaseManager.Database;
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.GoToFirstRecordOnExecute := True;
    DidActivate := not q.Transaction.InTransaction;
    if DidActivate then
      q.Transaction.StartTransaction;
    q.SQL.Text :=
      Format('SELECT id FROM wg_holiday WHERE theday=%d AND themonth=%d',
        [D, M]);
    q.ExecQuery;
    Result := not q.EOF;
    q.Close;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;
    q.Free;
  end;}
  DidActivate := False;
  q := TIBSQL.Create(nil);
  try
    q.Database := gdcBaseManager.Database;
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.GoToFirstRecordOnExecute := True;
    DidActivate := not q.Transaction.InTransaction;
    if DidActivate then
      q.Transaction.StartTransaction;
    q.SQL.Text :=
      Format('SELECT id FROM wg_holiday WHERE holidaydate = ''%s''',
        [DateToStr(TheDate)]);
    q.ExecQuery;
    Result := not q.EOF;
    q.Close;
  finally
    if DidActivate and q.Transaction.InTransaction then
      q.Transaction.Commit;
    q.Free;
  end;
end;

function TgdcHoliday.IsHoliday(const TheDate: TDate): Boolean;
{var
  D, M, Y: Word;
begin
  DecodeDate(TheDate, Y, M, D);
  Result := Locate('theday;themonth', VarArrayOf([D, M]), []);}
begin
  Result := Locate('holidaydate', TheDate, []);
end;

class function TgdcHoliday.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_wage_frmHoliday';
end;

procedure TgdcHoliday.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCHOLIDAY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCHOLIDAY', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCHOLIDAY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCHOLIDAY',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCHOLIDAY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  try
    inherited;
  except
    on E: EIBError do
    begin
      if (E.IBErrorCode = isc_no_dup) then
      begin
        MessageBox(ParentHandle,
          PChar('Государственный праздник на дату ' + FieldByName('HOLIDAYDATE').AsString +
          ' уже существует.'),
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          abort;
      end else
        raise;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCHOLIDAY', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCHOLIDAY', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGDCClasses([TgdcHoliday, TgdcTableCalendar, TgdcTableCalendarDay]);

finalization
  UnRegisterGDCClasses([TgdcHoliday, TgdcTableCalendar, TgdcTableCalendarDay]);
end.
