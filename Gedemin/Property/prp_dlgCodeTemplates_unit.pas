// ShlTanya, 25.02.2019

unit prp_dlgCodeTemplates_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBClient, Grids, DBGrids, gsDBGrid, ActnList, ExtCtrls, StdCtrls,
  DBCtrls, Storages, gsStorage, prp_InputNameDescription_unit, gd_common_functions;

type
  Tprp_dlgCodeTemplates = class(TForm)
    dbgrMain: TgsDBGrid;
    dsMain: TDataSource;
    cdsMain: TClientDataSet;
    dbmemCode: TDBMemo;
    Label1: TLabel;
    Label2: TLabel;
    btnAdd: TButton;
    btnDelete: TButton;
    btnEdit: TButton;
    btnCancel: TButton;
    btnOk: TButton;
    alMain: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    actEdit: TAction;
    actOk: TAction;
    btnLoadFromFile: TButton;
    btnSaveToFile: TButton;
    actLoadFromFile: TAction;
    actSaveToFile: TAction;
    od: TOpenDialog;
    sd: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure cdsMainBeforePost(DataSet: TDataSet);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
  private
    procedure SaveUpdates;
    procedure EditNameDesc(ANew: boolean);
  public
    procedure CheckNewTemplate(Sender: TObject; var CanClose: Boolean);
    function CheckTemplateExists(AName: string; const AExclRecNo: integer = -1): boolean;
  end;

var
  prp_dlgCodeTemplates: Tprp_dlgCodeTemplates;

implementation

{$R *.DFM}

procedure Tprp_dlgCodeTemplates.FormCreate(Sender: TObject);
var
  SF: TgsStorageFolder;
  i: integer;
begin
  cdsMain.CreateDataSet;
  cdsMain.DisableControls;
  cdsMain.Fields[2].Visible:= False;
  dbmemCode.DataField:= 'value';
  if Assigned(UserStorage) then
  begin
    SF := UserStorage.OpenFolder('Options\CodeTemplates', True, False);
    try
      for i := 0 to SF.FoldersCount - 1 do begin
        cdsMain.Append;
        cdsMain.FieldByName('name').AsString:= SF.Folders[i].Name;
        cdsMain.FieldByName('desc').AsString:= SF.Folders[i].ValueByName('Description').AsString;
        cdsMain.FieldByName('value').AsString:= SF.Folders[i].ValueByName('Value').AsString;
        cdsMain.Post;
      end;
    finally
      UserStorage.CloseFolder(SF, False);
    end;
    cdsMain.EnableControls;
    cdsMain.First;
  end;
end;

procedure Tprp_dlgCodeTemplates.actAddExecute(Sender: TObject);
begin
  EditNameDesc(True);
end;

procedure Tprp_dlgCodeTemplates.actDeleteExecute(Sender: TObject);
begin
  cdsMain.Delete;
end;

procedure Tprp_dlgCodeTemplates.actEditExecute(Sender: TObject);
begin
  EditNameDesc(False);
end;

procedure Tprp_dlgCodeTemplates.actOkExecute(Sender: TObject);
begin
  if (cdsMain.State in [dsInsert, dsEdit]) then
    cdsMain.Post;
  SaveUpdates;
  ModalResult:= mrOk;
end;

procedure Tprp_dlgCodeTemplates.SaveUpdates;
var
  SF, SFTempl: TgsStorageFolder;
  sName: String;
  i: Integer;
begin
  if Assigned(UserStorage) then
  begin
    cdsMain.DisableControls;
    try

      SF:= UserStorage.OpenFolder('Options\CodeTemplates', True, True);
      try
        for i:= SF.FoldersCount - 1 downto 0 do
        begin
          if not cdsMain.Locate('name', SF.Folders[i].Name, []) then
            SF.DeleteFolder(SF.Folders[i].Name);
        end;

        cdsMain.First;
        while not cdsMain.Eof do
        begin
          sName:= cdsMain.FieldByName('name').AsString;
          if SF.FolderExists(sName) then begin
            SFTempl:= SF.FolderByName(sName);
          end
          else begin
            SFTempl:= SF.CreateFolder(sName);
          end;
          SFTempl.WriteString('Description', cdsMain.FieldByName('desc').AsString);
          SFTempl.WriteString('Value', cdsMain.FieldByName('value').AsString);

          cdsMain.Next;
        end;
      finally
        UserStorage.CloseFolder(SF, True);
      end;

    finally
      cdsMain.EnableControls;
    end;
  end;
end;

procedure Tprp_dlgCodeTemplates.EditNameDesc(ANew: boolean);
var
  frm: TfrmNameDescription;
