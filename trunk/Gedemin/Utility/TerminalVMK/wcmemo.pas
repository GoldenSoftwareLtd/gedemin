{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit wcmemo; 

interface

uses
  WMemo, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('WMemo', @WMemo.Register); 
end; 

initialization
  RegisterPackage('wcmemo', @Register); 
end.
