unit boPhIncomingCall;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  boObject, DB, DBTables, xMsgBox, Ternaries;

type
  TboPhIncomingCall = class(TComponent)
  private
  protected
  public
    StartDate, EndDate: TDateTime;
    {TestUrgency, }AllEmployee, AllAttr, AllCustomer, AllPeople,
      Add, AllOperator: Boolean;
    Answer, SortBy, Day, Month, TypeDate, Customer, People: Integer;
    Employee, Attr, OffAttr, Operators: String;

    FOperator: String;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

//    function AddIncoming(var NewID: Integer): Boolean;
//    function EditIncoming(ID: Integer): Boolean;
    function DeleteIncomings(ID: Integer; DeleteList: TStringList): Boolean;

    procedure LoadOptions;
    procedure SaveOptions;

    function Filter: Boolean;

  published
  end;

procedure Register;

implementation

uses
  PhoneBasics_unit, mmibOptions, dlgIncomingFilter_unit,
  phIncomingCallAttributes;

constructor TboPhIncomingCall.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FOperator := IntToStr(Operator);
  LoadOptions;
end;

destructor TboPhIncomingCall.Destroy;
begin
  SaveOptions;
  inherited Destroy;
end;

procedure TboPhIncomingCall.LoadOptions;
var
  D: TDateTime;
  C: Integer;
  S: String;

begin
  if (ComponentState * [csDesigning, csReading] = []) and (ibOptions <> nil) then
  begin
    if ibOptions.GetDateTime('Ph_IncomingCall_startdate' + FOperator, D) then
      StartDate := D
    else
      StartDate := Now;

    if ibOptions.GetDateTime('Ph_IncomingCall_enddate' + FOperator, D) then
      EndDate := D
    else
      EndDate := Now;

    if ibOptions.GetInteger('Ph_IncomingCall_allemployee' + FOperator, C) then
      AllEmployee := C = 1
    else
      AllEmployee := True;

    if ibOptions.GetInteger('Ph_IncomingCall_AllOperator' + FOperator, C) then
      AllOperator := C = 1
    else
      AllOperator := True;


    if ibOptions.GetInteger('Ph_IncomingCall_allCustomer' + FOperator, C) then
      AllCustomer := C = 1
    else
      AllCustomer := True;

    if ibOptions.GetInteger('Ph_IncomingCall_allPeople' + FOperator, C) then
      AllPeople := C = 1
    else
      AllPeople := True;

    if ibOptions.GetInteger('Ph_IncomingCall_allAttr' + FOperator, C) then
      AllAttr := C = 1
    else
      AllAttr := True;

    if ibOptions.GetInteger('Ph_IncomingCall_Add' + FOperator, C) then
      Add := C = 1
    else
      Add := True;

    if ibOptions.GetInteger('Ph_IncomingCall_answer' + FOperator, C) then
      Answer := C
    else
      Answer := 1;

{    if ibOptions.GetInteger('Ph_IncomingCall_typecall' + FOperator, C) then
      TypeCall := C
    else
      TypeCall := 1;}

{    if ibOptions.GetInteger('Ph_IncomingCall_CallKind' + FOperator, C) then
      CallKind := C
    else
      CallKind := 0;}


{    if ibOptions.GetInteger('Ph_IncomingCall_TestUrgency' + FOperator, C) then
      TestUrgency := C = 1
    else
      TestUrgency := False;}

    if ibOptions.GetInteger('Ph_IncomingCall_sortby' + FOperator, C) then
      SortBy := C
    else
      SortBy := 1;

    if ibOptions.GetInteger('Ph_IncomingCall_Customer' + FOperator, C) then
      Customer := C
    else
      Customer := -1;

    if ibOptions.GetInteger('Ph_IncomingCall_People' + FOperator, C) then
      People := C
    else
      People := -1;

    if ibOptions.GetInteger('Ph_IncomingCall_Day' + FOperator, C) then
      Day := C
    else
      Day := 1;

    if ibOptions.GetInteger('Ph_IncomingCall_Month' + FOperator, C) then
      Month := C
    else
      Month := 1;

    if ibOptions.GetInteger('Ph_IncomingCall_TypeDate' + FOperator, C) then
      TypeDate := C
    else
      TypeDate := 1;

    if ibOptions.GetString('Ph_IncomingCall_Employee' + FOperator, S) then
      Employee := S
    else
      Employee := '';

    if ibOptions.GetString('Ph_IncomingCall_Attr' + FOperator, S) then
      Attr := S
    else
      Attr := '';

    if ibOptions.GetString('Ph_IncomingCall_OffAttr' + FOperator, S) then
      OffAttr := S
    else
      OffAttr := '';

    if ibOptions.GetString('Ph_IncomingCall_Operators' + FOperator, S) then
      Operators := S
    else
      Operators := '';
  end;
