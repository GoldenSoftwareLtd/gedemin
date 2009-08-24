
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    flt_dlg_dlgQueryParam_unit.pas

  Abstract

    Gedemin project. Main window which is called from Gedemin
    on Global Param variable event.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    20.10.01    JKL        Initial version.
    1.01    02.01.03    DAlex      Support "no query" parameters.

--}

unit flt_dlg_dlgQueryParam_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, flt_dlg_frmParamLine_unit, prm_ParamFunctions_unit,
  ComCtrls, Spin, xCalc, Mask, xDateEdits, xCalculatorEdit, gd_AttrComboBox,
  IBDatabase, gsIBLookupComboBox, ContNrs;

type
  TdlgQueryParam = class(TForm)
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ScrollBox1: TScrollBox;
    Timer1: TTimer;
    pnlName: TPanel;
    lblFilterName: TLabel;
    lblFormName: TLabel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOKClick(Sender: TObject);

  private
    FHint: THintWindow;
    FLineList: TObjectList;
    FParamList: TgsParamList;

    procedure ShowHint(const AnComment: String; const X, Y: SmallInt);

  public
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    function QueryParams(const AnParamList: TgsParamList): Boolean;
  end;

var
  dlgQueryParam: TdlgQueryParam;

implementation

uses
  flt_ScriptInterface, flt_EnumComboBox
  {$IFDEF GEDEMIN}
  , Storages, gd_security
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

type
  TWinControlCrack = class(TWinControl)
  end;

{ TdlgQueryParam }

