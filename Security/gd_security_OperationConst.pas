
// ��������� ��������
unit gd_security_operationconst;

interface

const
  // ����������
  // �����������������
  GD_SYS_GADMIN      = 1000;
  // �������� �����
  GD_SYS_ADDRESSBOOK = 100;
  // ������ ��������
  GD_SYS_EVENTVIEWER = 200;
  // BugBase
  GD_SYS_BUGBASE     = 300;
  // Setup
  GD_SYS_SETUP       = 400;
  // ���������� �������
  GD_SYS_GOOD        = 500;
  //���������
  GD_SYS_MESSAGES    = 600;
  // �����������
  GD_SYS_ACCOUNT     = 700;
  // ������
  GD_SYS_REPORTSERVER = 800;

  //��������
  GD_OP_START           = 100010;
  GD_OP_EXIT            = 100020;
  GD_OP_INCORRECTEXIT   = 100030;

  // ������ � ����������
  GD_OP_VIEWCONTACT     = 101000;
  GD_OP_ADDCONTACT      = 101010;
  GD_OP_DELETECONTACT   = 101020;
  GD_OP_EDITCONTACT     = 101030;

  // ������ � �����������
  GD_OP_MESSAGE         = 101500; // �� ������
  GD_OP_NEWMESSAGE      = 101510;
  GD_OP_EDITMESSAGE     = 101512;
  GD_OP_DELETEMESSAGE   = 101514;

  // ������ � ����������
  GD_OP_VIEWATTR        = 102000;
  GD_OP_SYNCATTR        = 102005;
  GD_OP_ADDATTR         = 102010;
  GD_OP_EDITATTR        = 102020;
  GD_OP_DELETEATTR      = 102030;

  // ������ � ���������� �����������
  GD_OP_ADDATTRSET      = 102040;
  GD_OP_EDITATTRSET     = 102050;
  GD_OP_DELETEATTRSET   = 102060;

  //������ � ���������� ������������
  GD_OP_ADDATTRREF      = 102070;
  GD_OP_DELETEATTRREF   = 102080;
  GD_OP_EDITATTRREF     = 102090;

  //������ � ���������
  GD_OP_ADDINDEX        = 102100;
  GD_OP_DELETEINDEX     = 102110;

  //��������� ���� ������� � �������� �����������
  GD_OP_CHANGERIGHTATTRREF = 102120;

  // ������ � ��������������� ������������
  GD_OP_VIEWDimension   = 102200;
  GD_OP_ADDDimension    = 102210;
  GD_OP_EDITDimension   = 102220;
  GD_OP_DELETEDimension = 102230;

  // ���������� ����������� � ��������-�����������
  GD_OP_ATTRDIMENSION   = 102240;

  // ������ �� ������������ ������
  GD_OP_VIEWCARDACCOUNT = 103000;
  GD_OP_ADDCARDACCOUNT  = 103010;
  GD_OP_DELETECARDACCOUNT = 103020;
  GD_OP_EDITCARDACCOUNT = 103030;

  // ������ � �������� ����������
  GD_OP_VIEWTRTYPE = 104000;
  GD_OP_ADDTRTYPE = 104010;
  GD_OP_DELETETRTYPE = 104020;
  GD_OP_EDITTRTYPE = 104030;

  // ������ � �������� ����������
  GD_OP_ADDENTRYTYPE = 105010;
  GD_OP_DELETEENTRYTYPE = 105020;
  GD_OP_EDITENTRYTYPE = 105030;

  // EVENT VIEWER
  GD_OP_ARCHIVEOPERATION = 106010;
  GD_OP_DELETEOPERATION = 106020;

  //������ ���������
  GD_OP_AB_VIEWFILTER = 107000;
  GD_OP_AB_ADDFILTER = 107010;
  GD_OP_AB_DELETEFILTER = 107020;
  GD_OP_AB_EDITFILTER = 107030;

  //������ �������
  GD_OP_VIEWCURR = 108000;
  GD_OP_ADDCURR = 108010;
  GD_OP_DELETECURR = 108020;
  GD_OP_EDITCURR = 108030;
  GD_OP_ADDCURRRATE = 108040;
  GD_OP_DELETECURRRATE = 108050;
  GD_OP_EDITCURRRATE = 108060;

  // ��������� ���������
  BN_OP_VIEWPAYMENTORDER = 111100;
  BN_OP_ADDPAYMENTORDER = 111110;
  BN_OP_DELETEPAYMENTORDER = 111120;
  BN_OP_EDITPAYMENTORDER = 111130;
  BN_OP_TR_PAYMENTORDER = 111135;

  // ��������� ���������
  BN_OP_VIEWPAYMENTDEMAND = 111200;
  BN_OP_ADDPAYMENTDEMAND = 111210;
  BN_OP_DELETEPAYMENTDEMAND = 112120;
  BN_OP_EDITPAYMENTDEMAND = 111230;
  BN_OP_TR_PAYMENTDEMAND = 111235;

  // ���������� �������
  BN_OP_ADDPAYMENTSPEC = 111140;
  BN_OP_DELETEPAYMENTSPEC = 111150;
  BN_OP_EDITPAYMENTSPEC = 111160;

  // ���������� �������
  BN_OP_VIEWBANKSTATEMENT = 111300;
  BN_OP_ADDBANKSTATEMENT = 111310;
  BN_OP_DELETEBANKSTATEMENT = 111320;
  BN_OP_EDITBANKSTATEMENT = 111330;
  BN_OP_TR_BANKSTATEMENT = 111340;

  // �������� ������������
  BN_OP_VIEWUSERDOCUMENT = 111400;
  BN_OP_ADDUSERDOCUMENT = 111410;
  BN_OP_DELETEUSERDOCUMENT = 111420;
  BN_OP_EDITUSERDOCUMENT = 111430;

  // ���������� ������� {BEGIN}

  // ������ � �������� �������
  GD_OP_ADDGOODGROUP = 121100;
  GD_OP_EDITGOODGROUP = 121200;
  GD_OP_DELETEGOODGROUP = 121300;

  // ������ � ��������
  GD_OP_ADDGOOD = 122100;
  GD_OP_EDITGOOD = 122200;
  GD_OP_DELETEGOOD = 122300;

  // ������ � ��������� ���������
  GD_OP_ADDVALUE = 123110;
  GD_OP_EDITVALUE = 123120;
  GD_OP_DELETEVALUE = 123130;

  // ������ � ��������� ��������� � ����������� ������
  GD_OP_ADDGOODVALUE = 123140;
  GD_OP_EDITGOODVALUE = 123150;
  GD_OP_DELETEGOODVALUE = 123160;

  // ������ � ��������
  GD_OP_ADDTAX = 123210;
  GD_OP_EDITTAX = 123220;
  GD_OP_DELETETAX = 123230;

  // ������ � �������� � ����������� ������
  GD_OP_ADDGOODTAX = 123240;
  GD_OP_EDITGOODTAX = 123250;
  GD_OP_DELETEGOODTAX = 123260;

  // ������ � ��������������
  GD_OP_ADDSETGOOD = 123310;
  GD_OP_EDITSETGOOD = 123320;
  GD_OP_DELETESETGOOD = 123330;

  // ������ �� �����-������
  GD_OP_ADDBARCODEGOOD = 123410;
  GD_OP_EDITBARCODEGOOD = 123420;
  GD_OP_DELETEBARCODEGOOD = 123430;

  // ������ �� ������������ ����
  GD_OP_ADDTNVD = 123510;
  GD_OP_EDITTNVD = 123520;
  GD_OP_DELETETNVD = 123530;

  // ������ �� ������������ ������������
  GD_OP_ADDPRMETAL = 123610;
  GD_OP_EDITPRMETAL = 123620;
  GD_OP_DELETEPRMETAL = 123630;

  // ������ � ������������� � ����������� ������
  GD_OP_ADDGOODPRMETAL = 123640;
  GD_OP_EDITGOODPRMETAL = 123650;
  GD_OP_DELETEGOODPRMETAL = 123660;

  // {END}

  // ����������� ���� {BEGIN}

  // ������ � ������������ ������
  GD_OP_CALCFIELD = 131000;

  GD_OP_ADDCALCFIELD = 131100;
  GD_OP_EDITCALCFIELD = 131200;
  GD_OP_DELETECALCFIELD = 131300;

  // ������ � ����������� �����������
  GD_OP_GLOBALVAR = 132000;

  GD_OP_ADDGLOBALVAR = 132100;
  GD_OP_EDITGLOBALVAR = 132300;
  GD_OP_SETGLOBALVAR = 132200;

  // ������ ���������� boCalcField
  GD_OP_RECALCFIELD = 133000;

  // {END}

  // �����������
  GD_OP_REFERENCE           = 100200;

  // ���������������-��������������� �������
  GD_OP_PLACE               = 100210;
  GD_OP_ADDPLACE            = 100212;
  GD_OP_EDITPLACE           = 100214;
  GD_OP_DELETEPLACE         = 100216;
  GD_OP_DUPLICATEPLACE      = 100218;

  // ���� ������ �����������
  GD_OP_COMPACCTYPE          = 100230;
  GD_OP_ADDCOMPACCTYPE       = 100232;
  GD_OP_EDITCOMPACCTYPE      = 100234;
  GD_OP_DELETECOMPACCTYPE    = 100236;
  GD_OP_DUPLICATECOMPACCTYPE = 100238;


  GD_REF_CONTACT = 50100;
  GD_REF_CURR = 50200;
  GD_REF_PAYMENTORDER = 50300;
  GD_REF_PAYMENTSPEC = 50400;
  GD_REF_BANKSTATEMENT = 50500;
  GD_REF_BANKSTATEMENTLINE = 50600;
  GD_REF_GOOD = 50800;
  GD_REF_PAYMENTDEMAND = 50900;
  GD_REF_MESSAGES = 51000;

  // ������� �����������

  // ����������� ������
  GD_TR_EXPENDITURE_CASHLESS = 400110;

  GD_TR_VAR_EXPENDITURE_CASHLESS_COMPANY = 500110;
  GD_TR_VAR_EXPENDITURE_CASHLESS_COMPANYGROUP = 500111;
  GD_TR_VAR_EXPENDITURE_CASHLESS_COMPANYTYPE = 500112;
  GD_TR_VAR_EXPENDITURE_CASHLESS_PAYMENTSPEC = 500113;

  // ����������� ������
  GD_TR_INCOME_CASHLESS = 400120;

  // �������� ������
  GD_TR_EXPENDITURE_CASH = 400130;

  // �������� ������
  GD_TR_INCOME_CASH = 400130;

  // �������� ������������
  GD_TR_USER = 401000;

  /////////////////////////////////////////////////////////////////////////////
  // ������� ���������

  /////////////////////////////////////////////////////////////////////////////
  // ����
  BN_DOC_PAYMENTORDER                      = 800100; // ��������� ���������
  BN_DOC_PAYMENTDEMAND                     = 800200; // ��������� ����������
  BN_DOC_PAYMENTDEMANDPAYMENT              = 800210; // ����������-���������
  BN_DOC_ADVICEOFCOLLECTION                = 800220; // ���������� ������������
  BN_DOC_BANKSTATEMENT                     = 800300; // ���������� �������
    BN_DOC_BS_REVALUATION                  = 800302; // ����������
    BN_DOC_BS_INCOME                       = 800304; // ������
    BN_DOC_BS_OUTCOME                      = 800306; // ������
  BN_DOC_BANKCATALOGUE                     = 800350; // ���������
    BN_DOC_BC_POS                          = 800352; // ������ �� ���������
  BN_DOC_CHECKLIST                         = 800400; // ������ �����
  BN_DOC_CURRCOMMISION                     = 800500; // �������� ��������
  BN_DOC_CURRSELLCONTRACT                  = 800510; // ������� �� ������� ������
  BN_DOC_CURRCOMMISSSELL                   = 800520; // ��������� �� ������� ������
  BN_DOC_CURRLISTALLOCATION                = 800530; // ������ ������������� ������
  BN_DOC_CURRBUYCONTRACT                   = 800540; // ������� �� ������� ������
  BN_DOC_CURRCONVCONTRACT                  = 800550; // �������� �� �������� ������

  /////////////////////////////////////////////////////////////////////////////
  // ������
  GD_DOC_USERDOCUMENT                      = 801000; // ����� �������� ������������

  /////////////////////////////////////////////////////////////////////////////
  // ����������

  GD_DOC_REALIZATIONBILL                   = 802001; // ��������� �� ������ ���
  GD_DOC_CONTRACT                          = 802002; // ��������
  GD_DOC_RETURNBILL                        = 802003; // ��������� �� ������� ���
  GD_DOC_BILL                              = 802004; // ����-�������

  /////////////////////////////////////////////////////////////////////////////
  // ���� ��� ������
  CTL_DOC_INVOICE                          = 803001;
  CTL_DOC_RECEIPT                          = 803101;

  /////////////////////////////////////////////////////////////////////////////
  // �����������
