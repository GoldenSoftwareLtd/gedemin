unit rpl_ViewRPLFile_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, xpDBGrid, rplDBGrid, DB, DBClient, StdCtrls,
  XPComboBox, ActnList, XPButton, XPPanel, ZLib, ComCtrls, Buttons,
  ExtCtrls, XPCheckBox, XPGroupBox, Contnrs, XPEdit, rpl_BaseTypes_unit, IBCustomDataSet;

type
  TViewRPLFileState = (vfsOpened, vfsNone, vfsBusy, vfsReady);

  TfrmViewRPLFile = class(TForm)
    alMain: TActionList;
    actClose: TAction;
    actFilter: TAction;
    actSelectFile: TAction;
    cdsEvent: TClientDataSet;
    dsEvent: TDataSource;
    actViewRPL: TAction;
    Panel1: TPanel;
    cmbFileName: TXPComboBox;
    btnOpen: TXPButton;
    btnClose: TXPButton;
    pnlStatus: TPanel;
    lLog: TLabel;
    pbProgress: TProgressBar;
    XPButton1: TXPButton;
    cdsData: TClientDataSet;
    dsData: TDataSource;
    ibdsDBData: TIBDataSet;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    dbgrEvent: TrplDBGrid;
    gbxData: TXPGroupBox;
    dbgrData: TrplDBGrid;
    XPGroupBox1: TXPGroupBox;
    cmbWhere: TXPComboBox;
    XPButton2: TXPButton;
    chkInsert: TXPCheckBox;
    chkUpdate: TXPCheckBox;
    chkDelete: TXPCheckBox;
    pnlDBData: TPanel;
    spl: TSplitter;
    dbgrDBData: TrplDBGrid;
    dsDBData: TDataSource;
    chkData: TXPCheckBox;
    XPGroupBox2: TXPGroupBox;
    cmbWhereDB: TXPComboBox;
    XPButton3: TXPButton;
    actFilterDB: TAction;
    chkEmpty: TXPCheckBox;
    actLoadEList: TAction;
    actFindNext: TAction;
    actSaveEList: TAction;
    lblIndex: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actSelectFileExecute(Sender: TObject);
    procedure actViewRPLExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure dbgrEventDblClick(Sender: TObject);
    procedure cdsEventAfterScroll(DataSet: TDataSet);
    procedure chkDataClick(Sender: TObject);
    procedure dbgrDBDataDblClick(Sender: TObject);
    procedure actFilterDBExecute(Sender: TObject);
    procedure actFilterUpdate(Sender: TObject);
  private
    FState: TViewRPLFileState;
    procedure ResizeColumns;
    procedure SimpleRead(Stream: TStream; ACount: integer);
    function  CreateFilter: string;
    function  GetCortege(AID: integer): TrpCortege;
    function CheckOpeningFile(AFileName: string): boolean;
  public
    { Public declarations }
  end;

const
  FILE_NAME_HISTORY = 'd:\Bases\IBReplicator\FileNameHist.txt';
  WHERE_HISTORY_FILE_NAME = 'd:\Bases\IBReplicator\WhereHist.txt';
  WHERE_DB_HISTORY_FILE_NAME = 'd:\Bases\IBReplicator\WhereDBHist.txt';

var
  frmViewRPLFile: TfrmViewRPLFile;

implementation

uses
  rpl_dmImages_unit, rpl_ResourceString_unit,
  main_frmIBReplicator_unit, rpl_const;

{$R *.dfm}

