program wizard;

uses
  Forms,
  wiz_Main_Unit in 'wiz_Main_Unit.pas' {Form1},
  wiz_FunctionBlock_unit in 'wiz_FunctionBlock_unit.pas',
  wiz_dlgEditFrom_unit in 'wiz_dlgEditFrom_unit.pas' {BlockEditForm},
  wiz_dlgVarEditForm_unit in 'wiz_dlgVarEditForm_unit.pas' {dlgVarEditForm},
  wiz_ExpressionEditorForm_unit in 'wiz_ExpressionEditorForm_unit.pas' {ExpressionEditorForm},
  dmImages_unit in '..\..\Gedemin\dmImages_unit.pas' {dmImages: TDataModule},
  wiz_dlgEntryEditForm_unit in 'wiz_dlgEntryEditForm_unit.pas' {dlgEntryEditForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TBlockEditForm, BlockEditForm);
  Application.CreateForm(TdlgVarEditForm, dlgVarEditForm);
  Application.CreateForm(TExpressionEditorForm, ExpressionEditorForm);
  Application.CreateForm(TdmImages, dmImages);
  Application.CreateForm(TdlgEntryEditForm, dlgEntryEditForm);
  Application.Run;
end.
