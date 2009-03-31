{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_dlgEditFrom_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_FunctionBlock_unit, StdCtrls, ExtCtrls, ActnList, ComCtrls;

type
  TBlockEditForm= class(TdlgBaseEditForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    PageControl: TPageControl;
    tsGeneral: TTabSheet;
    Label1: TLabel;
    cbName: TComboBox;
    Label2: TLabel;
    mDescription: TMemo;
    Button4: TButton;
    actHelp: TAction;
    eLocalName: TEdit;
    lLocalName: TLabel;
    procedure actOkUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure eNameChange(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); override;  
  public
    { Public declarations }
    procedure SaveChanges; override;
  end;

var
  BlockEditForm: TBlockEditForm;

implementation

{$R *.DFM}

procedure TBlockEditForm.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CheckOk;
end;

procedure TBlockEditForm.actOkExecute(Sender: TObject);
begin
  SaveChanges;
end;

procedure TBlockEditForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  cbName.Text := Value.BlockName;
  mDescription.Lines.Text := Value.Description;
  eLocalName.Text := Value.LocalName;
end;

procedure TBlockEditForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TBlockEditForm.eNameChange(Sender: TObject);
begin
  FBlock.BlockName := cbName.Text;
end;

procedure TBlockEditForm.SaveChanges;
begin
  inherited;
  FBlock.BlockName := cbName.Text;
  FBlock.Description := mDescription.Lines.Text;
  FBlock.LocalName := eLocalName.Text;
end;

procedure TBlockEditForm.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
 