unit xRepDSF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, DsgnIntF, DB, Dialogs,
  xBasics, xRepDSLF, gsMultilingualSupport;

type
  TDataSourcesForm = class(TForm)
    Panel1: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    GroupBox1: TGroupBox;
    List: TListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FormDesigner: IFormDesigner;
    SList: TxValueList;
  end;

var
  DataSourcesForm: TDataSourcesForm;

implementation

{$R *.DFM}

procedure TDataSourcesForm.BitBtn1Click(Sender: TObject);
var
  Form: TDataSourcesListForm;
  i: Integer;
begin
  if List.ItemIndex = -1 then exit;
  Form := TDataSourcesListForm.Create(Application);
  try
    Form.List.Items.Clear;
    for i := 0 to FormDesigner.Form.ComponentCount - 1 do
     if FormDesigner.Form.Components[i] is TDataSource then
       Form.List.Items.Add(FormDesigner.Form.Components[i].Name);
    if Form.List.Items.IndexOf(SList.Values[List.ItemIndex]) <> -1 then
      Form.List.ItemIndex :=
        Form.List.Items.IndexOf(SList.Values[List.ItemIndex]);

    Form.UpdateEdit;

    if Form.ShowModal = mrOk then
     begin
       ShowMessage(Form.DataSourceEdit.Text);

       SList.Values[List.ItemIndex] := Form.DataSourceEdit.Text;

       List.Items.Assign(SList);
       List.ItemIndex := 0;
     end;
  finally
    Form.Free;
  end;
end;

procedure TDataSourcesForm.BitBtn2Click(Sender: TObject);
var
  LastIndex: Integer;
begin
  LastIndex := List.ItemIndex;
  SList.Values[List.ItemIndex] := '';
  List.Items.Assign(SList);
  List.ItemIndex := LastIndex;
end;

end.