procedure TfrmViewRPLFile.FormCreate(Sender: TObject);
begin
  FState:= vfsNone;
  cdsEvent.CreateDataSet;
  dbgrEvent.Columns[6].Visible:= False;
  if SysUtils.FileExists(FILE_NAME_HISTORY) then
    cmbFileName.Items.LoadFromFile(FILE_NAME_HISTORY)
  else
    cmbFileName.Items.SaveToFile(FILE_NAME_HISTORY);
  if SysUtils.FileExists(WHERE_HISTORY_FILE_NAME) then
    cmbWhere.Items.LoadFromFile(WHERE_HISTORY_FILE_NAME)
  else
    cmbWhere.Items.SaveToFile(WHERE_HISTORY_FILE_NAME);
  if SysUtils.FileExists(WHERE_DB_HISTORY_FILE_NAME) then
    cmbWhereDB.Items.LoadFromFile(WHERE_DB_HISTORY_FILE_NAME)
  else
    cmbWhereDB.Items.SaveToFile(WHERE_DB_HISTORY_FILE_NAME);
  WindowState:= wsMaximized;
  if cmbFileName.Items.Count > 0 then
    cmbFileName.ItemIndex:= 0;
end;

procedure TfrmViewRPLFile.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  cmbFileName.Items.SaveToFile(FILE_NAME_HISTORY);
  cmbWhere.Items.SaveToFile(WHERE_HISTORY_FILE_NAME);
  cmbWhereDB.Items.SaveToFile(WHERE_DB_HISTORY_FILE_NAME);
end;

procedure TfrmViewRPLFile.FormResize(Sender: TObject);
begin
  ResizeColumns;
end;

procedure TfrmViewRPLFile.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmViewRPLFile.actSelectFileExecute(Sender: TObject);
var
  O: TOpenDialog;
begin
  O := TOpenDialog.Create(nil);
  try
    O.Filter := 'Файлы реплики|*.rpl|All files|*.*';
    O.FilterIndex := 0;
    O.Options := [ofOverwritePrompt, ofHideReadOnly, ofNoNetworkButton,
      ofEnableSizing];
    O.InitialDir:= mainIBReplicator.GetLoadPath;
    if O.Execute and CheckOpeningFile(O.FileName) then begin
      cmbFileName.Text:= O.FileName;
      if cmbFileName.Items.IndexOf(O.FileName) = -1 then
        cmbFileName.Items.Add(O.FileName);
      FState:= vfsReady;
    end;
  finally
    O.Free;
  end;
end;

function TfrmViewRPLFile.CheckOpeningFile(AFileName: string): boolean;
var
  FileHeader: TrplStreamHeader;
  F, ZF: TStream;
begin
  Result:= False;
  F := TFileStream.Create(AFileName, fmOpenRead);
  ZF:= TDecompressionStream.Create(F);
  try
    if SysUtils.FileExists(AFileName) then begin
      FileHeader := TrplStreamHeader.Create;
      try
        try
          try
            FileHeader.LoadFromStream(ZF);
          except
            raise Exception.Create(Format('Ошибка при чтении файла %s', [AFileName]));
          end;

          if {not ReplDataBase.CanRepl(FileHeader.DBKey) or} (FileHeader.Schema <> ReplDataBase.DataBaseInfo.Schema) then
            raise Exception.Create('Не тот файл.')
          else begin
            Result:= True;
          end;
        except
          on E: Exception do begin
          end;
        end;
      finally
        FileHeader.Free;
      end;
    end;
  finally
    ZF.Free;
    F.Free;
  end;
end;

procedure TfrmViewRPLFile.actViewRPLExecute(Sender: TObject);
var
  FileHeader: TrplStreamHeader;
  F, ZF, ZD: TStream;
  iCount, i, iTmp: integer;
  Relation: TrpRelation;
  rpEvent: TrpEvent;
  rpCortege: TrpCortege;
