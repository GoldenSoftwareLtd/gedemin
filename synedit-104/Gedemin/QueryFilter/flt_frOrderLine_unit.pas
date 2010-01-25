unit flt_frOrderLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, DBCtrls, flt_sqlfilter_condition_type, IBDatabase,
  gd_AttrComboBox, Buttons, gsComboTreeBox;

const
  WM_CLOSEORDERLINE = 15000;

type
  TfrOrderLine = class(TFrame)
    pnlOrder: TPanel;
    Label1: TLabel;
    cbOrderType: TComboBox;
    Label2: TLabel;
    bbtnClose: TBitBtn;
    ctbFields: TComboTreeBox;
    procedure cbFieldsExit(Sender: TObject);
    procedure cbFieldsChange(Sender: TObject);
    procedure bbtnCloseClick(Sender: TObject);
  end;

implementation

{$R *.DFM}


procedure TfrOrderLine.cbFieldsExit(Sender: TObject);
begin
  if ctbFields.SelectedNode = nil then
  begin
    cbOrderType.ItemIndex := 0;
  end;
end;

// �������� �� ������ ����
procedure TfrOrderLine.cbFieldsChange(Sender: TObject);
begin
  if (ctbFields.SelectedNode <> nil) then
  begin
    // ������������� ������� ����������
    if TFilterOrderBy(ctbFields.SelectedNode.Data).IsAscending then
      cbOrderType.ItemIndex := 0
    else
      cbOrderType.ItemIndex := 1;
  end else
    cbOrderType.ItemIndex := -1;
end;

// ��������� ������� ������ �������
procedure TfrOrderLine.bbtnCloseClick(Sender: TObject);
begin
  // �������� ��������� ������������� ����
  PostMessage(Parent.Parent.Parent.Parent.Handle, WM_USER, WM_CLOSEORDERLINE, Integer(Self));
end;

end.
