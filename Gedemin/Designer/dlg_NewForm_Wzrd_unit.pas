// ShlTanya, 24.02.2019

{++

  Copyright (c) 2002-2016 by Golden Software of Belarus, Ltd

  Module

    dlg_NewForm_Wzrd_unit.pas

  Abstract

    Gedemin project. Мастер создания пользовательской формы.

  Author



  Revisions history

    1.00    dd.mm.2002    Nick        Initial version
    1.01    28.03.2003    Yuri        Minor changes.

--}

unit dlg_NewForm_Wzrd_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, ComCtrls, gd_ClassList;

type
  Tdlg_NewForm_Wzrd = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    pcNewForm: TPageControl;
    tsFormType: TTabSheet;
    tsFormName: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    btnCancel: TButton;
    alFormWzrd: TActionList;
    Image1: TImage;
    Label1: TLabel;
    rbSimplyForm: TRadioButton;
    rbGDCForm: TRadioButton;
    tsGDC: TTabSheet;
    Label2: TLabel;
    edFormName: TEdit;
    Memo1: TMemo;
    tsInheritedType: TTabSheet;
    tsFinal: TTabSheet;
    Label3: TLabel;
    Label5: TLabel;
    cbFormType: TComboBox;
    Label6: TLabel;
    stFinal: TStaticText;
    actPrev: TAction;
    actNext: TAction;
    actOk: TAction;
    actCancel: TAction;
    Bevel1: TBevel;
    Label7: TLabel;
    edSelectedClass: TEdit;
    btnSelectClass: TButton;
    actSelectClass: TAction;
    lblWarning: TLabel;
    procedure actPrevExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure tsFinalShow(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure edFormNameKeyPress(Sender: TObject; var Key: Char);
    procedure actSelectClassExecute(Sender: TObject);
    procedure cbFormTypeClick(Sender: TObject);
    procedure edFormNameChange(Sender: TObject);

  private
    FSelectedFormClass: TgdFormEntry;
    FSelectedClass: TgdBaseEntry;

    procedure FormOnCloseQuery(Sender: TObject; var CanClose: Boolean);
    function FillAncestorFormList(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
  end;

var
  dlg_NewForm_Wzrd: Tdlg_NewForm_Wzrd;

implementation

uses
  gsResizerInterface, contnrs, gdcBase, Storages,
  gsStorage, gd_directories_const, gdc_createable_form, gdc_dlgG_unit,
  gdc_dlgTR_unit, gdc_dlgTRPC_unit, gdc_dlgHGR_unit,
  gdc_frmG_unit, gdc_frmMDH_unit, gdc_frmMDHGR_unit, gdc_frmMDHGRAccount_unit,
  gdc_frmMDV_unit, gdc_frmMDVGR_unit, gdc_frmMDVTree_unit,
  gdc_frmSGR_unit, gdc_frmSGRAccount_unit, gd_dlgClassList_unit,
  gd_createable_form, gdc_frmInvViewRemains_unit,
  gdv_frmG_unit, gdc_frmMD2H_unit, gdc_dlgInvDocument_unit,
  gdcBaseInterface;

{$R *.DFM}

procedure Tdlg_NewForm_Wzrd.actPrevExecute(Sender: TObject);
begin
  if rbSimplyForm.Checked and (pcNewForm.ActivePage = tsFinal) then
    pcNewForm.ActivePage := tsFormName
  else if (pcNewForm.ActivePage = tsFinal) and (FSelectedFormClass <> nil)
    and (Pos('tgdc_frm', LowerCase(FSelectedFormClass.TheClass.ClassName)) = 1) then
  begin
    pcNewForm.ActivePage := tsInheritedType;
  end else
    pcNewForm.ActivePageIndex := pcNewForm.ActivePageIndex - 1;
end;

procedure Tdlg_NewForm_Wzrd.actNextExecute(Sender: TObject);
begin
  if (rbSimplyForm.Checked and (pcNewForm.ActivePage = tsFormName))
     or ((pcNewForm.ActivePage = tsInheritedType) and (FSelectedFormClass <> nil)
       and (Pos('tgdc_frm', LowerCase(FSelectedFormClass.TheClass.ClassName)) = 1)) then
    pcNewForm.ActivePage := tsFinal
  else
    pcNewForm.ActivePageIndex := pcNewForm.ActivePageIndex + 1;
end;

procedure Tdlg_NewForm_Wzrd.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := pcNewForm.ActivePage <> tsFormType;
end;

procedure Tdlg_NewForm_Wzrd.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled :=
    (pcNewForm.ActivePage = tsFormType)
    or
    (
      (pcNewForm.ActivePage = tsFormName)
      and
      (edFormName.Text > '')
      and
      (not lblWarning.Visible)
    )
    or
    (
      (pcNewForm.ActivePage = tsInheritedType)
      and
      (cbFormType.ItemIndex > -1)
      and
      (FSelectedFormClass <> nil)
    )
    or
    (
      (pcNewForm.ActivePage = tsGDC)
      and
      (FSelectedClass <> nil)
    );
end;

procedure Tdlg_NewForm_Wzrd.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := pcNewForm.ActivePage = tsFinal;
end;

function Tdlg_NewForm_Wzrd.FillAncestorFormList(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
begin
  if (ACE is TgdFormEntry) and (ACE.SubType = '') and (ACE as TgdFormEntry).ShowInFormEditor then
    cbFormType.Items.AddObject(ACE.TheClass.ClassName + ' - ' + ACE.Caption, ACE);
  Result := True;
end;

procedure Tdlg_NewForm_Wzrd.FormCreate(Sender: TObject);
begin
  FSelectedFormClass := nil;
  FSelectedClass := nil;
  rbSimplyForm.Checked := True;
  edFormName.Text := '';
  lblWarning.Visible := False;
  edSelectedClass.Text := '';
  cbFormType.Clear;
  gdClassList.Traverse(TgdcCreateableForm, '', FillAncestorFormList, nil, nil);
  pcNewForm.ActivePageIndex := 0;
end;

procedure Tdlg_NewForm_Wzrd.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tdlg_NewForm_Wzrd.tsFinalShow(Sender: TObject);
var
  N: String;
begin
  N := '  Имя формы: ' + USERFORM_PREFIX + edFormName.Text + #13#10;

  if rbSimplyForm.Checked then
    stFinal.Caption := 'Простая форма'#10#13 + N
  else begin
    stFinal.Caption := 'Наследуемая форма'#10#13 + N;

    if FSelectedFormClass <> nil then
      stFinal.Caption := stFinal.Caption + '    Класс формы: ' + FSelectedFormClass.TheClass.ClassName +  #10#13;

    if FSelectedClass <> nil then
    begin
      stFinal.Caption := stFinal.Caption + '    Тип объекта формы: ' + FSelectedClass.TheClass.ClassName +  #10#13;
      stFinal.Caption := stFinal.Caption + '    Подтип объекта формы: ' + FSelectedClass.SubType;
    end;
  end;
end;

procedure Tdlg_NewForm_Wzrd.actOkExecute(Sender: TObject);
var
  F: TgdcCreateableForm;
  FgdcClass: TgdcBase;
  FCS: TCreateableFormStates;
begin
  if rbSimplyForm.Checked then
  begin
    F := TgdcCreateableForm.CreateNewUser(Application, 0);
    F.Name := USERFORM_PREFIX + edFormName.Text;
    F.OnCloseQuery := FormOnCloseQuery;
    FCS := F.CreateableFormState;
    Include(FCS, cfsCloseAfterDesign);
    F.CreateableFormState := FCS;
    if (F.Resizer <> nil) and (F.Resizer.ObjectInspectorForm <> nil) then
    begin
      F.Show;
      F.Resizer.ObjectInspectorForm.RefreshList;
    end else
      F.Free;
  end else
  begin
    if FSelectedClass = nil then
      F := FSelectedFormClass.frmClass.CreateNewUser(Application, 0)
    else
      F := FSelectedFormClass.frmClass.CreateNewUser(Application, 0, FSelectedClass.SubType);
    F.Name := USERFORM_PREFIX + edFormName.Text;
    F.Resizer.ObjectInspectorForm.RefreshList;
    F.OnCloseQuery := FormOnCloseQuery;

    if (FSelectedClass <> nil) and (Pos('tgdc_dlg', LowerCase(FSelectedClass.TheClass.ClassName)) = 1) then
    begin
      FgdcClass := FSelectedClass.gdcClass.Create(F);
      FgdcClass.SubType := FSelectedClass.SubType;
      FgdcClass.Open;
      F.Setup(FgdcClass);
    end;

    FCS := F.CreateableFormState;
    Include(FCS, cfsCloseAfterDesign);
    F.CreateableFormState := FCS;
    if (F.Resizer <> nil) and (F.Resizer.ObjectInspectorForm <> nil) then
    begin
      F.Show;
      F.Resizer.ObjectInspectorForm.RefreshList;
    end else
      F.Free;
  end;
end;

procedure Tdlg_NewForm_Wzrd.FormOnCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Sender <> Self then
    CanClose := False;
end;

procedure Tdlg_NewForm_Wzrd.edFormNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (not (Key in  ['0'..'9', 'a'..'z', 'A'..'Z', '_'])) and (Key >= #32) then
    Key := #0;
end;

procedure Tdlg_NewForm_Wzrd.actSelectClassExecute(Sender: TObject);
var
  FC: TgdcFullClassName;
begin
  with Tgd_dlgClassList.Create(Self) do
  try
    if SelectModal('', FC) then
    begin
      FSelectedClass := gdClassList.Get(TgdBaseEntry, FC.gdClassName, FC.SubType) as TgdBaseEntry;
      edSelectedClass.Text := FC.gdClassName + ' ' + FC.SubType;
    end;
  finally
    Free;
  end;
end;

procedure Tdlg_NewForm_Wzrd.cbFormTypeClick(Sender: TObject);
begin
  if cbFormType.ItemIndex > -1 then
    FSelectedFormClass := cbFormType.Items.Objects[cbFormType.ItemIndex] as TgdFormEntry
  else
    FSelectedFormClass := nil;
end;

procedure Tdlg_NewForm_Wzrd.edFormNameChange(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder(st_ds_NewFormPath, True);
  try
    lblWarning.Visible := (F <> nil)
      and F.FolderExists(USERFORM_PREFIX + edFormName.Text);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

end.