begin
  if not CheckOpeningFile(cmbFileName.Text) then Exit;
  FState:= vfsBusy;
  pnlStatus.Visible:= True;
  F := TFileStream.Create(cmbFileName.Text, fmOpenRead);
  ZF:= TDecompressionStream.Create(F);
  ZD := TMemoryStream.Create;
  FileHeader := TrplStreamHeader.Create;
  rpEvent:= TrpEvent.Create;
  rpCortege:= TrpCortege.Create;
  try
{    try
      while true do
        ZD.CopyFrom(ZF, 1);
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
    ZD.Position:= 0;
    TMemoryStream(ZD).SaveToFile('1.tmp');
    ZD.Position:= 0;
    FileHeader.LoadFromStream(ZD);
    ZD.Read(iCount, SizeOf(iCount));}
    FileHeader.LoadFromStream(ZF);
    ZF.Read(iCount, SizeOf(iCount));
    pbProgress.Max:= iCount;
    cdsEvent.Close;
    cdsEvent.Open;
    try
      if not ReplDataBase.Transaction.InTransaction then
        ReplDataBase.Transaction.StartTransaction;
      ibdsDBData.Transaction:= ReplDataBase.Transaction;
      if ReplDataBase.DataBaseInfo.DBState = dbsMain then begin
        ReplDataBase.RUIDManager.RUIDConf.LoadFromField(FileHeader.DbKey);
        ReplDataBase.RUIDManager.RUIDConf.DeleteFromList(FileHeader.ReplKey);
      end
      else begin
//        ZD.ReadBuffer(iTmp, SizeOf(iTmp));
//       SimpleRead(ZD, iTmp * SizeOf(TRUIDConformity));
        ZF.ReadBuffer(iTmp, SizeOf(iTmp));
        SimpleRead(ZF, iTmp * SizeOf(TRUIDConformity));
      end;
      for i:= 1 to iCount do begin
        cdsEvent.Append;

//        rpEvent.LoadFromStream(ZD);
        rpEvent.LoadFromStream(ZF);
        if rpEvent.RelationKey = 517334387 then
          ShowMessage('');
        cdsEvent.FieldByName('fdID').AsInteger:= i - 1;
        cdsEvent.FieldByName('fdSeqNo').AsInteger:= rpEvent.Seqno;
        Relation := ReplDataBase.Relations[rpEvent.RelationKey];
        if Assigned(Relation) then
          cdsEvent.FieldByName('fdRelation').AsString:= Relation.RelationName
        else
          cdsEvent.FieldByName('fdRelation').AsString:= '';
        cdsEvent.FieldByName('fdType').AsString:= rpEvent.ReplType;
        cdsEvent.FieldByName('fdOldKey').AsString:= rpEvent.OldKey;
        cdsEvent.FieldByName('fdNewKey').AsString:= rpEvent.NewKey;
        cdsEvent.FieldByName('fdTime').AsDateTime:= rpEvent.ActionTime;
        cdsEvent.Post;
        rpCortege.RelationKey := rpEvent.RelationKey;
        case rpEvent.ReplType[1] of
          atInsert, atUpdate:begin
//              rpCortege.LoadFromStream(ZD);
              rpCortege.LoadFromStream(ZF);
            end;
        end;
        pbProgress.Position:= i;
      end;
      FState:= vfsOpened;
    finally
      ReplDataBase.Transaction.RollBack;
    end;
  finally
    rpEvent.Free;
    rpCortege.Free;
    ZF.Free;
    F.Free;
    ZD.Free;
    FileHeader.Free;
    pnlStatus.Visible:= False;
    ResizeColumns;
    if FState = vfsBusy then
      FState:= vfsReady
  end;
end;

procedure TfrmViewRPLFile.ResizeColumns;
begin
  if dbgrEvent.Columns.Count < 6 then Exit; 
  dbgrEvent.Columns[0].Width:= 200;
  dbgrEvent.Columns[1].Width:= 50;
  dbgrEvent.Columns[2].Width:= 20;
  dbgrEvent.Columns[3].Width:= 115;
  dbgrEvent.Columns[4].Width:= (dbgrEvent.Width - 425) div 2;
  dbgrEvent.Columns[5].Width:= (dbgrEvent.Width - 420) div 2;
{  memSelect.Width:= (gbxData.Width - 6) div 4 - 1;
  memInsert.Width:= (gbxData.Width - 6) div 4 - 1;
  memUpdate.Width:= (gbxData.Width - 6) div 4 - 1;
  memDelete.Width:= (gbxData.Width - 6) div 4 - 1;
  memInsert.Left:= memSelect.Left + memSelect.Width;
  memUpdate.Left:= memInsert.Left + memInsert.Width;
  memDelete.Left:= memUpdate.Left + memUpdate.Width;}
  chkData.Left:= Width - 205;