function TdlgQueryParam.QueryParams(const AnParamList: TgsParamList): Boolean;
var
  FWinCtrl: TWinControl;
  SizeScreenY: Integer;
  S: String;

  function GetLinesHeight: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to FLineList.Count - 2 do
      Result := Result + Tdlg_frmParamLine(FLineList.Items[I]).Height;
  end;

  procedure SetValues(const AnList: TStrings; AnSource: Variant);
  var
    K, Tmp: Integer;
  begin
    AnList.Clear;
    if VarIsArray(AnSource) then
      for K := VarArrayLowBound(AnSource, 1) to VarArrayHighBound(AnSource, 1) do
      try
        Tmp := AnSource[K];
        AnList.AddObject('', Pointer(Tmp));
      except
      end;
  end;

  procedure AddLines(const LocParamList: TgsParamList);
  var
    I: Integer;
    TempStr: String;
    Cond: String;
  begin
    for I := 0 to LocParamList.Count - 1 do
    begin
      if LocParamList.Params[I].ParamType = prmNoQuery then
        LocParamList.Params[I].ResultValue := Unassigned
      else begin
        FLineList.Add(Tdlg_frmParamLine.Create(nil));
        case LocParamList.Params[I].ParamType of
          prmInteger:
          begin
            FWinCtrl := TSpinEdit.Create(nil);
            try
              TSpinEdit(FWinCtrl).Value := LocParamList.Params[I].ResultValue;
            except
            end;
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
          end;

          prmFloat:
          begin
            FWinCtrl := TxCalculatorEdit.Create(nil);
            TxCalculatorEdit(FWinCtrl).DecDigits := -1;
            try
              TxCalculatorEdit(FWinCtrl).Value := LocParamList.Params[I].ResultValue;
            except
            end;
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
          end;

          prmString:
          begin
            FWinCtrl := TEdit.Create(nil);
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              TEdit(FWinCtrl).Text := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

          prmDate:
          begin
            FWinCtrl := TxDateEdit.Create(nil);
            TxDateEdit(FWinCtrl).ConvertErrorMessage := False;
            TxDateEdit(FWinCtrl).Kind := kDate;
            TxDateEdit(FWinCtrl).DateTime := Date;
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              TxDateEdit(FWinCtrl).DateTime := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

          prmDateTime:
          begin
            FWinCtrl := TxDateEdit.Create(nil);
            TxDateEdit(FWinCtrl).ConvertErrorMessage := False;
            TxDateEdit(FWinCtrl).Kind := kDateTime;
            TxDateEdit(FWinCtrl).DateTime := Now;
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              TxDateEdit(FWinCtrl).DateTime := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

          prmTime:
          begin
            FWinCtrl := TxDateEdit.Create(nil);
            TxDateEdit(FWinCtrl).ConvertErrorMessage := False;
            TxDateEdit(FWinCtrl).Kind := kTime;
            TxDateEdit(FWinCtrl).DateTime := Time;
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              TxDateEdit(FWinCtrl).DateTime := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

          prmLinkSet:
          begin
            FWinCtrl := TgsComboBoxAttrSet.Create(nil);
            TgsComboBoxAttrSet(FWinCtrl).Style := csDropDownList;
            TgsComboBoxAttrSet(FWinCtrl).TableName := LocParamList.Params[I].LinkTableName;
            TgsComboBoxAttrSet(FWinCtrl).FieldName := LocParamList.Params[I].LinkDisplayField;
            TgsComboBoxAttrSet(FWinCtrl).PrimaryName := LocParamList.Params[I].LinkPrimaryField;
            TgsComboBoxAttrSet(FWinCtrl).Database := FDatabase;
            TgsComboBoxAttrSet(FWinCtrl).Transaction := FTransaction;
            TgsComboBoxAttrSet(FWinCtrl).UserAttr := False;
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              if LocParamList.Params[I].LinkConditionFunction > '' then
              begin
                if (LocParamList.Params[I].LinkFunctionLanguage > '') and
                 Assigned(FilterScript) then
                  Cond := FilterScript.GetScriptResult('=' + LocParamList.Params[I].LinkConditionFunction,
                   LocParamList.Params[I].LinkFunctionLanguage, TempStr)
                else
                  Cond := LocParamList.Params[I].LinkConditionFunction;
                TgsComboBoxAttrSet(FWinCtrl).Condition := Cond;
              end;
              if VarIsArray(LocParamList.Params[I].ResultValue) then
                SetValues(TgsComboBoxAttrSet(FWinCtrl).ValueID, LocParamList.Params[I].ResultValue);
              TgsComboBoxAttrSet(FWinCtrl).ShowHint := True;
              TgsComboBoxAttrSet(FWinCtrl).ValueIDChange(nil);
            except
            end;
          end;

          prmLinkElement:
          begin
            FWinCtrl := TgsIBLookupComboBox.Create(nil);
            TgsIBLookupComboBox(FWinCtrl).ListTable := LocParamList.Params[I].LinkTableName;
            TgsIBLookupComboBox(FWinCtrl).ListField := LocParamList.Params[I].LinkDisplayField;
            TgsIBLookupComboBox(FWinCtrl).KeyField := LocParamList.Params[I].LinkPrimaryField;
            TgsIBLookupComboBox(FWinCtrl).Database := FDatabase;
            TgsIBLookupComboBox(FWinCtrl).Transaction := FTransaction;
            TgsIBLookupComboBox(FWinCtrl).ShowHint := True;
            TgsIBLookupComboBox(FWinCtrl).SortOrder := TgsSortOrder(LocParamList.Params[I].SortOrder);
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              if LocParamList.Params[I].LinkConditionFunction > '' then
              begin
                if (LocParamList.Params[I].LinkFunctionLanguage > '') and
                 Assigned(FilterScript) then
                  TgsIBLookupComboBox(FWinCtrl).Condition := FilterScript.GetScriptResult('=' + LocParamList.Params[I].LinkConditionFunction,
                   LocParamList.Params[I].LinkFunctionLanguage, TempStr)
                else
                  TgsIBLookupComboBox(FWinCtrl).Condition := LocParamList.Params[I].LinkConditionFunction;
              end;
              if VarIsArray(LocParamList.Params[I].ResultValue) then
                TgsIBLookupComboBox(FWinCtrl).CurrentKeyInt := LocParamList.Params[I].ResultValue[0];
            except
            end;
          end;

          prmBoolean:
          begin
            FWinCtrl := TCheckBox.Create(nil);
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            try
              TCheckBox(FWinCtrl).Checked := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

          prmEnumElement:
          begin
            FWinCtrl := TfltDBEnumComboBox.Create(nil);
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            TfltDBEnumComboBox(FWinCtrl).Style := csDropDownList;
            TfltDBEnumComboBox(FWinCtrl).TableName := LocParamList.Params[I].LinkTableName;
            TfltDBEnumComboBox(FWinCtrl).FieldName := LocParamList.Params[I].LinkDisplayField;
            TfltDBEnumComboBox(FWinCtrl).Database := FDatabase;
            try
              TfltDBEnumComboBox(FWinCtrl).QuoteSelected := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

          prmEnumSet:
          begin
            FWinCtrl := TfltDBEnumSetComboBox.Create(nil);
            Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).AddWinControl(FWinCtrl);
            TfltDBEnumSetComboBox(FWinCtrl).Style := csDropDownList;
            TfltDBEnumSetComboBox(FWinCtrl).TableName := LocParamList.Params[I].LinkTableName;
            TfltDBEnumSetComboBox(FWinCtrl).FieldName := LocParamList.Params[I].LinkDisplayField;
            TfltDBEnumSetComboBox(FWinCtrl).Database := FDatabase;
            try
              TfltDBEnumSetComboBox(FWinCtrl).QuoteSelected := LocParamList.Params[I].ResultValue;
            except
            end;
          end;

        else
          raise Exception.Create('Тип параметра не поддерживается.');
        end;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Parent := Self.ScrollBox1;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Top := GetLinesHeight;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Align := alTop;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Visible := True;
        S := Trim(LocParamList.Params[I].DisplayName);
        if (S > '') and (S[Length(S)] <> ':') then
          S := S + ':';
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).lblName.Caption := S;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).lblName.FocusControl := FWinCtrl;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).lblName.Hint :=
          LocParamList.Params[I].Comment;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Comment :=
          LocParamList.Params[I].Comment;
        Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).EventComment := ShowHint;
        if Self.Height + Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Height < SizeScreenY then
          Self.Height := Self.Height + Tdlg_frmParamLine(FLineList.Items[FLineList.Count - 1]).Height;
        if LocParamList.Params[I].Required then
          TWinControlCrack(FWinCtrl).Color := $A9FFFF;
      end;
    end;
  end;

