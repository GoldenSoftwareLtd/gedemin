
unit at_dlgToNamespaceInterface;

interface

uses
  gdcBaseInterface;

type
  Iat_dlgToNamespace = interface
    procedure AddObject(const AnObjID: Integer;
      const AnObjectName: String;
      const AClassName: String;
      const ASubType: String;
      const ARUID: TRUID;
      const AEditionDate: TDateTime;
      const AHeadObjectKey: Integer;
      const ANamespace: String;
      const ALinked: Boolean);
  end;

implementation

end.