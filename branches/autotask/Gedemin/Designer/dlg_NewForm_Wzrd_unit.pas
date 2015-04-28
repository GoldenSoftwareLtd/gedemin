
{++

  Copyright (c) 2002 by Golden Software of Belarus

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
    Label4: TLabel;
    cbGdcType: TComboBox;
    cbGdcSubtype: TComboBox;
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
    procedure actPrevExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure tsFinalShow(Sender: TObject);
    procedure cbGdcTypeClick(Sender: TObject);
    procedure edFormNameExit(Sender: TObject);
    procedure tsGDCShow(Sender: TObject);
    procedure tsInheritedTypeShow(Sender: TObject);
    procedure tsFormNameShow(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure edFormNameKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FSubTypeList: TStringList;
    procedure FormOnCloseQuery(Sender: TObject; var CanClose: Boolean);

    function BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
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
  gdc_frmSGR_unit, gdc_frmSGRAccount_unit,
  gd_createable_form, gdc_frmInvViewRemains_unit,
  gdv_frmG_unit, gdc_frmMD2H_unit, gdc_dlgInvDocument_unit;

{$R *.DFM}

var
  AncestorFormList: TClassList;

procedure Tdlg_NewForm_Wzrd.actPrevExecute(Sender: TObject);
begin
  if pcNewForm.ActivePageIndex > 0 then
  begin
    if rbSimplyForm.Checked and (pcNewForm.ActivePage = tsFinal) then
      pcNewForm.ActivePage := tsFormName
    else if (pcNewForm.ActivePage = tsFinal) and (Pos('tgdc_frm', LowerCase(cbFormType.Text)) = 1) then
      pcNewForm.ActivePage := tsInheritedType
    else
      pcNewForm.ActivePageIndex := pcNewForm.ActivePageIndex - 1;
  end
end;

procedure Tdlg_NewForm_Wzrd.actNextExecute(Sender: TObject);
begin
  if pcNewForm.ActivePageIndex < (pcNewForm.PageCount - 1) then
  begin
    if (rbSimplyForm.Checked and (pcNewForm.ActivePage = tsFormName))
       or ((pcNewForm.ActivePage = tsInheritedType) and (Pos('tgdc_frm', LowerCase(cbFormType.Text)) = 1)) then
      pcNewForm.ActivePage := tsFinal
    else
      pcNewForm.ActivePageIndex := pcNewForm.ActivePageIndex + 1;
  end;
end;

procedure Tdlg_NewForm_Wzrd.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := pcNewForm.ActivePageIndex > 0;
end;

procedure Tdlg_NewForm_Wzrd.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := pcNewForm.ActivePageIndex < (pcNewForm.PageCount - 1);
{ TODO : Добавить проверку на заполнение необх. данных на каждой закладке. }
end;

procedure Tdlg_NewForm_Wzrd.actOkUpdate(Sender: TObject);
begin

  if edFormName.Text > '' then
  begin
    if rbSimplyForm.Checked then
      actOk.Enabled := True
    else
      if (cbFormType.ItemIndex <> -1) and ((cbGdcType.ItemIndex <> -1) or (Pos('tgdc_frm', LowerCase(cbFormType.Text)) = 1)) then
        actOk.Enabled := True
      else
        actOk.Enabled := False;
  end
  else
    actOk.Enabled := False;

end;

function Tdlg_NewForm_Wzrd.BuildClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
begin
  if (ACE is TgdBaseEntry) and (ACE.SubType = '') then
    if not TgdBaseEntry(ACE).gdcClass.IsAbstractClass then
      cbGdcType.Items.Add(ACE.TheClass.ClassName);
      
  Result := True;
end;

procedure Tdlg_NewForm_Wzrd.FormCreate(Sender: TObject);
var
  I: Integer;
  function GetClassDescription(const AName: String): String;
  var
    S: String;
  begin

    S := UpperCase(AName);
    if S = 'TGDC_DLGG' then
      Result :=	'Простой диалог'
    else if S = 'TGDC_DLGTR' then
      Result := 'Диалог с транзакцией'
    else if S = 'TGDC_DLGTRPC' then
      Result := 'Диалог с закладками'
    else if S = 'TGDC_DLGHGR' then
      Result := 'Диалог с гридом'
    else if S = 'TGDC_FRMG' then
      Result := 'Простая форма'
    else if S = 'TGDC_FRMMDH' then
      Result := 'Master-detail форма (гориз.)'
    else if S = 'TGDC_FRMMDHGR' then
      Result := 'Master-detail с гридом'
    else if S = 'TGDC_FRMMDHGRACCOUNT' then
      Result := 'Master-detail форма с гридом и р/с'
    else if S = 'TGDC_FRMMDV' then
      Result := 'Master-detail форма (вер.)'
    else if S = 'TGDC_FRMMDVGR' then
      Result := 'Master-detail форма с гридом'
    else if S = 'TGDC_FRMMDVTREE' then
      Result := 'Дерево с гридом'
    else if S = 'TGDC_FRMSGR' then
      Result := 'Простая форма с гридом'
    else if S = 'TGDC_FRMSGRACCOUNT' then
      Result := 'Простая форма с гридом и р/с'
    else if S = 'TGDC_FRMINVVIEWREMAINS' then
      Result := 'Форма просмотра остатков'
    else if S = 'TGDV_FRMG' then
      Result := 'Форма просмотра бухгалтерского отчета'
    else if S = 'TGDC_FRMMD2H' then
      Result := 'Master-detail-subdetail форма'
    else Result := '';
{    if Result > '' then
      Result := ' (' + Result + ')';}
  end;
begin
  FSubTypeList := TStringList.Create;
  rbSimplyForm.Checked := True;
  edFormName.Text := '';
  pcNewForm.ActivePageIndex := 0;

  cbGdcType.Items.Clear;

  gdClassList.Traverse(TgdcBase, '', BuildClassTree, nil, nil);

  cbFormType.Clear;
  for I := 0 to AncestorFormList.Count - 1 do
  begin
    cbFormType.Items.AddObject(GetClassDescription(AncestorFormList[I].ClassName) + ' (' + AncestorFormList[I].ClassName + ')', Pointer(I));
//    cbFormType.Items.AddObject(AncestorFormList[I].ClassName + GetClassDescription(AncestorFormList[I].ClassName), Pointer(I));
  end;
end;

procedure Tdlg_NewForm_Wzrd.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tdlg_NewForm_Wzrd.tsFinalShow(Sender: TObject);
begin
  stFinal.Caption := '';
  if rbSimplyForm.Checked then
    stFinal.Caption := 'Простая форма'#10#13
  else
    stFinal.Caption := 'Наследуемая форма'#10#13;

  stFinal.Caption := stFinal.Caption + '  Имя формы: ' + USERFORM_PREFIX + Trim(edFormName.Text) +  #10#13;

  if rbGDCForm.Checked then
  begin
    stFinal.Caption := stFinal.Caption + '    Класс формы: ' + cbFormType.Text +  #10#13;
    stFinal.Caption := stFinal.Caption + '    Тип объекта формы: ' + cbGdcType.Text +  #10#13;
    stFinal.Caption := stFinal.Caption + '    Подтип объекта формы: ' + cbGdcSubtype.Text;
  end;
end;

procedure Tdlg_NewForm_Wzrd.cbGdcTypeClick(Sender: TObject);
var
  P: TPersistentClass;
  I: Integer;
begin
  if cbGdcType.ItemIndex > -1 then
  begin
    P := GetClass(cbGdcType.Text);
    cbGdcSubtype.Items.Clear;
    cbGdcSubtype.Enabled := CgdcBase(P).GetSubTypeList(FSubTypeList);
    if cbGdcSubtype.Enabled then
      for I := 0 to FSubTypeList.Count - 1 do
        cbGdcSubtype.Items.Add(FSubTypeList.Names[I]);
  end;
end;

procedure RegisterAncestorForm(AncestorForms: Array of TPersistentClass);
var
  I: Integer;
begin
  if not Assigned(AncestorFormList) then
    AncestorFormList := TClassList.Create
  else
    AncestorFormList.Clear;
  for I := Low(AncestorForms) to High(AncestorForms) do
    AncestorFormList.Add(AncestorForms[I]);
end;

procedure Tdlg_NewForm_Wzrd.edFormNameExit(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  if ActiveControl = btnCancel then
    Exit;
  F := GlobalStorage.OpenFolder(st_ds_NewFormPath, True);
  try
    if F <> nil then
    begin
      if F.FolderExists(USERFORM_PREFIX + edFormName.Text) then
      begin
        ShowMessage('Форма с таким именем уже существует.');
        edFormName.SetFocus;
      end;
    end;
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure Tdlg_NewForm_Wzrd.tsGDCShow(Sender: TObject);
begin
  cbGdcType.SetFocus;
end;

procedure Tdlg_NewForm_Wzrd.tsInheritedTypeShow(Sender: TObject);
begin
  cbFormType.SetFocus;
end;

procedure Tdlg_NewForm_Wzrd.tsFormNameShow(Sender: TObject);
begin
  edFormName.SetFocus;
end;

procedure Tdlg_NewForm_Wzrd.actOkExecute(Sender: TObject);
var
  P: TPersistentClass;
//  S: String;
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
    if Assigned(F.Resizer.ObjectInspectorForm) then
    begin
      F.Show;
      F.Resizer.ObjectInspectorForm.RefreshList;
    end
    else
      F.Free;
  end
  else
  begin

    P := TPersistentClass(AncestorFormList[Integer(cbFormType.Items.Objects[cbFormType.ItemIndex])]);
    if P <> nil then
    begin
      F := CgdcCreateableForm(P).CreateNewUser(Application, 0, FSubTypeList.Values[cbGdcSubtype.Text]);
      F.Name := USERFORM_PREFIX + edFormName.Text;
      F.Resizer.ObjectInspectorForm.RefreshList;
      F.OnCloseQuery := FormOnCloseQuery;

      if Pos('tgdc_dlg', LowerCase(cbFormType.Text)) = 1 then
      begin
        P := GetClass(cbGdcType.Text);
        if P <> nil then
        begin
          FgdcClass := CgdcBase(P).Create(F);
          if cbGdcSubtype.Text <> '' then
            FgdcClass.SubType := FSubTypeList.Values[cbGdcSubtype.Text];
          FgdcClass.Open;
          F.Setup(FgdcClass);
        end
        else
          ShowMessage('Класс незарегистрирован');
      end;

      FCS := F.CreateableFormState;
      Include(FCS, cfsCloseAfterDesign);
      F.CreateableFormState := FCS;
      if Assigned(F.Resizer.ObjectInspectorForm) then
      begin
        F.Show;
        F.Resizer.ObjectInspectorForm.RefreshList;
      end
      else
        F.Free;
    end
    else
      ShowMessage('Класс формы незарегистрирован');
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

procedure Tdlg_NewForm_Wzrd.FormDestroy(Sender: TObject);
begin
  FSubTypeList.Free;
end;

initialization
  RegisterAncestorForm([Tgdc_dlgG, Tgdc_dlgTR, Tgdc_dlgTRPC, Tgdc_dlgHGR,
                        Tgdc_frmG, Tgdc_frmMDH, Tgdc_frmMDHGR, Tgdc_frmMDHGRAccount,
                        Tgdc_frmMDV, Tgdc_frmMDVGR, Tgdc_frmMDVTree,
                        Tgdc_frmSGR, Tgdc_frmSGRAccount, Tgdc_frmInvViewRemains,
                        Tgdv_frmG, Tgdc_frmMD2H, TdlgInvDocument])

finalization
  AncestorFormList.Free;

end.