begin
  Result := True;
  SizeScreenY := GetSystemMetrics(SM_CYSCREEN);
  FLineList := TObjectList.Create;
  try
    FParamList := AnParamList;
    AddLines(AnParamList);
    if FLineList.Count > 0 then
    begin
      Self.ActiveControl := Tdlg_frmParamLine(FLineList.Items[0]).WinControl;
      Result := ShowModal = mrOK;
    end;
  finally
    FParamList := nil;
    FreeAndNil(FLineList);
  end;
end;

procedure TdlgQueryParam.ShowHint(const AnComment: String; const X, Y: SmallInt);
var
  R: TRect;
begin
  FHint.ReleaseHandle;
  if AnComment > '' then
  begin
    R := FHint.CalcHintRect(200, AnComment, nil);
    FHint.ActivateHint(R, AnComment);
    Timer1.Enabled := True;
  end;
end;

procedure TdlgQueryParam.FormCreate(Sender: TObject);
begin
  FHint := THintWindow.Create(nil);
  FHint.Parent := Self;
end;

procedure TdlgQueryParam.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FHint);
end;

procedure TdlgQueryParam.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  FHint.ReleaseHandle;
end;

procedure TdlgQueryParam.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I: Integer;
begin
  {$IFDEF GEDEMIN}
  //
  if pnlName.Visible then
  begin
    if ((ModalResult = mrCancel) or (ModalResult = mrNone))
      and Assigned(GlobalStorage)
      and Assigned(IBLogin)
      and ((GlobalStorage.ReadInteger('Options\Policy', GD_POL_APPL_FILTERS_ID,
        GD_POL_APPL_FILTERS_MASK, False) and IBLogin.InGroup) = 0) then
    begin
      ModalResult := mrOk;
    end;
  end;
  {$ENDIF}

  if ModalResult = mrOk then
  begin
    ModalResult := mrNone;
    for I := 0 to FLineList.Count - 1 do
      if Tdlg_frmParamLine(FLineList.Items[I]).WinControl is TxDateEdit then
      begin
        (Tdlg_frmParamLine(FLineList.Items[I]).WinControl as TxDateEdit).ConvertErrorMessage := True;
        if Tdlg_frmParamLine(FLineList.Items[I]).WinControl.CanFocus then
          Tdlg_frmParamLine(FLineList.Items[I]).WinControl.SetFocus;
        if btnOK.CanFocus then
          btnOK.SetFocus;
        CanClose := btnOK.Focused;
        (Tdlg_frmParamLine(FLineList.Items[I]).WinControl as TxDateEdit).ConvertErrorMessage := False;
        if not CanClose then
          Exit;
      end;
    if btnOK.CanFocus then
      btnOK.SetFocus;
    ModalResult := mrOk;
  end;
end;

