// ShlTanya, 24.02.2019

unit obj_WrapperMessageClasses;

interface

uses
  obj_WrapperGSClasses, Gedemin_TLB, gdcMessage;

type
  TwrpGdcBaseMessage = class(TwrpGDCBase, IgsGdcBaseMessage)
  private
    function  GetGdcBaseMessage: TgdcBaseMessage;
  protected
    function  GetMessageType: WideString; safecall;
  end;

  TwrpGdcAttachment = class(TwrpGDCBase, IgsGdcAttachment)
  private
    function  GetGdcAttachment: TgdcAttachment;
  protected
    procedure OpenAttachment; safecall;
  end;

implementation

uses
  ComServ, gdcOLEClassList;

{ TwrpGdcBaseMessage }

function TwrpGdcBaseMessage.GetGdcBaseMessage: TgdcBaseMessage;
begin
  Result := GetObject as TgdcBaseMessage;
end;

function TwrpGdcBaseMessage.GetMessageType: WideString;
begin
  Result := GetGdcBaseMessage.GetMessageType;
end;

{ TwrpGdcAttachment }

function TwrpGdcAttachment.GetGdcAttachment: TgdcAttachment;
begin
  Result := GetObject as TgdcAttachment;
end;

procedure TwrpGdcAttachment.OpenAttachment;
begin
  GetGdcAttachment.OpenAttachment;
end;

initialization
  RegisterGdcOLEClass(TgdcBaseMessage, TwrpGdcBaseMessage, ComServer.TypeLib, IID_IgsGdcBaseMessage);
  RegisterGdcOLEClass(TgdcAttachment, TwrpGdcAttachment, ComServer.TypeLib, IID_IgsGdcAttachment);
end.
