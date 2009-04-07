
{

  Copyright (c) 1996-98 by Golden Software

  Module

    dbSrch.pas

  Abstract

    A dialog box for DBSearch component.

  Author

    Mikle Shoihet (who knows)

  History

    1.00    ????          mikle      Initial version.
    1.01    02-Jun-1997   andreik    Minor change.
    1.02    12-Aug-1997   mikle      Minor change.
    1.03    14-Aug-1997   andreik    Minor change.
    1.04    04-Oct-1997   mikle      Minor change.
    1.05    26-Dec-1997   mikle      Minor cahnge.
    1.06    04-Feb-1998   mikle      Add OkFind event
    1.07    11-Aug-1998   dennis     Addapted for Delphi4. Some bugs corrected.
    1.08    12-Sep-1998   andreik    Dialog color prop added.
    1.09    27-Oct-1998   andreik    Minor changes.
    1.10    09-Nov-1998   andreik    Minor changes.
    1.11    18-Nov-1998   andreik    Minor bug fixed.

}

unit DbSrch;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBCtrls, DbTables, DBGrids, DBFinDlg;

type
  TFindDirection = (fdUp, fdDown, fdAll);
  TFindOption = (foCaseSensitive, foWholeWordsOnly, foRegularExpression,
     foWholeFieldOnly);
  TFindOptions = set of TFindOption;

type
  TDBSearchField = class(TComponent)
  private
    { Private declarations }
    FDataLink: TFieldDataLink;
    FDBGrid: TDBGrid;
    FFindOption: TFindOptions;
    FFindDirection: TFindDirection;

    DBFindDlg: TDBFindDlg;
    IsFirstSrch: Boolean;
    IsNullField: Boolean;
    IsNullGrid: Boolean;

    FOldDestroy: TNotifyEvent;
    FOkFind: TNotifyEvent;
    FDialogColor: TColor;

    FOldOnButtonClick: TNotifyEvent;

    function  GetField: TField;
    function  GetDataField: string;
    function  GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetDBGrid(Value: TDBGrid);
    procedure SetFindOption(Value: TFindOptions);
    procedure SetFindDirection(Value: TFindDirection);

    procedure SearchValue(Sender: TObject);
    procedure EndSearch(Sender: TObject; var Action: TCloseAction);
    procedure MakeOnDestroy(Sender: TObject);

    procedure SearchKey;
    procedure SearchOther;
    procedure SetDialogColor(const Value: TColor);

  protected
    { Protected declarations }
    procedure Loaded;
      override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;

  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure Find;

    property Field: TField read GetField;

  published
    { Published declarations }

    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DBGrid: TDBGrid read FDBGrid write SetDBGrid;
    property FindOption: TFindOptions read FFindOption write SetFindOption;
    property FindDirection: TFindDirection read FFindDirection
             write SetFindDirection;
    property OkFind: TNotifyEvent read FOkFind write FOkFind;
    property DialogColor: TColor read FDialogColor write SetDialogColor
      default clBtnFace;
  end;

procedure Register;

implementation

constructor TDBSearchField.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := TFieldDataLink.Create;
  FDBGrid := nil;

  FFindOption := [];
  FFindDirection := fdAll;

  if not (csDesigning in ComponentState) then
  begin
    DBFindDlg := TDBFindDlg.Create(Self);
    FOldOnButtonClick := DBFindDlg.xbbFind.OnClick;
    DBFindDlg.xbbFind.OnClick := SearchValue;
    DBFindDlg.OnClose := EndSearch;
  end else
    DBFindDlg := nil;

  FOkFind := nil;

  IsFirstSrch := True;

  FDialogColor := clBtnFace;
end;

destructor TDBSearchField.Destroy;
begin
  if FDataLink <> nil then
  begin
    FDataLink.Free;
    FDataLink := nil;
  end;

  if DBFindDlg <> nil then
  begin
    DBFindDlg.Free;
    DBFindDlg := nil;
  end;

  inherited Destroy;
end;