procedure TdlgQueryParam.btnOKClick(Sender: TObject);
var
  DateParamCount: Integer;
  FirstDateValue: TDate;
  TempDateTime: TDateTime;

  function DaysCount(nMonth: Word; nYear: Word): Integer;
  begin
    if nMonth = 2 then
      if isLeapYear(nYear) then
        Result := 29
      else
        Result := 28
    else
      if nMonth in [1, 3, 5, 7, 8, 10, 12] then
        Result := 31
      else
        Result := 30;
  end;

  function CheckcondDateValue(AnSecondDate: TDate): TDate;
  var
    FDay, FMonth, FYear: Word;
    SDay, SMonth, SYear: Word;
    TempDay: Word;
    TempDate: TDate;
  begin
    Result := AnSecondDate;
    if (FirstDateValue > AnSecondDate) or (AnSecondDate = 0) or (FirstDateValue = 0) then
      Exit;
    DecodeDate(FirstDateValue, FYear, FMonth, FDay);
    DecodeDate(AnSecondDate, SYear, SMonth, SDay);
    TempDay := DaysCount(SMonth, SYear);
    if ((SDay = 30) and (TempDay = 31))
     or ((SDay = 28) and (SMonth = 2) and (TempDay = 29)) then
    begin
      TempDate := EncodeDate(SYear, SMonth, TempDay);
      if MessageBox(Handle,
        PChar(Format('Вы ввели дату: %s. Это предпоследний день месяца %s. '#13#10 +
        'Возможно, вы хотели ввести дату: %s?'#13#10#13#10 +
        'Нажмите Да (Yes), чтобы изменить параметр автоматически.'#13#10 +
        'Нажмите Нет (No), чтобы оставить введенную дату без изменений.',
        [DateToStr(AnSecondDate), FormatDateTime('mmmm', AnSecondDate), DateToStr(TempDate)])),
        'Вопрос',
        MB_YESNO or MB_ICONQUESTION) = ID_YES then
      begin
        Result := TempDate;
      end;
    end;
  end;

  function GetResult(const AnIndex: Integer): Variant;
  var
    I: Integer;
  begin
    Result := varUnknown;
    if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TxCalculatorEdit then
      Result := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TxCalculatorEdit).Value
    else
      if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TSpinEdit then
        Result := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TSpinEdit).Value
      else
        if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TEdit then
          Result := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TEdit).Text
        else
          if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TDateTimePicker then
            begin
              TempDateTime := Frac((Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TDateTimePicker).Time);
              Result := VarAsType(TempDateTime, varDate);
            end
          else
            if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TxDateEdit then
            begin
              if (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TxDateEdit).Kind = kDate then
              begin
                TempDateTime := Trunc((Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TxDateEdit).Date);
                Inc(DateParamCount);
                case DateParamCount of
                  1: FirstDateValue := TempDateTime;
                  2: TempDateTime := CheckcondDateValue(TempDateTime);
                end;
                Result := VarAsType(TempDateTime, varDate);
              end else
              begin
                TempDateTime := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TxDateEdit).DateTime;
                Result := VarAsType(TempDateTime, varDate);
              end
            end else
              if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TCheckBox then
              begin
                Result := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TCheckBox).Checked
              end else
                if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TfltDBEnumComboBox then
                begin
                  Result := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TfltDBEnumComboBox).QuoteSelected
                end else
                  if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TfltDBEnumSetComboBox then
                  begin
                    Result := (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TfltDBEnumSetComboBox).QuoteSelected
                  end else
                    if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TgsIBLookupComboBox then
                      Result := VarArrayOf([(Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TgsIBLookupComboBox).CurrentKeyInt])
                    else
                      if Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl is TgsComboBoxAttrSet then
                      begin
                        Result := VarArrayCreate([0, (Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl
                         as TgsComboBoxAttrSet).ValueID.Count - 1], varVariant);
                        for I := 0 to VarArrayHighBound(Result, 1) do
                          Result[I] := Integer((Tdlg_frmParamLine(FLineList.Items[AnIndex]).WinControl as TgsComboBoxAttrSet).ValueID.Objects[I])
                      end else
                        Assert(False, 'This TWinControl isn''t known.');
  end;

  procedure SetResultFromLine(const LocParamList: TgsParamList);

    function EmptyDate(const S: String): Boolean;
    var
      J: Integer;
    begin
      for J := 1 to Length(S) do
      begin
        if S[J] in ['1'..'9'] then
        begin
          Result := False;
          exit;
        end;
      end;
      Result := True;
    end;

  var
    I, QI, K: Integer;
    IsNull: Boolean;
  begin
    DateParamCount := 0;
    QI := 0;
    for I := 0 to LocParamList.Count - 1 do
    with LocParamList.Params[I] do
    begin
      if not (ParamType = prmNoQuery) then
      begin
        ResultValue := GetResult(QI);

        if Required then
        begin
          if VarIsArray(ResultValue) then
          begin
            IsNull := VarArrayLowBound(ResultValue, 1) > VarArrayHighBound(ResultValue, 1);
            for K := VarArrayLowBound(ResultValue, 1) to VarArrayHighBound(ResultValue, 1) do
            begin
              if VarIsNull(ResultValue[K]) or ((VarType(ResultValue[K]) = varInteger) and (ResultValue[K] = -1)) then
              begin
                IsNull := True;
                break;
              end;
            end;
          end
          else
            IsNull := VarIsNull(ResultValue)
              or ((VarType(ResultValue) = varString) and (ResultValue = ''))
              or ((VarType(ResultValue) in [varInteger, varDouble, varCurrency, varSingle, varSmallInt]) and (ResultValue = 0))
              or ((VarType(ResultValue) = varDate) and EmptyDate(ResultValue));

          if IsNull then
          begin
            ActiveControl := Tdlg_frmParamLine(FLineList.Items[QI]).WinControl;
            raise Exception.Create('Необходимо заполнить поле "' + DisplayName + '"');
          end;
        end;

        Inc(QI);
      end;
    end;
  end;

begin
  Assert(FParamList <> nil);
  SetResultFromLine(FParamList);
  ModalResult := mrOk;
end;

end.