end;

procedure TboPhIncomingCall.SaveOptions;
begin
  if (ComponentState * [csDesigning, csReading] = []) and (ibOptions <> nil) then
  begin
    ibOptions.SetDateTime('Ph_IncomingCall_startdate' + FOperator, False, StartDate);
    ibOptions.SetDateTime('Ph_IncomingCall_enddate' + FOperator, False, EndDate);
    ibOptions.SetInteger('Ph_IncomingCall_answer' + FOperator, False, Answer);
{    ibOptions.SetInteger('Ph_IncomingCall_typecall' + FOperator, False, TypeCall);}
{    ibOptions.SetInteger('Ph_IncomingCall_CallKind' + FOperator, False, CallKind);}
    ibOptions.SetInteger('Ph_IncomingCall_SortBy' + FOperator, False, SortBy);
    ibOptions.SetString('Ph_IncomingCall_Employee' + FOperator, False, Employee);
    ibOptions.SetInteger('Ph_IncomingCall_People' + FOperator, False, People);
    ibOptions.SetInteger('Ph_IncomingCall_Customer' + FOperator, False, Customer);
    ibOptions.SetString('Ph_IncomingCall_Attr' + FOperator, False, Attr);
    ibOptions.SetString('Ph_IncomingCall_OffAttr' + FOperator, False, OffAttr);
    ibOptions.SetString('Ph_IncomingCall_Operators' + FOperator, False, Operators);
    ibOptions.SetInteger('Ph_IncomingCall_allemployee' + FOperator, False, Ternary(AllEmployee, 1, 0));
    ibOptions.SetInteger('Ph_IncomingCall_alloperator' + FOperator, False, Ternary(AllOperator, 1, 0));
    ibOptions.SetInteger('Ph_IncomingCall_allPeople' + FOperator, False, Ternary(AllPeople, 1, 0));
    ibOptions.SetInteger('Ph_IncomingCall_allCustomer' + FOperator, False, Ternary(AllCustomer, 1, 0));
    ibOptions.SetInteger('Ph_IncomingCall_allAttr' + FOperator, False, Ternary(AllAttr, 1, 0));
    ibOptions.SetInteger('Ph_IncomingCall_Add' + FOperator, False, Ternary(Add, 1, 0));
    ibOptions.SetInteger('Ph_IncomingCall_Day' + FOperator, False, Day);
    ibOptions.SetInteger('Ph_IncomingCall_Month' + FOperator, False, Month);
    ibOptions.SetInteger('Ph_IncomingCall_TypeDate' + FOperator, False, TypeDate);
  end;
end;

function TboPhIncomingCall.Filter: Boolean;
//var
//  dlgIncomingFilter: TdlgIncomingFilter;
var
  Stamp: TTimeStamp;
begin
//  dlgIncomingFilter := TdlgIncomingFilter.Create(Application);
//  try
    dlgIncomingFilter.dtpStartDate.DateTime := StartDate;
    dlgIncomingFilter.dtpStartTime.DateTime := StartDate;

    dlgIncomingFilter.dtpFinishDate.DateTime := EndDate;
    dlgIncomingFilter.dtpFinishTime.DateTime := EndDate;

    dlgIncomingFilter.cbAllEmployee.Checked := AllEmployee;
    dlgIncomingFilter.cbAllOperator.Checked := AllOperator;
    dlgIncomingFilter.cbAnswer.ItemIndex := Answer;
