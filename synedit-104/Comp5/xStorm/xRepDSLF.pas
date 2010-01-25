unit xRepDSLF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, SysUtils;

type
  TDataSourcesListForm = class(TForm)
    GroupBox1: TGroupBox;
    List: TListBox;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    Label1: TLabel;
    DataSourceEdit: TEdit;
    procedure FormShow(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure DataSourceEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    UseList: Boolean;
    procedure UpdateEdit;
  end;

var
  DataSourcesListForm: TDataSourcesListForm;

implementation

{$R *.DFM}

procedure TDataSourcesListForm.FormShow(Sender: TObject);
begin
  List.ItemIndex := 0;
  UseList := true;
end;

procedure TDataSourcesListForm.UpdateEdit;
begin
  if UseList and (List.ItemIndex <> -1) then
   begin
     DataSourceEdit.Text := '';
     DataSourceEdit.Text := List.Items[List.ItemIndex];
   end;
end;

procedure TDataSourcesListForm.ListClick(Sender: TObject);
begin
  UseList := true;
  UpdateEdit;
end;

procedure TDataSourcesListForm.OKBtnClick(Sender: TObject);
begin
  {$IFDEF DEBUG}
  ShowMessage(DataSourceEdit.Text + '   ' + IntToStr(List.ItemIndex));
  {$ENDIF}

  UpdateEdit;
  
  {$IFDEF DEBUG}
  ShowMessage(DataSourceEdit.Text);
  {$ENDIF}
end;

procedure TDataSourcesListForm.DataSourceEditKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  UseList := false;
end;

end.

