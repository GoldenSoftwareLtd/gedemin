// ShlTanya, 24.02.2019

unit dlg_gsResizer_ObjectInspectorFind_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  Tdlg_gsResizer_ObjectInspectorFind = class(TForm)
    gbResult: TGroupBox;
    lbResult: TListBox;
    alFind: TActionList;
    actFind: TAction;
    actGoTo: TAction;
    actCancel: TAction;
    btnGoTo: TButton;
    btnCancel: TButton;
    gbFind: TGroupBox;
    lblName: TLabel;
    edtText: TEdit;
    btnFind: TButton;
    procedure actFindUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actGoToExecute(Sender: TObject);
    procedure actGoToUpdate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtTextKeyPress(Sender: TObject; var Key: Char);
    procedure lbResultDblClick(Sender: TObject);
    procedure lbResultKeyPress(Sender: TObject; var Key: Char);
  private
    FNamesList: TStrings;
    FSelectedIndex: integer;
  public
    function FindObject(ANames: TStrings): integer;
  end;

var
  dlg_gsResizer_ObjectInspectorFind: Tdlg_gsResizer_ObjectInspectorFind;

implementation

{$R *.DFM}

procedure Tdlg_gsResizer_ObjectInspectorFind.FormCreate(Sender: TObject);
begin
  FNamesList:= TStringList.Create;
  FSelectedIndex:= -1;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FNamesList);
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.FormShow(Sender: TObject);
begin
  edtText.SetFocus;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.actCancelExecute(
  Sender: TObject);
begin
  modalResult:= mrOk;
end;

function Tdlg_gsResizer_ObjectInspectorFind.FindObject(
  ANames: TStrings): integer;
begin
  Result:= -1;
  FNamesList.Assign(ANames);
  if ShowModal = mrOk then begin
    Result:= FSelectedIndex;
  end;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.actGoToExecute(Sender: TObject);
begin
  FSelectedIndex:= integer(lbResult.Items.Objects[lbResult.ItemIndex]);
  ModalResult:= mrOk;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.actGoToUpdate(Sender: TObject);
begin
  actGoTo.Enabled:= lbResult.ItemIndex > -1;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.actFindExecute(Sender: TObject);
var
  i: integer;
begin
  lbResult.Items.Clear;
  for i:= 0 to FNamesList.Count - 1 do begin
    if Pos(AnsiUpperCase(Trim(edtText.Text)), AnsiUpperCase(FNamesList[i])) > 0 then
      lbResult.Items.AddObject(FNamesList[i], pointer(i));
  end;
  lbResult.Enabled:= lbResult.Items.Count > 0;
  if lbResult.Items.Count = 0 then begin
    lbResult.Items.Add('Ничего не найдено');
  end
  else if lbResult.Items.Count = 1 then begin
    FSelectedIndex:= integer(lbResult.Items.Objects[0]);
//    ModalResult:= mrOk;
  end
  else
    lbResult.ItemIndex:= 0;
  if lbResult.Enabled then
    lbResult.SetFocus
  else
    edtText.SetFocus;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.actFindUpdate(Sender: TObject);
begin
  actFind.Enabled:= Trim(edtText.Text) <> '';
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.lbResultDblClick(
  Sender: TObject);
begin
  actGoTo.Execute;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.edtTextKeyPress(
  Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    actFind.Execute
  else if Ord(Key) = VK_ESCAPE then
    actCancel.Execute;
end;

procedure Tdlg_gsResizer_ObjectInspectorFind.lbResultKeyPress(
  Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    actGoTo.Execute
  else if Ord(Key) = VK_ESCAPE then
    actCancel.Execute;
end;

end.