end;

procedure TfrmViewRPLFile.SimpleRead(Stream: TStream; ACount: integer);
var
  Buff: byte;
  i: integer;
begin
  for i:= 1 to ACount do
    Stream.ReadBuffer(Buff, 1);
end;

procedure TfrmViewRPLFile.actFilterExecute(Sender: TObject);
begin
  try
    cdsEvent.Filtered:= False;
    cdsEvent.Filter:= CreateFilter;
    if cdsEvent.Filter <> '' then
      cdsEvent.Filtered:= True;
    if (cmbWhere.Items.IndexOf(cmbWhere.Text) = -1) and (Trim(cmbWhere.Text) <> '')  then
      cmbWhere.Items.Add(cmbWhere.Text);
  except
  end;
end;

procedure TfrmViewRPLFile.actFilterDBExecute(Sender: TObject);
begin
  if Trim(cmbWhereDB.Text) = '' then Exit;
  try
    ibdsDBData.Close;
    ibdsDBData.SelectSQL.Text:= Format('SELECT * FROM %s', [cdsEvent.FieldByName('fdRelation').AsString]);
    ibdsDBData.SelectSQL.Text:= ibdsDBData.SelectSQL.Text + ' WHERE ' + cmbWhereDB.Text;
    ibdsDBData.Open;
    if (cmbWhereDB.Items.IndexOf(cmbWhereDB.Text) = -1) and (Trim(cmbWhereDB.Text) <> '')  then
      cmbWhereDB.Items.Add(cmbWhereDB.Text);
  except
  end;
end;

procedure TfrmViewRPLFile.dbgrEventDblClick(Sender: TObject);
var
  sVal: string;
begin
  case dbgrEvent.SelectedField.DataType of
    ftString: sVal:= dbgrEvent.SelectedField.FullName + ' LIKE ' + QuotedStr('%' + dbgrEvent.SelectedField.AsString + '%');
    ftInteger: sVal:= dbgrEvent.SelectedField.FullName + '=' + IntToStr(dbgrEvent.SelectedField.AsInteger);
  end;
  cmbWhere.Text:= sVal;
end;

function TfrmViewRPLFile.CreateFilter: string;
begin
  if (chkInsert.Checked or chkUpdate.Checked or chkDelete.Checked or chkEmpty.Checked) and
      not (chkInsert.Checked and chkUpdate.Checked and chkDelete.Checked and chkEmpty.Checked) then begin
    if chkInsert.Checked then
      Result:= 'fdType=' + QuotedStr(atInsert);
    if chkUpdate.Checked then begin
      if Result <> '' then
        Result:= Result + ' OR ';
      Result:= Result + 'fdType=' + QuotedStr(atUpdate);
    end;
    if chkDelete.Checked then begin
      if Result <> '' then
        Result:= Result + ' OR ';
      Result:= Result + 'fdType=' + QuotedStr(atDelete);
    end;
    if chkEmpty.Checked then begin
      if Result <> '' then
        Result:= Result + ' OR ';
      Result:= Result + 'fdType=' + QuotedStr(atEmpty);
    end;
  end;
  if Trim(cmbWhere.Text) <> '' then begin
    if Result <> '' then
      Result:= '(' + Result + ') AND ';
    Result:= Result + Trim(cmbWhere.Text);
  end;
end;

