unit gsIBLookupComboBox_dlgAction;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, jpeg, ExtCtrls, ActnList;

type
  TgsIBLkUp_dlgAction = class(TForm)
    btnList: TButton;
    btnCreate: TButton;
    btnClose: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblText: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    cb: TComboBox;
    ActionList: TActionList;
    actCreateNew: TAction;
    procedure actCreateNewExecute(Sender: TObject);
    procedure actCreateNewUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gsIBLkUp_dlgAction: TgsIBLkUp_dlgAction;

implementation

{$R *.DFM}

procedure TgsIBLkUp_dlgAction.actCreateNewExecute(Sender: TObject);
begin
  ModalResult := mrYes;
end;

procedure TgsIBLkUp_dlgAction.actCreateNewUpdate(Sender: TObject);
begin
  actCreateNew.Enabled := (not cb.Visible)
    or (cb.ItemIndex > 0);
end;

end.
