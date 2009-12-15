program Inventory_doc_project;

uses
  Forms,
  Inventory_doc_unit in 'Inventory_doc_unit.pas' {Form1},
  gdcInvDocument_unit in 'gdcInvDocument_unit.pas',
  gdcInvMovement in 'gdcInvMovement.pas',
  gdcInvConsts_unit in 'gdcInvConsts_unit.pas',
  gdc_dlgSetupInvDocument_unit in 'gdc_dlgSetupInvDocument_unit.pas' {dlgSetupInvDocument},
  gdc_dlgG_unit in '..\Component\Repository\gdc_dlgG_unit.pas' {gdc_dlgG},
  dmImages_unit in '..\Gedemin\dmImages_unit.pas' {dmImages: TDataModule},
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas' {dmDatabase: TDataModule},
  Inventory_document_unit in 'Inventory_document_unit.pas' {frmNewDocument},
  gdc_dlgInvDocument_unit in 'gdc_dlgInvDocument_unit.pas' {dlgInvDocument},
  gdc_dlgInvDocumentLine_unit in 'gdc_dlgInvDocumentLine_unit.pas' {dlgInvDocumentLine},
  gdc_dlgTR_unit in '..\Component\Repository\gdc_dlgTR_unit.pas' {gdc_dlgTR},
  gdc_frmSGRAccount_unit in '..\Component\Repository\gdc_frmSGRAccount_unit.pas',
  gdc_dlgHGR_unit in '..\Component\Repository\gdc_dlgHGR_unit.pas' {gdc_dlgHGR},
  gdc_frmG_unit in '..\Component\Repository\gdc_frmG_unit.pas' {gdc_frmG},
  gdc_frmMDH_unit in '..\Component\Repository\gdc_frmMDH_unit.pas' {gdc_frmMDH},
  gdc_frmMDHGR_unit in '..\Component\Repository\gdc_frmMDHGR_unit.pas' {gdc_frmMDHGR},
  gdc_frmMDHGRAccount_unit in '..\Component\Repository\gdc_frmMDHGRAccount_unit.pas' {gdc_frmMDHGRAccount},
  gdc_frmMDV_unit in '..\Component\Repository\gdc_frmMDV_unit.pas' {gdc_frmMDV},
  gdc_frmMDVGR_unit in '..\Component\Repository\gdc_frmMDVGR_unit.pas' {gdc_frmMDVGR},
  gdc_frmMDVGR2_unit in '..\Component\Repository\gdc_frmMDVGR2_unit.pas' {gdc_frmMDVGR2},
  gdc_frmMDVTree_unit in '..\Component\Repository\gdc_frmMDVTree_unit.pas' {gdc_frmMDVTree},
  gdc_frmMDVTree2_unit in '..\Component\Repository\gdc_frmMDVTree2_unit.pas' {gdc_frmMDVTree2},
  gdc_frmSGR_unit in '..\Component\Repository\gdc_frmSGR_unit.pas' {gdc_frmSGR},
  gdc_frmInvDocument_unit in 'gdc_frmInvDocument_unit.pas' {gdc_frmInvDocument},
  gdc_dlgSelectGoodFeatures_unit in 'gdc_dlgSelectGoodFeatures_unit.pas' {dlgSelectGoodFeatures},
  gdcInvPriceList_unit in 'gdcInvPriceList_unit.pas',
  gdc_frmInvPriceListType_unit in 'gdc_frmInvPriceListType_unit.pas' {gdc_frmInvPriceListType},
  gdc_dlgSetupInvPriceList_unit in 'gdc_dlgSetupInvPriceList_unit.pas' {dlgSetupInvPriceList},
  gdc_frmInvDocumentType_unit in 'gdc_frmInvDocumentType_unit.pas' {gdc_frmInvDocumentType},
  gdcInvUtils_unit in 'gdcInvUtils_unit.pas',
  gdc_frmInvPriceList_unit in 'gdc_frmInvPriceList_unit.pas' {gdc_frmInvPriceList},
  gdc_dlgInvPriceList_unit in 'gdc_dlgInvPriceList_unit.pas' {dlgInvPriceList};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TdmImages, dmImages);
  Application.CreateForm(TdmDatabase, dmDatabase);
  Application.CreateForm(Tgdc_frmInvPriceListType, gdc_frmInvPriceListType);
  Application.Run;
end.
