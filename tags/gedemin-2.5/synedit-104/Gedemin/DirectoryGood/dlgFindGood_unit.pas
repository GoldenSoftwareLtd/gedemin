
 {++
   Project ADDRESSBOOK
   Copyright � 2000- by Golden Software

   ������

     dlgFind_unit

   ��������

     ���� ��� ������

   �����

.    Anton

   �������

     ver    date    who    what
     1.00 - 24.04.2000 - Anton - ������ ������

 --}

unit dlgFindGood_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, ComCtrls, ExtCtrls, StdCtrls,
  Menus, ActnList, gd_security, IBSQL, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBUpdateSQL, DirectoryGood, at_sql_setup, gd_createable_form;

type
  TdlgFindGood = class(TCreateableForm)
    Panel1: TPanel;
    Label1: TLabel;
    edName: TEdit;
    Button1: TButton;
    Button3: TButton;
    Panel2: TPanel;
    btnProperty: TButton;
    btnDelete: TButton;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ActionList1: TActionList;
    actDelete: TAction;
    actProperty: TAction;
    actFind: TAction;
    dbgGood: TgsIBGrid;
    dsGood: TDataSource;
    qryGood: TIBQuery;
    ibusGood: TIBUpdateSQL;
    IBTransaction: TIBTransaction;
    DirectGood: TboDirectGood;
    atSQLSetup: TatSQLSetup;
    procedure btnDeleteClick(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actPropertyUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);

  public
    procedure Find(Name: String); // ��������� ������

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  dlgFindGood: TdlgFindGood;

implementation

{$R *.DFM}

uses
  gsDesktopManager, Storages;

//������ ������
procedure TdlgFindGood.Find(Name: String);
begin
  qryGood.Close;
  if Name = '' then
    qryGood.SQL.Text := 'SELECT * FROM gd_good '
  else
    qryGood.SQL.Text := 'SELECT * FROM gd_good WHERE name CONTAINING ''' + Name +
      '''';

  edName.Text := Name;
  qryGood.Open;
  if not Visible then
    ShowModal;
end;

procedure TdlgFindGood.btnDeleteClick(Sender: TObject);
begin
  
end;

//������ ������
procedure TdlgFindGood.actFindExecute(Sender: TObject);
begin
  Find(edName.Text);
end;

procedure TdlgFindGood.actPropertyUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := qryGood.Active and
    (qryGood.RecordCount > 0);
end;

procedure TdlgFindGood.actDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := qryGood.Active and
    (qryGood.RecordCount > 0);
end;

procedure TdlgFindGood.actDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  if (qryGood.Active and (qryGood.RecordCount > 0)) and
     (MessageBox(Handle, PChar(Format('������� ����� %s?', [qryGood.FieldByName('name').AsString])),
     '��������', MB_YESNO or MB_ICONEXCLAMATION) = mrYes) then
    if dbgGood.SelectedRows.Count > 0 then
    begin
      for I := 0 to dbgGood.SelectedRows.Count - 1 do
        try
          qryGood.GotoBookmark(Pointer(dbgGood.SelectedRows.Items[I]));
          if (qryGood.FieldByName('afull').AsInteger and IBLogin.Ingroup) <> 0 then
            qryGood.Delete
          else
            ShowMessage(Format('��� ���� �� �������� %s', [qryGood.FieldByName('name').AsString]))
        except
          //gsDBDelete.isUse(qryGood.FieldByName('id').AsString);
        end;
    end
    else
    begin
      try
        if (qryGood.FieldByName('afull').AsInteger and IBLogin.Ingroup) <> 0 then
         qryGood.Delete
        else
          ShowMessage('��� ���� �� �������� ' + qryGood.FieldByName('name').AsString);
      except
//      gsDBDelete.isUse(qryGood.FieldByName('id').AsString);
      end;
    end;

  IBTransaction.CommitRetaining;
end;

procedure TdlgFindGood.actPropertyExecute(Sender: TObject);
begin
  if DirectGood.EditGood(qryGood.FieldByName('id').AsInteger) then
    qryGood.Refresh;
end;

procedure TdlgFindGood.LoadSettings;
begin
  inherited;
  UserStorage.SaveComponent(dbgGood, dbgGood.SaveToStream);
end;

procedure TdlgFindGood.SaveSettings;
begin
  inherited;
  UserStorage.LoadComponent(dbgGood, dbgGood.LoadFromStream);
end;

procedure TdlgFindGood.FormShow(Sender: TObject);
begin
  if not qryGood.Active then Find('');
end;

end.
