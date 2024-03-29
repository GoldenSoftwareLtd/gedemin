// ShlTanya, 09.03.2019

unit gdv_dlgSelectDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Db, IBCustomDataSet, gdcBase, gdcTree,
  gdcClasses_interface, gdcClasses, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, gsDBTreeView, ActnList, IBSQL, gdcBaseInterface, TB2Item,
  TB2Dock, TB2Toolbar, gdc_createable_form, gsStorage, Storages,
  gd_classList, gsPeriodEdit;

type
  TdlgSelectDocument = class(TgdcCreateableForm)
    pnlBottom: TPanel;
    Button3: TButton;
    pnlDocType: TPanel;
    Splitter1: TSplitter;
    pnlDoc: TPanel;
    tvDocumentType: TgsDBTreeView;
    gdcDocumentType: TgdcBaseDocumentType;
    dsDocumentType: TDataSource;
    dsDocument: TDataSource;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    pLine: TPanel;
    pnlDocHead: TPanel;
    sLine: TSplitter;
    gDocument: TgsIBGrid;
    gDocumentLine: TgsIBGrid;
    dsDocumentLine: TDataSource;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    actNewDocument: TAction;
    actEditDocument: TAction;
    actDeleteDocument: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    Panel4: TPanel;
    Panel6: TPanel;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    TBControlItem2: TTBControlItem;
    lblPeriod: TLabel;
    TBControlItem1: TTBControlItem;
    gsPeriod: TgsPeriodEdit;
    TBSeparatorItem2: TTBSeparatorItem;
    actRun: TAction;
    TBItem4: TTBItem;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure gDocumentLineClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure gDocumentClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure gdcDocumentTypeAfterScroll(DataSet: TDataSet);
    procedure actNewDocumentUpdate(Sender: TObject);
    procedure actNewDocumentExecute(Sender: TObject);
    procedure actEditDocumentExecute(Sender: TObject);
    procedure actDeleteDocumentExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gDocumentDblClick(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
  private
    FDocument: TgdcDocument;
    FDocumentLine: TgdcDocument;
    { Private declarations }

    procedure ShowLinePanel(V: Boolean);
    function GetSelectedId: TID;
    procedure LoadGridSettings(DataSet: TgdcBase; Grid: TgsIBGrid);
    procedure SaveGridSettings(DataSet: TgdcBase; Grid: TgsIBGrid);
  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;

    property SelectedId: TID read GetSelectedId;
  end;

var
  dlgSelectDocument: TdlgSelectDocument;

implementation
uses gsStorage_CompPath;
{$R *.DFM}

procedure TdlgSelectDocument.actOkExecute(Sender: TObject);
begin
  SaveGridSettings(FDocument, gDocument);
  SaveGridSettings(FDocumentLine, gDocumentLine);

  ModalResult := mrOk
end;

procedure TdlgSelectDocument.actCancelExecute(Sender: TObject);
begin
  SaveGridSettings(FDocument, gDocument);
  SaveGridSettings(FDocumentLine, gDocumentLine);

  ModalResult := mrCancel;
end;

procedure TdlgSelectDocument.FormCreate(Sender: TObject);
begin
  gdcDocumentType.Open
end;

procedure TdlgSelectDocument.gDocumentLineClickCheck(Sender: TObject;
  CheckID: String; var Checked: Boolean);
begin
  gDocumentLine.CheckBox.Clear;
  gDocument.CheckBox.Clear;
end;

procedure TdlgSelectDocument.gDocumentClickCheck(Sender: TObject;
  CheckID: String; var Checked: Boolean);
begin
  gDocumentLine.CheckBox.Clear;
  gDocument.CheckBox.Clear;
end;

procedure TdlgSelectDocument.gdcDocumentTypeAfterScroll(DataSet: TDataSet);
var
  F: TgdcFullClass;
begin
  SaveGridSettings(FDocument, gDocument);
  SaveGridSettings(FDocumentLine, gDocumentLine);

  if Visible then
  begin
    dsDocument.DataSet := nil;
    dsDocumentLine.DataSet := nil;
    gDocument.Columns.Clear;
    gDocumentLine.Columns.Clear;
    F := TgdcDocument.GetDocumentClass(GetTID(DataSet.FieldByName('id')), dcpHeader);
    if (DataSet.FieldByName('documenttype').AsString <> 'B') and (F.gdClass <> nil) then
    begin
      if FDocument <> nil then
        FDocument.Free;

      FDocument := TgdcDocument(F.gdClass.Create(Self));
      FDocument.SubType := F.SubType;
      FDocument.MasterSource := dsDocumentType;
      FDocument.MasterField := 'ID';
      FDocument.DetailField := 'documenttype';
      FDocument.ExtraConditions.Add(' z.documenttypekey = :documenttype');
      FDocument.ExtraConditions.Add('z.documentdate >= :datebegin and z.documentdate <= :dateend');
      FDocument.ParamByName('datebegin').AsDateTime := gsPeriod.Date;
      FDocument.ParamByName('dateend').AsDateTime := gsPeriod.EndDate;

      FDocument.Open;
      dsDocument.DataSet := FDocument;
      LoadGridSettings(FDocument, gDocument);
      gDocument.ResizeColumns;

      F := TgdcDocument.GetDocumentClass(GetTID(DataSet.FieldByName('id')), dcpLine);
      if F.gdClass <> nil then
      begin
        if FDocumentLine <> nil then
          FDocumentLine.Free;

        FDocumentLine := TgdcDocument(F.gdClass.Create(Self));
        FDocumentLine.SubType := F.SubType;
        FDocumentLine.MasterSource := dsDocument;
        FDocumentLine.MasterField := 'ID';
        FDocumentLine.DetailField := 'parent';
        FDocumentLine.ExtraConditions.Add(' z.parent = :parent');
        FDocumentLine.Open;
        dsDocumentLine.DataSet := FDocumentLine;
        LoadGridSettings(FDocumentLine, gDocumentLine);
        gDocumentLine.ResizeColumns;
        ShowLinePanel(True);
      end else
      begin
        ShowLinePanel(False);
      end;
    end else
    begin
      if FDocument <> nil then
        FDocument.Free;

      FDocument := TgdcDocument.Create(nil);
      FDocument.ExtraConditions.Add(' z.documenttypekey = ' + DataSet.FieldByName('id').AsString);
      FDocument.ExtraConditions.Add('z.documentdate >= :datebegin and z.documentdate <= :dateend');
      
      FDocument.ParamByName('datebegin').AsDateTime := gsPeriod.Date;
      FDocument.ParamByName('dateend').AsDateTime := gsPeriod.EndDate;

      FDocument.Open;
      dsDocument.DataSet := FDocument;

      ShowLinePanel(False);
    end;
  end;
end;

procedure TdlgSelectDocument.ShowLinePanel(V: Boolean);
begin
  pLine.Visible := V;
  sLine.Visible := V;
  if V then
  begin
    sLine.Top := sLine.Height + pLine.Top;
  end;
end;

function TdlgSelectDocument.GetSelectedId: TID;
begin
  Result := -1;
  if gDocument.CheckBox.CheckList.Count > 0 then
  begin
    Result := GetTID(gDocument.CheckBox.CheckList[0]);
  end else
  if gDocumentLine.CheckBox.CheckList.Count > 0 then
  begin
    Result := GetTID(gDocumentLine.CheckBox.CheckList[0]);
  end;
end;

procedure TdlgSelectDocument.actNewDocumentUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := FDocument <> nil;
end;

procedure TdlgSelectDocument.actNewDocumentExecute(Sender: TObject);
begin
  FDocument.CreateDialog('');
end;

procedure TdlgSelectDocument.actEditDocumentExecute(Sender: TObject);
begin
  FDocument.EditDialog('');
end;

procedure TdlgSelectDocument.actDeleteDocumentExecute(Sender: TObject);
begin
  FDocument.Delete;
end;

procedure TdlgSelectDocument.FormShow(Sender: TObject);
begin
  gdcDocumentTypeAfterScroll(gdcDocumentType);
end;

procedure TdlgSelectDocument.gDocumentDblClick(Sender: TObject);
begin
  actEditDocument.Execute;
end;

procedure TdlgSelectDocument.LoadGridSettings(DataSet: TgdcBase; Grid: TgsIBGrid);

  procedure LoadDefault(F: TgsStorageFolder);
  var
    V: TgsStorageValue;
    S: TStream;
  begin
    V := F.ValueByName('GrSet');
    if Assigned(V) and (V is TgsStringValue) then
    begin
      S := TMemoryStream.Create;
      try
        if UserStorage.ReadStream(V.AsString, 'data', S, False) then
        begin
          Grid.LoadFromStream(S);
          Grid.ResizeColumns;
        end;
      finally
        S.Free;
      end;
    end;
  end;

  procedure Load(F: TgsStorageFolder);
  var
    V: TgsStorageValue;
    S: TStream;
  begin
    V := F.ValueByName('data');
    if Assigned(V) and (V is TgsStreamValue) then
    begin
      S := TMemoryStream.Create;
      try
        (V as TgsStreamValue).SaveDataToStream(S);
        Grid.LoadFromStream(S);
        Grid.ResizeColumns;
      finally
        S.Free;
      end;
    end
    else
    begin
      LoadDefault(F);
    end;
  end;

var
  F: TgsStorageFolder;
  Path: String;
begin
  if Assigned(UserStorage) and Assigned(DataSet) and Assigned(Grid) then
  begin
    Path := 'GDC\' + DataSet.ClassName + DataSet.SubType;
    F := UserStorage.OpenFolder(Path, False);

    if Assigned(F) then
    begin
      try
        Load(F);
      finally
        UserStorage.CloseFolder(F, False);
      end;
    end;
  end;
end;

procedure TdlgSelectDocument.SaveGridSettings(DataSet: TgdcBase; Grid: TgsIBGrid);
var
  F: TgsStorageFolder;
  V: TgsStorageValue;
  S: TStringStream;
  Path: String;
begin
  if Assigned(UserStorage) and Assigned(DataSet) and Assigned(Grid) and (Grid.SettingsModified) then
  begin
    Path := 'GDC\' + DataSet.ClassName + DataSet.SubType;
    S := TStringStream.Create('');
    try
      Grid.SaveToStream(S);

      F := UserStorage.OpenFolder(Path, True, False);
      if Assigned(F) then
      try
        V := F.ValueByName('data');
        if V is TgsStreamValue then
        begin
          if V.AsString = S.DataString then
            exit;
        end;
      finally
        UserStorage.CloseFolder(F, False);
      end;

      F := UserStorage.OpenFolder(Path, True);
      if Assigned(F) then
      try
        if not F.ValueExists('data') then
          F.WriteStream('data', nil);
        V := F.ValueByName('data');
        if V is TgsStreamValue then
          V.AsString := S.DataString;
      finally
        UserStorage.CloseFolder(F);
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TdlgSelectDocument.SaveSettings;
var
  MS: TMemoryStream;
begin
  inherited;

  SaveGrid(gDocument);
  SaveGrid(gDocumentLine);
  if UserStorage <> nil then
  begin
    MS := TMemoryStream.Create;
    try
      tvDocumentType.SaveToStream(MS);
      UserStorage.WriteStream(BuildComponentPath(tvDocumentType), 'TVState', MS);
    finally
      MS.Free;
    end;
    UserStorage.WriteDateTime(BuildComponentPath(gsPeriod), 'DateBegin', gsPeriod.Date);
    UserStorage.WriteDateTime(BuildComponentPath(gsPeriod), 'DateEnd', gsPeriod.EndDate);
  end;
end;

procedure TdlgSelectDocument.LoadSettings;
var
  MS: TMemoryStream;
begin
  inherited;

  LoadGrid(gDocument);
  LoadGrid(gDocumentLine);
  if UserStorage <> nil then
  begin
    MS := TMemoryStream.Create;
    try
      if UserStorage.ReadStream(BuildComponentPath(tvDocumentType), 'TVState', MS) then
        tvDocumentType.LoadFromStream(MS);
    finally
      MS.Free;
    end;
    gsPeriod.AssignPeriod(UserStorage.ReadDateTime(BuildComponentPath(gsPeriod), 'DateBegin', Date),
      UserStorage.ReadDateTime(BuildComponentPath(gsPeriod), 'DateEnd', Date));
  end;
end;

procedure TdlgSelectDocument.actRunExecute(Sender: TObject);
begin

  FDocument.Close;

  FDocument.ParamByName('datebegin').AsDateTime := gsPeriod.Date;
  FDocument.ParamByName('dateend').AsDateTime := gsPeriod.EndDate;

  FDocument.Open;

end;

initialization
  RegisterFrmClass(TdlgSelectDocument);

finalization
  UnRegisterFrmClass(TdlgSelectDocument);
end.
