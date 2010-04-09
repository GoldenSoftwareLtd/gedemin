unit gdcAcctDocument;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcTree, gdcClasses, gd_createable_form;

type
  TgdcAcctDocument = class(TgdcDocument)
  private
    { Private declarations }
  protected
    { Protected declarations }

    procedure MakeEntry; override;
  public
    { Public declarations }

    function DocumentTypeKey: Integer; override;
  published
    { Published declarations }
  end;

procedure Register;

implementation
uses gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdcAcctAccount', [TgdcAcctDocument]);
end;

{ TgdcAcctDocument }

function TgdcAcctDocument.DocumentTypeKey: Integer;
begin
  Result := 805001;
end;

procedure TgdcAcctDocument.MakeEntry;
begin

  // Перекрыт так проводки создаются вручную

end;

initialization
  RegisterGdcClass(TgdcAcctDocument);
finalization
  UnRegisterGdcClass(TgdcAcctDocument);
end.
