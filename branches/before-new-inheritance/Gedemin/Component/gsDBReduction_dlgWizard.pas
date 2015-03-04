
{++
         28.08.2003     Yuri     Подправил работу с таблицей (св-во ChangeDestEnabled)
--}

unit gsDBReduction_dlgWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ActnList, StdCtrls, Buttons, gsIBLookupComboBox, ExtCtrls,
  Grids, jpeg, gsDBReduction, ImgList, Menus;

type
  TdlgWizard = class(TForm)
    alNext: TActionList;
    actNext: TAction;
    actPrior: TAction;
    actExit: TAction;
    pcReduce: TPageControl;
    tsFirst: TTabSheet;
    tsSecond: TTabSheet;
    tsThird: TTabSheet;
    Label1: TLabel;
    gsibluCondemned: TgsIBLookupComboBox;
    Label2: TLabel;
    gsibluMaster: TgsIBLookupComboBox;
    Bevel1: TBevel;
    Label3: TLabel;
    Panel1: TPanel;
    cbChangeDest: TCheckBox;
    sgReduction: TStringGrid;
    imgTransfer: TImage;
    imgNotTransfer: TImage;
    ts4: TTabSheet;
    Label4: TLabel;
    cbOk: TCheckBox;
    lbOk: TLabel;
    Memo1: TMemo;
    pmReduction: TPopupMenu;
    actSum: TAction;
    miSumma: TMenuItem;
    bForward: TBitBtn;
    bBack: TBitBtn;
    bClose: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Button1: TButton;
    actChange: TAction;
    Label5: TLabel;
    Label6: TLabel;
    rgAfterAction: TRadioGroup;
    procedure actExitExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actPriorUpdate(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPriorExecute(Sender: TObject);
    procedure cbChangeDestClick(Sender: TObject);
    procedure sgReductionDrawCell(Sender: TObject; ACol, ARow: Integer;
      ARect: TRect; State: TGridDrawState);
    procedure sgReductionKeyPress(Sender: TObject; var Key: Char);
    procedure sgReductionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure gsibluMasterEnter(Sender: TObject);
    procedure actSumExecute(Sender: TObject);
    procedure actSumUpdate(Sender: TObject);
    procedure actChangeExecute(Sender: TObject);
    procedure actChangeUpdate(Sender: TObject);
  private
    FReduction: TgsDBReductionWizard;
    FisReduction: Boolean;
    FChangeDestEnabled: Boolean;
  public
    property Reduction: TgsDBReductionWizard write FReduction;
    property isReduction: Boolean read FisReduction;
    property ChangeDestEnabled: Boolean read FChangeDestEnabled write FChangeDestEnabled;
  end;

var
  dlgWizard: TdlgWizard;

implementation

{$R *.DFM}

uses
  gdcBase, at_Classes
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure TdlgWizard.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TdlgWizard.actNextUpdate(Sender: TObject);
begin
  {$IFNDEF DUNIT_TEST}
  if pcReduce.ActivePage = tsThird then
    TAction(Sender).Enabled := cbOk.Checked
  else
  {$ENDIF}
    TAction(Sender).Enabled := True;
end;

procedure TdlgWizard.actPriorUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (pcReduce.ActivePage = tsSecond) or
    (pcReduce.ActivePage = tsThird);
end;

procedure TdlgWizard.actNextExecute(Sender: TObject);

  procedure MakeCol(RTable: TReductionTable);
  var
    I: Integer;
    Field: TatRelationField;
  begin
    for I := 0 to RTable.ReductionField.Count - 1 do
    begin
      sgReduction.RowCount := sgReduction.RowCount + 1;
      if sgReduction.RowCount = 2 then
        sgReduction.FixedRows := 1;
      sgReduction.Rows[sgReduction.RowCount - 1].Clear;

      Field := atDatabase.FindRelationField(RTable.Name, RTable.ReductionField.Fields[I].FieldName);

      if Field <> nil then
        sgReduction.Rows[sgReduction.RowCount - 1].Add(Field.LName)
      else
        sgReduction.Rows[sgReduction.RowCount - 1].Add(RTable.ReductionField.Fields[I].FieldName);

      sgReduction.Rows[sgReduction.RowCount - 1].Add(
        VarToStr(RTable.ReductionField.Fields[I].CondemnedValue));
      sgReduction.Rows[sgReduction.RowCount - 1].AddObject(
        VarToStr(RTable.ReductionField.Fields[I].MasterValue), RTable.ReductionField.Fields[I]);
    end;

    for I := 0 to RTable.ReductionTableList.Count - 1 do
      MakeCol(RTable.ReductionTableList.Table[I]);
  end;

var
  MasterClass, CondemnedClass: TgdcFullClass;
  S: String;

begin
  if pcReduce.ActivePageIndex = 1 then
  begin
    if (gsibluCondemned.CurrentKey > '') and (gsibluMaster.CurrentKey > '')
      and (gsibluCondemned.gdClass <> nil) and (gsibluMaster.gdClass <> nil) then
    begin
      MasterClass :=
        GetClassForObjectByID(
          gsibluMaster.Database,
          gsibluMaster.Transaction,
          gsibluMaster.gdClass,
          gsibluMaster.SubType,
          gsibluMaster.CurrentKeyInt);

      CondemnedClass :=
        GetClassForObjectByID(
          gsibluCondemned.Database,
          gsibluCondemned.Transaction,
          gsibluCondemned.gdClass,
          gsibluCondemned.SubType,
          gsibluCondemned.CurrentKeyInt);

      if (MasterClass.gdClass = nil) or (CondemnedClass.gdClass = nil) then
      begin
        MessageBox(Handle,
          'Невозможно определить класс записи.',
          'Внимание',
          MB_OK or MB_ICONHAND);
        if gsibluCondemned.Visible and (pcReduce.ActivePage = tsFirst) then
          gsibluCondemned.SetFocus;
        exit;
      end;

      // идея такая: объединять можно записи или одного типа или
      // если класс мастер записи (той которая останется) наследуется
      // от класса записи, которая удалится.
      // в этом случае мы можем гарантировать что ничего не
      // пропадет.
      // в противном случае, если мы, например, объединяем
      // банк с компанией и компания главная запись, то все
      // что ссылается на таблицу GD_BANK в удаляемой записи
      // пропадет.
      if not MasterClass.gdClass.InheritsFrom(CondemnedClass.gdClass) then
      begin
        MessageBox(Handle,
          'Нельзя объединить записи разных типов.',
          'Внимание',
          MB_OK or MB_ICONHAND);
        if gsibluCondemned.Visible and (pcReduce.ActivePage = tsFirst) then
          gsibluCondemned.SetFocus;
        exit;
      end;
    end;

    if rgAfterAction.ItemIndex = 1 then
      S := 'сохранена'
    else
      S := 'удалена';

    lbOk.Caption :=
      'Запись: ' + #10#13 +
      'ИД:  ' + gsibluCondemned.CurrentKey + #10#13 +
      'Имя: ' + gsibluCondemned.Text + #10#13 +
      'будет ' + S + '. ' + #10#13#10#13 +
      'Все ссылки на эту запись ' + #10#13 +
      'будут переадресованы на запись: ' + #10#13 +
      'ИД:  ' + gsibluMaster.CurrentKey + #10#13 +
      'Имя: ' + gsibluMaster.Text + #10#13#10#13 +
      'Вы уверены, что хотите объединить эти записи?';
    cbOk.Checked := False;
  end;

  if pcReduce.ActivePageIndex = 2 then
  begin
    FReduction.TransferData := ChangeDestEnabled;
    FReduction.RenameRecord := rgAfterAction.ItemIndex = 1;
    if not FReduction.MakeReduction then
      exit
    else
      FisReduction := True;
  end;

  if pcReduce.ActivePageIndex = 0 then
  begin
    if (gsibluCondemned.CurrentKey = '') or (gsibluMaster.CurrentKey = '') then
    begin
      MessageBox(Handle,
        'Необходимо выбрать оба объекта для объединения.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;

    if gsibluCondemned.CurrentKey = gsibluMaster.CurrentKey then
    begin
      MessageBox(Handle,
        'Необходимо выбрать разные объекты для объединения.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;

    FReduction.MasterKey := gsibluMaster.CurrentKey;
    FReduction.CondemnedKey := gsibluCondemned.CurrentKey;
    if not FReduction.Prepare then
      exit;

    sgReduction.ColWidths[1] :=
      Trunc((sgReduction.Width - GetSystemMetrics(SM_CYHSCROLL)) / 4);
    sgReduction.ColWidths[2] := sgReduction.ColWidths[1];
    sgReduction.ColWidths[3] := sgReduction.ColWidths[1];
    sgReduction.ColWidths[0] := sgReduction.Width - sgReduction.ColWidths[1] * 3 -
      GetSystemMetrics(SM_CYHSCROLL) * 2;

    sgReduction.Cells[0, 0] := 'Поле';
    sgReduction.Cells[1, 0] := 'Удаляемая запись';
    sgReduction.Cells[2, 0] := 'Главная запись';
    sgReduction.Cells[3, 0] := 'Получаемая запись';

    sgReduction.RowCount := 1;

    MakeCol(FReduction.ReductionTable);
  end;


  if pcReduce.ActivePageIndex = 3 then
  begin
    pcReduce.ActivePageIndex := 0;
    gsibluCondemned.CurrentKey := '';
    gsibluCondemned.Text := '';
    {$IFDEF DUNIT_TEST}
    PostMessage(bClose.Handle, BM_CLICK, 0, 0);
    {$ENDIF}
  end
  else
  begin
    pcReduce.ActivePageIndex := pcReduce.ActivePageIndex + 1;
    {$IFDEF DUNIT_TEST}
    PostMessage(bForward.Handle, BM_CLICK, 0, 0);
    {$ENDIF}
  end;
end;

procedure TdlgWizard.actPriorExecute(Sender: TObject);
begin
  pcReduce.ActivePageIndex := pcReduce.ActivePageIndex - 1;
end;

procedure TdlgWizard.cbChangeDestClick(Sender: TObject);
begin
//  sgReduction.Enabled := cbReduceNullField.Checked;
  ChangeDestEnabled := cbChangeDest.Checked;
end;

procedure TdlgWizard.sgReductionDrawCell(Sender: TObject; ACol,
  ARow: Integer; ARect: TRect; State: TGridDrawState);
var
  S: String;
begin
  if (State * [gdSelected, gdFocused]) <> [] then
  begin
    sgReduction.Canvas.Brush.Color := clBtnFace;
    sgReduction.Canvas.FillRect(ARect);
  end;

  if ((ACol = 1) or (ACol = 2)) and (ARow <> 0) then
  begin
    if ((ACol = 1) and (sgReduction.Rows[ARow].Objects[2] as TrField).Transfer) or
       ((ACol = 2) and not (sgReduction.Rows[ARow].Objects[2] as TrField).Transfer) then
      sgReduction.Canvas.Font.Color := clBlack
    else
      sgReduction.Canvas.Font.Color := clSilver;
    sgReduction.Canvas.TextOut(ARect.Left + 2, ARect.Top + 2, sgReduction.Cells[ACol, ARow]);
  end;

  if (ACol = 3) and (ARow <> 0) then
  begin
    sgReduction.Canvas.Font.Color := clBlack;
    if (sgReduction.Rows[ARow].Objects[2] as TrField).Summa then
    begin
      if (VarType((sgReduction.Rows[ARow].Objects[2] as TrField).CondemnedValue) = varString)
        or (VarType((sgReduction.Rows[ARow].Objects[2] as TrField).MasterValue) = varString) then
        S := VarToStr((sgReduction.Rows[ARow].Objects[2] as TrField).CondemnedValue) + ' ' +
             VarToStr((sgReduction.Rows[ARow].Objects[2] as TrField).MasterValue)
      else
        S := VarToStr(VarAsType((sgReduction.Rows[ARow].Objects[2] as TrField).CondemnedValue, varDouble) +
             VarAsType((sgReduction.Rows[ARow].Objects[2] as TrField).MasterValue, varDouble));
      sgReduction.Canvas.Font.Color := clRed;
    end
    else if (sgReduction.Rows[ARow].Objects[2] as TrField).Transfer then
    begin
      S := VarToStr((sgReduction.Rows[ARow].Objects[2] as TrField).CondemnedValue);
      sgReduction.Canvas.Font.Color := clBlue;
    end
    else
      S := VarToStr((sgReduction.Rows[ARow].Objects[2] as TrField).MasterValue);

    sgReduction.Canvas.TextOut(ARect.Left + 2, ARect.Top + 2, S);
  end;
end;

procedure TdlgWizard.sgReductionKeyPress(Sender: TObject; var Key: Char);
begin
  if ChangeDestEnabled and
     ((sgReduction.Col = 1) or (sgReduction.Col = 2)) and (sgReduction.Row <> 0) and
     (Key = ' ') and
     (sgReduction.Rows[sgReduction.Row].Objects[2] is TrField) then
  begin
    (sgReduction.Rows[sgReduction.Row].Objects[2] as TrField).Transfer :=
      sgReduction.Col = 1;
    sgReduction.Refresh;
{    sgReductionDrawCell(sgReduction, sgReduction.Col, sgReduction.Row,
      sgReduction.CellRect(1, sgReduction.Row), [gdSelected]);
    sgReductionDrawCell(sgReduction, sgReduction.Col, sgReduction.Row,
      sgReduction.CellRect(2, sgReduction.Row), [gdSelected])}
  end;
end;

procedure TdlgWizard.sgReductionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin                       
  if (ssDouble in Shift) and ChangeDestEnabled and 
     ((sgReduction.Col = 1) or (sgReduction.Col = 2)) and (sgReduction.Row <> 0) and
     (sgReduction.Rows[sgReduction.Row].Objects[2] is TrField) then
  begin
    (sgReduction.Rows[sgReduction.Row].Objects[2] as TrField).Transfer :=
      sgReduction.Col = 1;
    sgReduction.Refresh;
  end;
end;

procedure TdlgWizard.FormActivate(Sender: TObject);
begin
  if Visible and (pcReduce.ActivePage = tsFirst) then
    gsibluCondemned.SetFocus;

  {$IFDEF DUNIT_TEST}
  PostMessage(bForward.Handle, BM_CLICK, 0, 0);
  {$ENDIF}
end;

procedure TdlgWizard.FormCreate(Sender: TObject);
begin
  FisReduction := False;
  ChangeDestEnabled := True;

  Image2.Picture := Image1.Picture;
  Image3.Picture := Image1.Picture;
end;

{
  Класс удаляемой и мастер записи должен совпадать.
  Нельзя объединять Компанию и Человека.
}
procedure TdlgWizard.gsibluMasterEnter(Sender: TObject);
var
  Obj: TgdcBase;
begin
  if gsibluCondemned.CurrentKey > '' then 
  begin 
    if gsibluCondemned.gdClass <> nil then
    begin
      try
        Obj := gsibluCondemned.gdClass.CreateSingularByID(nil,
          gsibluCondemned.Database, gsibluCondemned.Transaction,
          gsibluCondemned.CurrentKeyInt, gsibluCondemned.SubType);
        try
          if Obj <> nil then
            gsibluMaster.gdClassName := Obj.GetCurrRecordClass.gdClass.ClassName;
        finally
          Obj.Free;
        end;
      except
        MessageBox(Handle,
          PChar(
          'Невозможно найти запись с ID = ' + gsibluCondemned.CurrentKey + #13#10#13#10 +
          'Возможно нарушена целостность данных.'#13#10 +
          'Обратитесь к системному администратору.'
          ),
          'Внимание',
          MB_OK or MB_ICONERROR);
      end;
    end;
  end else
    gsibluMaster.gdClassName := gsibluCondemned.gdClassName;
end;

procedure TdlgWizard.actSumExecute(Sender: TObject);
begin
  if Assigned(sgReduction.Rows[sgReduction.Row].Objects[2]) then
  begin
    actSum.Checked := not actSum.Checked;

    (sgReduction.Rows[sgReduction.Row].Objects[2] as TrField).Summa :=
      actSum.Checked;

    sgReduction.Refresh;
  end;  
end;

procedure TdlgWizard.actSumUpdate(Sender: TObject);
begin
  if Assigned(sgReduction.Rows[sgReduction.Row].Objects[2]) then
  begin
    actSum.Checked := (sgReduction.Rows[sgReduction.Row].Objects[2] as TrField).Summa;
    actSum.Enabled := ChangeDestEnabled and
                      (sgReduction.Rows[sgReduction.Row].Objects[2] as TrField).Summable;
  end;                
end;

procedure TdlgWizard.actChangeExecute(Sender: TObject);
var
  M, S, C, T: String;
begin
  M := gsibluMaster.CurrentKey;
  S := gsibluCondemned.CurrentKey;

  C := gsibluMaster.gdClassName;
  gsibluMaster.gdClassName := gsibluCondemned.gdClassName;
  gsibluCondemned.gdClassName := C;

  T := gsibluMaster.SubType;
  gsibluMaster.SubType := gsibluCondemned.SubType;
  gsibluCondemned.SubType := T;

  gsibluMaster.CurrentKey := S;
  gsibluCondemned.CurrentKey := M;
end;

procedure TdlgWizard.actChangeUpdate(Sender: TObject);
begin
  actChange.Enabled := (gsibluCondemned.CurrentKey <> gsibluMaster.CurrentKey);
end;

end.