procedure TDBSearchField.Loaded;
begin
  inherited Loaded;

  IsNullField := DataField = '';

  if not (csDesigning in ComponentState) then
  begin
    FOldDestroy := TForm(Owner).OnDestroy;
    TForm(Owner).OnDestroy := MakeOnDestroy;
  end;

  if (not (csDesigning in ComponentState)) and Assigned(DBFindDlg) then
  begin
    DBFindDlg.Color := FDialogColor;
  end;
end;

procedure TDBSearchField.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource)
  then
    DataSource := nil
  else
    if (Operation = opRemove) and (DBGrid <> nil) and (AComponent = DBGrid) then
      DBGrid := nil;
end;


function TDBSearchField.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBSearchField.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TDBSearchField.GetField: TField;
begin
  GetField := FDataLink.Field;
end;

function TDBSearchField.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBSearchField.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TDBSearchField.SetDBGrid(Value: TDBGrid);
begin
  FDBGrid := Value;
end;

procedure TDBSearchField.SetFindOption(Value: TFindOptions);
begin
  FFindOption := Value;
end;

procedure TDBSearchField.SetFindDirection(Value: TFindDirection);
begin
  FFindDirection := Value;
end;

procedure TDBSearchField.Find;
begin
  if DBFindDlg = nil then
    exit;

  IsNullGrid := False;

  if (FDBGrid = nil) and ((Owner as TForm).ActiveControl is TDBGrid) then
  begin
    DBGrid := (Owner as TForm).ActiveControl as TDBGrid;
    IsNullGrid := True;
  end else
    if DBGrid = nil then
    begin
      MessageBox(0, 'Курсор должен быть установлен на одно из полей таблицы.',
        'Внимание', MB_OK or MB_ICONEXCLAMATION);
      Exit;
    end;

  DataSource := DBGrid.DataSource;

  IsNullField := DataField = '';

  with DBFindDlg do
  begin
    MatchCaseCheckBox.Checked := (foCaseSensitive in FFindOption);
    WholeFieldCheckBox.Checked := foWholeFieldOnly in FFindOption;
    SearchComboBox.ItemIndex := 2;
    Show;
  end;
end;

procedure TDBSearchField.SearchValue(Sender: TObject);
begin
  if DBFindDlg = nil then
    exit;

  with DBFindDlg do
  begin
    FindWhatComboBox.Items.Insert(0, FindWhatComboBox.Text);
    FFindOption := [];
    if MatchCaseCheckBox.Checked then
      FFindOption := FFindOption + [foCaseSensitive];

    if WholeFieldCheckBox.Checked then
      FFindOption := FFindOption + [foWholeFieldOnly]
    else
      FFindOption := FFindOption + [foRegularExpression];
  end;

  with FDataLink do
  begin
    try
      if (FieldName = '') and (DBGrid <> nil) then
        FieldName := DBGrid.SelectedField.FieldName;

      if DataSource.DataSet is TTable then
      begin
        if (foWholeFieldOnly in FFindOption) and
           (TTable(DataSource.DataSet).IndexFieldCount > 0) and
           (FieldName = TTable(DataSource.DataSet).IndexFields[0].FieldName)
        then
          SearchKey
        else

          SearchOther;
      end
      else
        SearchOther;

      IsFirstSrch := false;
    except
      MessageBox(
        DBFindDlg.Handle,
        'Курсор должен находится на одном из полей таблицы.', 'Ошибка',
        MB_OK or MB_ICONHAND);
    end;
  end;

  if Assigned(FOldOnButtonClick) then
    FOldOnButtonClick(nil);
end;

procedure TDBSearchField.EndSearch(Sender: TObject; var Action: TCloseAction);
begin
  if DBFindDlg = nil then
    exit;

  DBFindDlg.Hide;

  IsFirstSrch := True;

  if IsNullField then
    DataField := '';

  if csDestroying in ComponentState then
    exit;

  try
    if Assigned(FDBGrid) and FDBGrid.Visible then
      FDBGrid.SetFocus;
  except
    // prevent from focusing disabled windows
  end;

  if IsNullGrid then
    FDBGrid := nil;
end;

procedure TDBSearchField.MakeOnDestroy(Sender: TObject);
var
  Action: TCloseAction;
