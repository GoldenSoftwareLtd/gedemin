unit gdv_dlgSelectDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBCustomDataSet, gdcBase, gdcTree, gdcClasses,
  Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, ActnList,
  IBSQL, gdcBaseInterface, TB2Item, TB2Dock, TB2Toolbar, gdc_createable_form,
  gsStorage, Storages, gd_classList;

type
  TdlgSelectDocument = class(TgdcCreateableForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    tvDocumentType: TgsDBTreeView;
    Bevel1: TBevel;
    gdcDocumentType: TgdcBaseDocumentType;
    dsDocumentType: TDataSource;
    dsDocument: TDataSource;
    ActionList: TActionList;
    actOk: TAction;
    actcancel: TAction;
    acthelp: TAction;
    pLine: TPanel;
    Panel5: TPanel;
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
    procedure actOkExecute(Sender: TObject);
    procedure actcancelExecute(Sender: TObject);
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
  private
    FDocument: TgdcDocument;
    FDocumentLine: TgdcDocument;
    { Private declarations }

    procedure ShowLinePanel(V: Boolean);
    function GetSelectedId: Integer;
    procedure LoadGridSettings(DataSet: TgdcBase; Grid: TgsIbGrid);
  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;

    property SelectedId: Integer read GetSelectedId;
  end;

var
  dlgSelectDocument: TdlgSelectDocument;

implementation
uses gsStorage_CompPath;
{$R *.DFM}

procedure TdlgSelectDocument.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TdlgSelectDocument.actcancelExecute(Sender: TObject);
begin
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
  if Visible  then
  begin
    dsDocument.DataSet := nil;
    dsDocumentLine.DataSet := nil;
    gDocument.Columns.Clear;
    gDocumentLine.Columns.Clear;
    F := TgdcDocument.GetDocumentClass(DataSet.FieldByName('id').AsInteger, dcpHeader);
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
      FDocument.Open;
      dsDocument.DataSet := FDocument;
      LoadGridSettings(FDocument, gDocument);
      gDocument.ResizeColumns;

      F := TgdcDocument.GetDocumentClass(DataSet.FieldByName('id').AsInteger, dcpLine);
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
      FDocument.ExtraConditions.Add(' z.id = -1');
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

function TdlgSelectDocument.GetSelectedId: Integer;
begin
  Result := -1;
  if gDocument.CheckBox.CheckList.Count > 0 then
  begin
    Result := StrToInt(gDocument.CheckBox.CheckList[0]);
  end else
  if gDocumentLine.CheckBox.CheckList.Count > 0 then
  begin
    Result := StrToInt(gDocumentLine.CheckBox.CheckList[0]);
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

procedure TdlgSelectDocument.LoadGridSettings(DataSet: TgdcBase; Grid: TgsIbGrid);

  procedure Internal(F: TgsStorageFolder);
  var
    V: TgsStorageValue;
    S: TStream;
  begin
    if F <> nil then
    begin
      V := F.ValueByName('GrSet');
      if V <> nil then
      begin
        if V is TgsStringValue then
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
        end else
          F.DeleteValue('GrSet');
      end;
    end;
  end;

var
  F: TgsStorageFolder;
begin
  if UserStorage <> nil then
  begin
    F := UserStorage.OpenFolder('GDC\' + DataSet.ClassName + DataSet.SubType,
      False, False);
    try
      Internal(F);
    finally
      UserStorage.CloseFolder(F, False);
    end
  end;
end;

procedure TdlgSelectDocument.SaveSettings;
var
  MS: TMemoryStream;
begin
  inherited;
  if UserStorage <> nil then
  begin
    MS := TMemoryStream.Create;
    try
      tvDocumentType.SaveToStream(MS);
      UserStorage.WriteStream(BuildComponentPath(tvDocumentType), 'TVState', MS);
    finally
      MS.Free;
    end;
  end;
end;

procedure TdlgSelectDocument.LoadSettings;
var
  MS: TMemoryStream;
begin
  inherited;
  if UserStorage <> nil then
  begin
    MS := TMemoryStream.Create;
    try
      if UserStorage.ReadStream(BuildComponentPath(tvDocumentType), 'TVState', MS) then
        tvDocumentType.LoadFromStream(MS);
    finally
      MS.Free;
    end;
  end;
end;

initialization
  RegisterFrmClass(TdlgSelectDocument);

finalization
  UnRegisterFrmClass(TdlgSelectDocument);
end.
