unit gdcAcctDocument;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcTree, gdcClasses, gd_createable_form;

type
  TgdcAcctDocument = class(TgdcDocument)
  protected
    procedure MakeEntry; override;

  public
    class function ClassDocumentTypeKey: Integer; override;
  end;

procedure Register;

implementation

uses
  gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdcAcctAccount', [TgdcAcctDocument]);
end;

{ TgdcAcctDocument }

class function TgdcAcctDocument.ClassDocumentTypeKey: Integer;
begin
  Result := 805001;
end;

procedure TgdcAcctDocument.MakeEntry;
begin
  // �������� ��� �������� ��������� �������
end;

initialization
  RegisterGdcClass(TgdcAcctDocument);

finalization
  UnregisterGdcClass(TgdcAcctDocument);
end.
