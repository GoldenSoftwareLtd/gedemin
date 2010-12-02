{********************************************************}
{                                                        }
{   JPEG-Support for Delphi (Design- and Runtime)        }
{   For IBExpress users                                  }
{                                                        }
{   Copyright (c) 2002 Robert Kuhlmann, Bremen, Germany  }
{        with quotations from unit DB.pas (VCL sources)  }
{        copyright (c) 1995, 02 Borland Corporation      }
{                                                        }
{    For questions or comments please contact            }
{    robert.kuhlmann1@ewetel.net                         }
{                                                        }
{********************************************************}

unit GraphicSupportIB;

interface

uses
  GraphicSupport;

procedure Register;

implementation

uses
  Classes, db, IBCustomDataset;

procedure Register;
begin
  { Register gets called by the IDE, when the package is loaded via LoadPackage,
    so the replacement can happen here to ensure JPEG support at designtime. }
  TFieldClass(Pointer(@DefaultFieldClasses[ftBlob])^) := TEnhBlobField;
  TFieldClass(Pointer(@DefaultFieldClasses[ftGraphic])^) := TEnhGraphicField;
  RegisterClass(TEnhBlobField);
  RegisterClass(TEnhGraphicField);
end;

initialization
  { This part ensures JPEG support for applications that use IBExpress instead
    of standard DB. For details  take a look at the readme-file. }
  TFieldClass(Pointer(@DefaultFieldClasses[ftBlob])^) := TEnhBlobField;
  TFieldClass(Pointer(@DefaultFieldClasses[ftGraphic])^) := TEnhGraphicField;
finalization
  TFieldClass(Pointer(@DefaultFieldClasses[ftBlob])^) := TBlobField;
  TFieldClass(Pointer(@DefaultFieldClasses[ftGraphic])^) := TGraphicField;
end.
