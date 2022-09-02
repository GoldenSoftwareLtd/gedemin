// andreik, 15.01.2019

unit gdc_frmGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVGR_unit, Db, IBCustomDataSet, gdcBase, gdcTree, gdcContacts,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls, IBUpdateSQL,
  IBDatabase;

type
  Tgdc_frmGroup = class(Tgdc_frmMDVGr)
    gdcGroup: TgdcGroup;
    gdcBaseContact: TgdcBaseContact;
    procedure FormCreate(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);
    procedure actDetailDeleteExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmGroup: Tgdc_frmGroup;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcBaseInterface, IBSQL, gdc_frmMDVTree_unit;

procedure Tgdc_frmGroup.FormCreate(Sender: TObject);
begin
  gdcObject := gdcGroup;
  gdcDetailObject := gdcBaseContact;
  inherited;
end;

procedure Tgdc_frmGroup.actDetailNewExecute(Sender: TObject);
var
  id, oldId: TID;
  i: integer;
  q: TIBSQL;
  Tr: TIBTransaction;
  F: TForm;
begin
  case
    MessageDlg(
      'Добавить уже существующую организацию' + #10#13 + 'или создать новую запись ?'
      + #10#13 + #10#13
      + 'Да - Добавить уже существующую организацию' + #10#13
      + 'Нет - Создать новую запись',
      mtConfirmation,
      mbYesNoCancel,
      0
    ) of
    mrYes : begin
      F := TgdcBaseContact.CreateViewForm(Application, '', '', True);
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      Tr.DefaultDatabase := gdcBaseManager.Database;
      q.Transaction := Tr;
      try
        if Assigned(F) then
        begin
          MessageBox(0,
            'Для выбора объектов выделите их и закройте окно.'#13#10 +
            '',
            'Выбор объекта',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

          F.ShowModal;

          if MessageBox(0,
            'Вы подтверждаете свой выбор?',
            'Внимание',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
          begin
            if (F is Tgdc_frmMDVTree) and ((F as Tgdc_frmMDVTree).gdcDetailObject <> nil) then
            begin
              if ((F as Tgdc_frmMDVTree).gdcDetailObject.ID > 0) then
              begin
                Tr.StartTransaction;
                for i:=0 to (F as Tgdc_frmMDVTree).ibgrDetail.SelectedRows.Count-1 do begin

                  id := (F as Tgdc_frmMDVTree).gdcDetailObject.GetIDForBookmark((F as Tgdc_frmMDVTree).ibgrDetail.SelectedRows[i]);
                  q.SQL.Text := 'UPDATE OR INSERT INTO gd_contactlist (groupkey, contactkey, reserved) ' +
                    'VALUES(:groupkey, :contactkey, null)';
                  SetTID(q.ParamByName('groupkey'), gdcObject.ID);
                  SetTID(q.ParamByName('contactkey'), id);
                  q.ExecQuery;
                end;
                Tr.Commit;
              end;
            end;
          end;
        end;
      finally
        F.Free;
        q.Free;
        Tr.Free;
      end;
    end;
    mrNo : begin
      if not gdcDetailObject.IsEmpty then
        OldID := gdcDetailObject.ID
      else
        OldID := -1;

      inherited;

      id := gdcDetailObject.ID;
      if (id = -1) or (id = oldId) then Exit;
      Tr := TIBTransaction.Create(nil);
      q := TIBSQL.Create(nil);
      try
        Tr.DefaultDatabase := gdcBaseManager.Database;
        q.Transaction := Tr;
        Tr.StartTransaction;
        q.SQL.Text := 'UPDATE OR INSERT INTO gd_contactlist (groupkey, contactkey, reserved) ' +
          'VALUES(:groupkey, :contactkey, null)';
        SetTID(q.ParamByName('groupkey'), gdcObject.ID);
        SetTID(q.ParamByName('contactkey'), id);
        q.ExecQuery;
        Tr.Commit;
      finally
        q.Free;
        Tr.Free;
      end;
    end;
  else
    Exit;
  end;
  gdcDetailObject.CloseOpen;
end;


procedure Tgdc_frmGroup.actDetailDeleteExecute(Sender: TObject);
var
  i: integer;
  msg: string;
  idList: string;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if (ibgrDetail.SelectedRows.Count > 1) then
    msg := Format('Выбрано записей:%d'#10#13+
      'Удалить ссылки на выбранные записи из группы "%s"?'#10#13#10#13+
      'Сами записи удалены не будут' , [ibgrDetail.SelectedRows.Count, gdcObject.ObjectName])
  else
    msg:= Format('Удалить ссылку на запись "%s" из группы "%s"?'#10#13#10#13+
      'Сама запись удалена не будет' , [gdcDetailObject.ObjectName, gdcObject.ObjectName]);
  if (MessageBox(self.Handle,
     PChar(msg),
     'Внимание!',
     MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_DEFBUTTON2) <> IDYES)
  then exit;

  idList := '';
  for i:=0 to ibgrDetail.SelectedRows.Count-1 do begin
    idList := idList + TID2S(gdcDetailObject.GetIDForBookmark(ibgrDetail.SelectedRows[i])) + ', ';
  end;
  idList := Copy(idList, 0, Length(idList) - 2);
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  Tr.DefaultDatabase := gdcBaseManager.Database;
  q.Transaction := Tr;
  try
    Tr.StartTransaction;
    q.SQL.Text := 'DELETE FROM GD_CONTACTLIST ' +
      'where groupkey = :groupkey and contactkey in (' + idList + ')';
    SetTID(q.ParamByName('groupkey'), gdcObject.ID);
    q.ExecQuery;
    Tr.Commit;
  finally
    q.Free;
    Tr.Free;
  end;
  gdcDetailObject.CloseOpen;
end;

procedure Tgdc_frmGroup.actDeleteExecute(Sender: TObject);
var
   i: integer;
   msg: string;
begin
  if (ibgrMain.SelectedRows.Count > 1) then
    msg := Format('Выбрано записей:%d'#10#13+
      'Удалить выбранные записи ?', [ibgrMain.SelectedRows.Count])
  else
    msg:= Format('Удалить запись "%s" ?', [gdcObject.ObjectName]);
  if (MessageBox(self.Handle,
     PChar(msg),
     'Внимание!',
     MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_DEFBUTTON2) <> IDYES)
  then exit;

  for i:=0 to ibgrMain.SelectedRows.Count-1 do begin
    gdcObject.GotoBookmark(TBookmark(ibgrMain.SelectedRows[i]));
    gdcObject.Delete;
  end;
end;

initialization
  RegisterFRMClass(Tgdc_frmGroup);

finalization
  UnRegisterFRMClass(Tgdc_frmGroup);
end.