procedure TfrmViewRPLFile.cdsEventAfterScroll(DataSet: TDataSet);
var
  rpCortege: TrpCortege;
  i: integer;
begin
  if (FState <> vfsOpened) or not chkData.Checked or not (cdsEvent.FieldByName('fdRelation').AsString > '') then Exit;
  cdsData.Close;
  cdsData.FieldDefs.Clear;
  ibdsDBData.Close;
  ibdsDBData.SelectSQL.Text := Format('SELECT * FROM %s', [cdsEvent.FieldByName('fdRelation').AsString]);
  ibdsDBData.Open;
  for I := 0 to ibdsDBData.FieldCount - 1 do
    cdsData.FieldDefs.Add(ibdsDBData.Fields[I].FieldName, ibdsDBData.Fields[I].DataType, ibdsDBData.Fields[I].Size, False);

  rpCortege:= GetCortege(cdsEvent.FieldByName('fdID').AsInteger);
  if not Assigned(rpCortege) or (cdsEvent.FieldByName('fdType').AsString = atDelete) then Exit;

  cdsData.CreateDataset;
  cdsData.Open;
  cdsData.Append;
  rpCortege.SaveToDataSet(cdsData);
  cdsData.Post;
  if not ibdsDBData.Active then
    ibdsDBData.Open;
end;

function TfrmViewRPLFile.GetCortege(AID: integer): TrpCortege;
var
  FileHeader: TrplStreamHeader;
  F, ZF: TStream;
  iCount, i, iTmp: integer;
  rpEvent: TrpEvent;
begin
  FState:= vfsBusy;
  pnlStatus.Visible:= True;
  F := TFileStream.Create(cmbFileName.Text, fmOpenRead);
  ZF:= TDecompressionStream.Create(F);
  FileHeader := TrplStreamHeader.Create;
  rpEvent:= TrpEvent.Create;
  Result:= TrpCortege.Create;
  try
    FileHeader.LoadFromStream(ZF);
    ZF.Read(iCount, SizeOf(iCount));
    pbProgress.Max:= AID;
    try
      ZF.ReadBuffer(iTmp, SizeOf(iTmp));
      SimpleRead(ZF, iTmp * SizeOf(TRUIDConformity));
      for i:= 0 to AID do begin
        rpEvent.LoadFromStream(ZF);
        Result.RelationKey := rpEvent.RelationKey;
        case rpEvent.ReplType[1] of
          atInsert, atUpdate:begin
              Result.LoadFromStream(ZF);
            end;
        end;
        pbProgress.Position:= i;
      end;
      FState:= vfsOpened;
    finally
      ReplDataBase.Transaction.RollBack;
    end;
  finally
    rpEvent.Free;
    ZF.Free;
    F.Free;
    FileHeader.Free;
    pnlStatus.Visible:= False;
    if FState = vfsBusy then
      FState:= vfsReady
  end;
end;

procedure TfrmViewRPLFile.chkDataClick(Sender: TObject);
begin
  if chkData.Checked then
    cdsEventAfterScroll(ibdsDBData);
  gbxData.Visible:= chkData.Checked;
  pnlDBData.Visible:= chkData.Checked;
  spl.Visible:= chkData.Checked;
end;

procedure TfrmViewRPLFile.dbgrDBDataDblClick(Sender: TObject);
var
  sVal: string;
begin
  case dbgrDBData.SelectedField.DataType of
    ftString: sVal:= dbgrDBData.SelectedField.FullName + ' LIKE ' + QuotedStr('%' + dbgrDBData.SelectedField.AsString + '%');
    ftInteger: sVal:= dbgrDBData.SelectedField.FullName + '=' + IntToStr(dbgrDBData.SelectedField.AsInteger);
  end;
  cmbWhereDB.Text:= sVal;
end;

procedure TfrmViewRPLFile.actFilterUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= FState = vfsOpened;
end;

end.
