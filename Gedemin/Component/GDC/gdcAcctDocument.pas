// ShlTanya, 09.02.2019

unit gdcAcctDocument;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcTree, gdcClasses, gd_createable_form,
  gdcBaseInterface;

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
  // Перекрыт так проводки создаются вручную
end;

initialization
  RegisterGdcClass(TgdcAcctDocument);

finalization
  UnregisterGdcClass(TgdcAcctDocument);
end.