//  {$IFDEF DEPARTMENT}
  DP_DOC_INVENTORY                         = 849010; // ��� ����� � ������
  DP_DOC_TRANSFER                          = 849020; // ��� ��������
  DP_DOC_REVALUATION                       = 849030; // ��� ����������
  DP_DOC_WITHDRAWAL                        = 849040; // ��� ������� ������
//  {$ENDIF}

  /////////////////////////////////////////////////////////////////////////////
  //  ��������� ���������


  INV_DOC_INVENTBRANCH                     = 804000; // ����� ��������� ����������
  INV_DOC_PRICELISTBRANCH                  = 805000; // ����� ����� �����-������

  /////////////////////////////////////////////////////////////////////////////
  //  ��������� ���������

  GD_DOC_TAXRESULT                         = 807005; // ���������� ������� ������� �� �������



  /////////////////////////////////////////////////////////////////////////////
  // ���� ���������
  //
  CST_FOLDER                               = 0;      // �����
  CST_GROUP                                = 1;      // ������ ���������
  CST_CONTACT                              = 2;      // ������� (�������)
  CST_COMPANY                              = 3;      // �����������
  CST_DEPARTMENT                           = 4;      // �������������
  CST_BANK                                 = 5;      // ����

  {$IFDEF DEPARTMENT}
  CST_SALE                                 = 100;    //
  CST_AUTHORITY                            = 101;    //
  CST_FINANCIAL                            = 102;    //
  CST_MAIN                                 = 103;    //
  {$ENDIF}

  // ������ ������ ���������� ��������
  OBJ_APPLICATION                   = 1010001;
  OBJ_GLOBALMACROS                  = 1020001;

  //�����������
  AC_ACCOUNTANCY = 714000;
type
  TSecurityDescriptor = Integer;

implementation

end.
