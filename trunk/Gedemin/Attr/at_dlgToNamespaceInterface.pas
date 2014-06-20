
unit at_dlgToNamespaceInterface;

interface

uses
  gdcBaseInterface;

type
  TgsNSObjectKind = (nskSelected, nskLinked, nskCompound);

  Iat_dlgToNamespace = interface
    procedure AddObject(const AnObjID: Integer;
      const AnObjectName: String;
      const AClassName: String;
      const ASubType: String;
      const ARUID: TRUID;
      const AEditionDate: TDateTime;
      const AHeadObjectKey: Integer;
      const ANamespace: String;
      const AKind: TgsNSObjectKind);
  end;

implementation

end.