begin
  frm:= TfrmNameDescription.Create(self);
  try
    if ANew then
      frm.Caption:= 'Добавление шаблона'
    else begin
      frm.Caption:= 'Изменение шаблона';
      frm.InputName:= cdsMain.FieldByName('name').AsString;
      frm.InputDescription:= cdsMain.FieldByName('desc').AsString;
    end;
    frm.OnCloseQuery:= CheckNewTemplate;
    frm.IsNew:= ANew;
    frm.ShowModal;
    if frm.ModalResult = mrOk then begin
      if ANew then
        cdsMain.Insert
      else
        cdsMain.Edit;
      cdsMain.FieldByName('name').AsString:= frm.InputName;
      cdsMain.FieldByName('desc').AsString:= frm.InputDescription;
      cdsMain.Post;
    end;
  finally
    frm.Free;
  end;
end;

function Tprp_dlgCodeTemplates.CheckTemplateExists(AName: string; const AExclRecNo: integer): boolean;
var
  bm: TBookmarkStr;
begin
  bm:= cdsMain.Bookmark;
  cdsMain.DisableControls;
  try
    Result:= cdsMain.Locate('name', AName, []);
    if Result then
      Result:= cdsMain.RecNo <> AExclRecNo;
    cdsMain.Bookmark:= bm;
  finally
    cdsMain.EnableControls;
  end;
end;

procedure Tprp_dlgCodeTemplates.CheckNewTemplate(Sender: TObject;
  var CanClose: Boolean);
begin
  if TfrmNameDescription(Sender).ModalResult = mrCancel then begin
    CanClose:= True;
    Exit;
  end;
  if Length(TfrmNameDescription(Sender).InputName) < 2 then begin
    MessageDlg('Длина имени не должна быть меньше 2-х символов.', mtError, [mbCancel], 0);
    CanClose:= False;
    Exit;
  end;
  if TfrmNameDescription(Sender).IsNew then
    CanClose:= not CheckTemplateExists(TfrmNameDescription(Sender).InputName)
  else
    CanClose:= not CheckTemplateExists(TfrmNameDescription(Sender).InputName, cdsMain.RecNo);
  if not CanClose then
    MessageDlg(Format('Шаблон с именем %s существует.', [TfrmNameDescription(Sender).InputName]), mtError, [mbCancel], 0)
end;

procedure Tprp_dlgCodeTemplates.cdsMainBeforePost(DataSet: TDataSet);
var
  s: string;
begin
  if not (Pos('|', cdsMain.FieldByName('value').AsString) > 0) and (dbmemCode.SelStart > 0) then begin
    if not (cdsMain.State in dsEditModes) then
      cdsMain.Edit;
    s:= cdsMain.FieldByName('value').AsString;
    Insert('|', s, dbmemCode.SelStart + 1);
    cdsMain.FieldByName('value').AsString:= s;
  end;
end;

procedure Tprp_dlgCodeTemplates.actLoadFromFileExecute(Sender: TObject);
var
  ms: TMemoryStream;
  s: string;
begin
  if OD.Execute then begin
    ms:= TMemoryStream.Create;
    try
      ms.LoadFromFile(OD.FileName);
      while ms.Position < ms.Size do begin
        s:= ReadStringFromStream(ms);
        if CheckTemplateExists(s) then begin
          cdsMain.Locate('name', s, []);
          cdsMain.Edit;
        end
        else begin
          cdsMain.Append;
          cdsMain.FieldByName('name').AsString:= s;
        end;
        cdsMain.FieldByName('desc').AsString:= ReadStringFromStream(ms);
        cdsMain.FieldByName('value').AsString:= ReadStringFromStream(ms);
        cdsMain.Post;
      end;
    finally
      ms.Free;
    end;
  end;
end;

procedure Tprp_dlgCodeTemplates.actSaveToFileExecute(Sender: TObject);
var
  ms: TMemoryStream;
  bm: TBookmarkStr;
begin
  if SD.Execute then begin
    ms:= TMemoryStream.Create;
    try
      bm:= cdsMain.Bookmark;
      cdsMain.DisableControls;
      try
        cdsMain.First;
        while not cdsMain.Eof do begin
          SaveStringToStream(cdsMain.FieldByName('name').AsString, ms);
          SaveStringToStream(cdsMain.FieldByName('desc').AsString, ms);
          SaveStringToStream(cdsMain.FieldByName('value').AsString, ms);
          cdsMain.Next;
        end;
        ms.SaveToFile(SD.FileName);
        cdsMain.Bookmark:= bm;
      finally
        cdsMain.EnableControls;
      end;  
    finally
      ms.Free;
    end;
  end;
end;

procedure Tprp_dlgCodeTemplates.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := cdsMain.RecordCount > 0;
end;

procedure Tprp_dlgCodeTemplates.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled := cdsMain.RecordCount > 0;
end;

end.
