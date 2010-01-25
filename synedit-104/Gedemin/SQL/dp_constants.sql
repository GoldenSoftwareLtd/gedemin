/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    dp_Constants.sql

  Abstract

    An Interbase script with Constants for DEPARTMENT  system.

  Author

    Smirnov Anton (15.10.00)

  Revisions history

    Initial  15.10.00  SAI    Initial version

  Status

    Draft

*/


/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* ���������� */

INSERT INTO gd_subsystem(id, name, description, reserved)
  VALUES (49000, 'Department', '�����������', NULL);

COMMIT;

INSERT INTO gd_documenttype(id, name, description)
  VALUES (849000, '��������� ��� ������������', '��������� ��� ������������');

INSERT INTO gd_documenttype(id, parent, name, description)
  VALUES (849010, 849000, '��� ����� � ������', '��� ����� � ������');

/*INSERT INTO gd_documenttype(id, parent, name, description)
  VALUES (849020, 849000, '��� �������� ���������', '��� �������� ���������');*/

/*INSERT INTO gd_documenttype(id, parent, name, description)
  VALUES (849030, 849000, '��� ����������', '��� ����������');*/

INSERT INTO gd_documenttype(id, parent, name, description)
  VALUES (849040, 849000, '��� (��������) �������', '��� (��������) �������');

COMMIT;

/*
 * �������������
 */


INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    739500,
    730000,
    '��� ������������� ���������',
    'ref_assetdest',
    'TfrmAssetDest',
    NULL,
    0
  );

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    739510,
    730000,
    '�����, �������������',
    'ref_decree',
    'TfrmDecree',
    NULL,
    0
  );

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    799000,
    710000,
    '����',
    '',
    '',
    NULL,
    0
  );

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    799010,
    799000,
    '��� ����� � ������',
    'ref_inventory',
    'TfrmInventory',
    NULL,
    0
  );

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    799040,
    799000,
    '��� (��������) �������',
    'ref_withdrawal',
    'TfrmWithdrawal',
    NULL,
    0
  );

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    799050,
    799000,
    '���������� �������',
    'ref_paymentspec',
    'TfrmPaymentSpec',
    NULL,
    0
  );

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    751000,
    710000,
    '������ ��� ������������',
    'dp_report',
    'Tdp_frmReport',
    NULL,
    0
  );


COMMIT;