begin
  Action := caFree;

  if DBFindDlg <> nil then
    EndSearch(Sender, Action);

  if Assigned(FOldDestroy) then FOldDestroy(Sender);
end;

procedure TDBSearchField.SearchKey;
begin
  if DBFindDlg = nil then Exit;

  if not (FDataLink.DataSource.DataSet as TTable).FindKey([DBFindDlg.FindWhatComboBox.Text]) then
    MessageBox(DBFindDlg.HANDLE,
      'Запись не найдена.',
      'Поиск',
      MB_OK or MB_ICONEXCLAMATION)
  else
    if Assigned(FOkFind) then FOkFind(Self);
end;

procedure TDBSearchField.SearchOther;
var
  IsFind: Boolean;
  S, S1: String;
  BK: TBookmark;
  OldDirection: TFindDirection;
begin
  if DBFindDlg = nil then Exit;
  OldDirection := FFindDirection;

  case DBFindDlg.SearchComboBox.ItemIndex of
    0: FFindDirection := fdUp;
    1: FFindDirection := fdDown;
    2:
    begin
      FFindDirection := fdAll;
      DBFindDlg.SearchComboBox.ItemIndex := 1;
    end;
  end;
  
  if (OldDirection <> FFindDirection) and (FFindDirection = fdAll) then
    IsFirstSrch := True;

  BK := FDataLink.DataSource.DataSet.GetBookmark;
  FDataLink.DataSource.DataSet.DisableControls;
  try

    IsFind := false;

    case FFindDirection of
      fdAll:
      begin
        if IsFirstSrch then
          FDataLink.DataSource.DataSet.First
        else
          FDataLink.DataSource.DataSet.Next;
      end;
      fdUp:
        if not IsFirstSrch then
          FDataLink.DataSource.DataSet.Prior;
      fdDown:
        if not IsFirstSrch then
          FDataLink.DataSource.DataSet.Next;
    end;

    while ((FFindDirection = fdUp) and (not FDataLink.DataSource.DataSet.BOF)) or
      ((FFindDirection <> fdUp) and (not FDataLink.DataSource.DataSet.EOF)) do
    begin
      if (foWholeFieldOnly in FFindOption) then
      begin
        if DBFindDlg.FindWhatComboBox.Text =
           FDataLink.DataSource.DataSet.FieldByName(FDataLink.FieldName).Text then
        begin
          IsFind := True;
          Break;
        end;
      end else begin
        if foCaseSensitive in FFindOption then
        begin
          S := DBFindDlg.FindWhatComboBox.Text;
          S1 := FDataLink.DataSource.DataSet.FieldByName(FDataLink.FieldName).Text;
        end else begin
          S := ANSIUpperCase(DBFindDlg.FindWhatComboBox.Text);
          S1 := ANSIUpperCase(FDataLink.DataSource.DataSet.FieldByName(FDataLink.FieldName).Text);
        end;
      
        if Pos(S, S1) > 0 then
        begin
          IsFind := True;
          Break;
        end;
      end;

      if FFindDirection = fdUp then
        FDataLink.DataSource.DataSet.Prior
      else
        FDataLink.DataSource.DataSet.Next;
    end;
  
    if not IsFind then
    begin
      MessageBox(DBFindDlg.HANDLE,
        'Запись не найдена.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION);

      FDataLink.DataSource.DataSet.GotoBookmark(BK);
    end else
      if Assigned(FOkFind) then FOkFind(Self);

  finally
    FDataLink.DataSource.DataSet.EnableControls;
    FDataLink.DataSource.DataSet.FreeBookmark(BK);
  end;
end;

procedure TDBSearchField.SetDialogColor(const Value: TColor);
begin
  FDialogColor := Value;
  if (not (csDesigning in ComponentState)) and Assigned(DBFindDlg) then
  begin
    DBFindDlg.Color := FDialogColor;
    DBFindDlg.UpdateButtons;
  end;
end;

// Registration -------------------------------------------

procedure Register;
begin
  RegisterComponents('x-DataBase', [TDBSearchField]);
end;

end.