//    dlgIncomingFilter.cbTypeCall.ItemIndex := TypeCall;
//    dlgIncomingFilter.cbCallKind.ItemIndex := CallKind;
    dlgIncomingFilter.dbgEmployee.ShowChecksByName['name'].Text := Employee;
    dlgIncomingFilter.cbAllAttr.Checked := AllAttr;
    dlgIncomingFilter.cbAdd.Checked := Add;
    dlgIncomingFilter.dbgEmployee.Enabled := not AllEmployee;
    dlgIncomingFilter.dbgAttr.ShowChecksByName['name'].Text := Attr;
    dlgIncomingFilter.dbgOffAttr.ShowChecksByName['name'].Text := OffAttr;
    dlgIncomingFilter.dbgOperator.ShowChecksByName['name'].Text := Operators;
    dlgIncomingFilter.dbgAttr.Enabled := not AllAttr;
    dlgIncomingFilter.edDay.Text := IntToStr(Day);
    dlgIncomingFilter.edMonth.Text := IntToStr(Month);
    dlgIncomingFilter.xdblCustomer.SetNewID(Customer);
    dlgIncomingFilter.xdblPeople.SetNewID(People);
    dlgIncomingFilter.cbCustomer.Checked := AllCustomer;
    dlgIncomingFilter.xdblCustomer.SetNewID(Customer);
    dlgIncomingFilter.cbPeople.Checked := AllPeople;
    dlgIncomingFilter.xdblPeople.Enabled := not AllPeople;
    dlgIncomingFilter.xdblCustomer.Enabled := not AllCustomer;

    case Typedate of
      0: dlgIncomingFilter.rb0.Checked := True;
      1: dlgIncomingFilter.rb1.Checked := True;
      2: dlgIncomingFilter.rb2.Checked := True;
      3: dlgIncomingFilter.rb3.Checked := True;
    end;
    dlgIncomingFilter.MakeEnabled;

    Result := dlgIncomingFilter.ShowModal = mrOk;

    if Result then
    begin
      Stamp.Date := DateTimeToTimeStamp(dlgIncomingFilter.dtpStartDate.DateTime).Date;
      Stamp.Time := DateTimeToTimeStamp(dlgIncomingFilter.dtpStartTime.DateTime).Time;
      StartDate := TimeStampToDateTime(Stamp);

      Stamp.Date := DateTimeToTimeStamp(dlgIncomingFilter.dtpFinishDate.DateTime).Date;
      Stamp.Time := DateTimeToTimeStamp(dlgIncomingFilter.dtpFinishTime.DateTime).Time;
      EndDate := TimeStampToDateTime(Stamp);
      Operators := dlgIncomingFilter.dbgOperator.ShowChecksByName['name'].Text;

      Answer := dlgIncomingFilter.cbAnswer.ItemIndex;
//      TypeCall := dlgIncomingFilter.cbTypeCall.ItemIndex;
//      CallKind := dlgIncomingFilter.cbCallKind.ItemIndex;
      Employee := dlgIncomingFilter.dbgEmployee.ShowChecksByName['name'].Text;
      AllEmployee := dlgIncomingFilter.cbAllEmployee.Checked;
      AllOperator := dlgIncomingFilter.cbAllOperator.Checked;
      Add := dlgIncomingFilter.cbAdd.Checked;
      Attr := dlgIncomingFilter.dbgAttr.ShowChecksByName['name'].Text;
      OffAttr := dlgIncomingFilter.dbgOffAttr.ShowChecksByName['name'].Text;
      AllAttr := dlgIncomingFilter.cbAllAttr.Checked;
      Day := StrToInt(dlgIncomingFilter.edDay.Text);
      Month := StrToInt(dlgIncomingFilter.edMonth.Text);


      if dlgIncomingFilter.rb0.Checked then
        TypeDate := 0;
      if dlgIncomingFilter.rb1.Checked then
        TypeDate := 1;
      if dlgIncomingFilter.rb2.Checked then
        TypeDate := 2;
      if dlgIncomingFilter.rb3.Checked then
        TypeDate := 3;

      Customer := dlgIncomingFilter.xdblCustomer.IDValue;
      AllCustomer := dlgIncomingFilter.cbCustomer.Checked;
      People := dlgIncomingFilter.xdblPeople.IdValue;
      AllPeople := dlgIncomingFilter.cbPeople.Checked;
//      SaveOptions;
    end;
//  finally
//    dlgIncomingFilter.Free;
//  end;
end;

{
  Добавление нового звонка.
}

{function TboPhIncomingCall.AddIncoming(var NewID: Integer): Boolean;
begin
  Result := False;

  if not dlgQuickCall.Visible then
  begin
    // Делаем начальные установки в окне
    dlgQuickCall.HideSelection;
    dlgQuickCall.btnAnswer.Visible := True;
    dlgQuickCall.btnNext.Visible := True;
    dlgQuickCall.ActiveControl := dlgQuickCall.xdblOperator;

    // Добавляем новую запись
    dlgQuickCall.tblIncomingCall.Append;
    dlgQuickCall.tblIncomingCall.FieldByName('startcall').AsDateTime := Now;
    // Если не установлен оператор, то устанавливаем его
    if Operator <> -1 then
      dlgQuickCall.tblIncomingCall.FieldByName('operator').AsInteger := Operator;

    try
      // Получаем уникальный ключ
      dlgQuickCall.spGetGetIncomingcall.ExecProc;

      // Получаем уникальный ключ
      dlgQuickCall.tblIncomingCall.FieldByName('id').AsInteger :=
        dlgQuickCall.spGetGetIncomingCall.Params[0].AsInteger;

      NewID := dlgQuickCall.tblIncomingCall.FieldByName('id').AsInteger;
    except
      // Получаем уникальный ключ
      if dlgQuickCall.spGetGetIncomingcall.Prepared then
        dlgQuickCall.spGetGetIncomingcall.UnPrepare;

      dlgQuickCall.spGetGetIncomingcall.Prepare;
      dlgQuickCall.spGetGetIncomingcall.ExecProc;

      // Получаем уникальный ключ
      dlgQuickCall.tblIncomingCall.FieldByName('id').AsInteger :=
        dlgQuickCall.spGetGetIncomingCall.Params[0].AsInteger;

      NewID := dlgQuickCall.tblIncomingCall.FieldByName('id').AsInteger;
    end;

    Result := dlgQuickCall.ShowModal = mrOk;

    if Result then
      AnalyzeICText(NewID, dlgQuickCall.tblIncomingCall.FieldByName('information').AsString);
  end
end;}

