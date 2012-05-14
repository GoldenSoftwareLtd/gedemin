unit amc_MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, amc_Base, Menus, ComCtrls;

type
  TfrmAddMacroCall = class(TForm)
    gdSeachParams: TGroupBox;
    lblBaseClass: TLabel;
    edBaseClass: TEdit;
    pnlControlButtons: TPanel;
    btnSearchClass: TButton;
    btnAddMacroCall: TButton;
    lblPath: TLabel;
    edPath: TEdit;
    lblPar: TLabel;
    lblBegin: TLabel;
    edPar: TEdit;
    edBegin: TEdit;
    edEnd: TEdit;
    lblEnd: TLabel;
    pmClasses: TPopupMenu;
    DelFile: TMenuItem;
    PageControl1: TPageControl;
    tsHierarhy: TTabSheet;
    tsMethods: TTabSheet;
    lbClasses: TListBox;
    lbMethods: TListBox;
    btnAddMethod: TButton;
    btnDelMethod: TButton;
    edMethod: TEdit;
    btnSaveHierarchy: TButton;
    edHierarchyFile: TEdit;
    ppMethods: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    btnDelMacroCall: TButton;
    cbParam: TCheckBox;
    cbBegin: TCheckBox;
    cbEnd: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSearchClassClick(Sender: TObject);
    procedure edPathDblClick(Sender: TObject);
    procedure btnAddMacroCallClick(Sender: TObject);
    procedure DelFileClick(Sender: TObject);
    procedure lbClassesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnSaveHierarchyClick(Sender: TObject);
    procedure btnAddMethodClick(Sender: TObject);
    procedure btnDelMethodClick(Sender: TObject);
    procedure btnDelMacroCallClick(Sender: TObject);
  private
    amcObject: TamcObject;
  public
    { Public declarations }
  end;

var
  frmAddMacroCall: TfrmAddMacroCall;

implementation

uses
  FileCtrl, JclStrings;

{$R *.DFM}

procedure TfrmAddMacroCall.FormCreate(Sender: TObject);
begin
  amcObject := TamcObject.Create;
  amcObject.Methods := lbMethods.Items;
end;

procedure TfrmAddMacroCall.FormDestroy(Sender: TObject);
begin
  amcObject.Methods := nil;
  amcObject.Free;
end;

procedure TfrmAddMacroCall.btnSearchClassClick(Sender: TObject);
var
  i: Integer;
begin
  amcObject.BaseClass := edBaseClass.Text;
//  amcObject.Method := edMethod.Text;
  amcObject.SearchClassHierarchy(edPath.Text);
  lbClasses.Clear;
  for i := 0 to amcObject.ClassFileList.Count - 1 do
  begin
    lbClasses.Items.Add('*** ' + amcObject.ClassFileList[i] + ' ***');
    lbClasses.Items.AddStrings(amcObject.ClassFileList.ClassList[i]);
    lbClasses.Items.Add('');
  end;

end;

procedure TfrmAddMacroCall.edPathDblClick(Sender: TObject);
var
  SearchDir: String;
begin
  if SelectDirectory('Choose a search path...', '', SearchDir) then
    edPath.Text := SearchDir;
end;

procedure TfrmAddMacroCall.btnAddMacroCallClick(Sender: TObject);
begin
//  amcObject.Method := edMethod.Text;
  amcObject.ParamsMethod := edPar.Text;
  amcObject.BeginMethod := edBegin.Text;
  amcObject.EndMethod := edEnd.Text;
  amcObject.AddMacroCall(amcAdd);
end;

procedure TfrmAddMacroCall.DelFileClick(Sender: TObject);
var
  str: String;
  i, IndexInLB: Integer;
begin
  IndexInLB := lbClasses.ItemIndex;
  if IndexInLB > -1 then
  begin
    if Pos('***', lbClasses.Items[IndexInLB]) = 1 then
    begin
      str := copy(lbClasses.Items[IndexInLB],
        4, Length(lbClasses.Items[IndexInLB]));
      str := Trim(copy(str, 1, Pos('***', str) -1));
      lbClasses.Items.Delete(IndexInLB);
      if amcObject.ClassFileList.IndexOf(str) > -1 then
        amcObject.ClassFileList.Delete(amcObject.ClassFileList.IndexOf(str));
      i := IndexInLB;
      while i < lbClasses.Items.Count do
//      for i := IndexInLB to lbClasses.Items.Count - 1 do
      begin
        if Pos('***', lbClasses.Items[i]) = 0 then
          lbClasses.Items.Delete(i)
        else
          Break;
      end;
    end;
  end;
end;

procedure TfrmAddMacroCall.lbClassesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if lbClasses.ItemIndex > -1 then
    lbClasses.Hint := lbClasses.Items[lbClasses.ItemIndex]
  else
    lbClasses.Hint := '';
end;

procedure TfrmAddMacroCall.btnSaveHierarchyClick(Sender: TObject);
begin
  lbClasses.Items.SaveToFile(edHierarchyFile.Text);
end;

procedure TfrmAddMacroCall.btnAddMethodClick(Sender: TObject);
begin
  if  lbMethods.Items.IndexOf(Trim(edMethod.Text)) = -1 then
    lbMethods.Items.Add(Trim(edMethod.Text));
  edMethod.Text := '';
end;

procedure TfrmAddMacroCall.btnDelMethodClick(Sender: TObject);
var
  i: Integer;
begin
  if lbMethods.ItemIndex > -1 then
  begin
    i := lbMethods.ItemIndex;
    lbMethods.Items.Delete(i);
    if i = lbMethods.Items.Count then
      Dec(i);
    lbMethods.ItemIndex := i;
  end;
end;

procedure TfrmAddMacroCall.btnDelMacroCallClick(Sender: TObject);
begin
  amcObject.AddMacroCall(amcDelete);
end;

end.