{
  Редактирование звонка.
}

{function TboPhIncomingCall.EditIncoming(ID: Integer): Boolean;
begin
  if not dlgQuickCall.Visible then
  begin
    if dlgQuickCall.tblIncomingCall.FindKey([ID]) then
    begin
      // Делаем начальные установки в окне
      dlgQuickCall.HideSelection;
      dlgQuickCall.btnAnswer.Visible := True;
      dlgQuickCall.btnNext.Visible := True;
      dlgQuickCall.ActiveControl := dlgQuickCall.xdblOperator;

      // Переходим в режим редактирования
      dlgQuickCall.tblIncomingCall.Edit;

      // Выбираем сотрудников
      dlgQuickCall.qrySelectEmployee.Close;

      dlgQuickCall.qrySelectEmployee.ParamByName('incomingcallkey').AsInteger :=
        dlgQuickCall.tblIncomingCall.FieldByName('id').AsInteger;

      // Переносим их в Grid
      dlgQuickCall.qrySelectEmployee.Open;
      dlgQuickCall.qrySelectEmployee.First;
      while not dlgQuickCall.qrySelectEmployee.Eof do
      begin
        dlgQuickCall.dbgEmployee.ShowChecksByName['name'].Add(
          dlgQuickCall.qrySelectEmployee.FieldByName('peoplekey').AsString);

        dlgQuickCall.qrySelectEmployee.Next;
      end;
      dlgQuickCall.qrySelectEmployee.Close;

      // Выбиарем атрибуты
      dlgQuickCall.qrySelectAttr.Close;

      dlgQuickCall.qrySelectAttr.ParamByName('incomingcallkey').AsInteger :=
        dlgQuickCall.tblIncomingCall.FieldByName('id').AsInteger;

      // Переносим их в Grid
      dlgQuickCall.qrySelectAttr.Open;
      dlgQuickCall.qrySelectAttr.First;
      while not dlgQuickCall.qrySelectAttr.Eof do
      begin
        dlgQuickCall.dbgAttr.ShowChecksByName['name'].Add(
          dlgQuickCall.qrySelectAttr.FieldByName('attrkey').AsString);

        dlgQuickCall.dbgAttr.OpenKey(
          dlgQuickCall.qrySelectAttr.FieldByName('attrkey').AsInteger);

        dlgQuickCall.qrySelectAttr.Next;
      end;

      Result := dlgQuickCall.ShowModal = mrOk;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;}

{
  Удаление звонка.
}

function TboPhIncomingCall.DeleteIncomings(ID: Integer; DeleteList: TStringList): Boolean;
var
  qryDeleteIncoming: TQuery;
  I: Integer;
begin
  Result := False;
  qryDeleteIncoming := TQuery.Create(Self);
  try
    if (DeleteList <> nil) and (DeleteList.Count <> 0) then
    begin
      if MessageBox(
          0, 'Удалить звоноки?', 'Внимание!',
          MB_YESNO + MB_ICONQUESTION
        ) = mrYes then
      begin
        for I := 0 to DeleteList.Count - 1 do
        begin
          qryDeleteIncoming.DatabaseName := 'xxx';
          qryDeleteIncoming.SQL.Text := 'DELETE FROM ph_incomingcall WHERE ' +
            ' id = ' + DeleteList.Strings[I];
          qryDeleteIncoming.ExecSQL;
        end;

        Result := True;
      end;
    end else begin
      if MessageBox(
          0, 'Удалить звонок?', 'Внимание!',
          MB_YESNO + MB_ICONQUESTION
        ) = mrYes then
      begin
        qryDeleteIncoming.DatabaseName := 'xxx';
        qryDeleteIncoming.SQL.Text := Format('DELETE FROM ph_incomingcall WHERE ' +
          ' id = %d', [ID]);
        qryDeleteIncoming.ExecSQL;
        Result := True;
      end;
    end;
  finally
    qryDeleteIncoming.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('x-BORent', [TboPhIncomingCall]);
end;

end.

