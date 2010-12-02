
/****************************************************/
/****************************************************/
/**                                                **/
/**   Gedemin project                              **/
/**   Copyright (c) 1999-2000 by                   **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

INSERT INTO at_fields
  (fieldname, lname, description, reftable, reflistfield, refcondition, settable, setlistfield, setcondition,
   alignment, format, visible, colwidth, disabled, reserved)
VALUES (
  'DINTKEY',
  '�������������',
  '���������� �������������.',
  NULL, NULL, NULL,
  NULL, NULL, NULL,
  'R',
  NULL,
  0,
  8,
  0,
  NULL
);

INSERT INTO at_fields
  (fieldname, lname, description, reftable, reflistfield, refcondition, settable, setlistfield, setcondition,
   alignment, format, visible, colwidth, disabled, reserved)
VALUES (
  'DCURRENCY',
  '����� � ������',
  '����� � ������',
  NULL, NULL, NULL,
  NULL, NULL, NULL,
  'R',
  '#,##0.##',
  1,
  10,
  0,
  NULL
);

INSERT INTO at_fields
  (fieldname, lname, description, reftable, reflistfield, refcondition, settable, setlistfield, setcondition,
   alignment, format, visible, colwidth, disabled, reserved)
VALUES (
  'DALIAS',
  '������������',
  '�������� ������������',
  NULL, NULL, NULL,
  NULL, NULL, NULL,
  'L',
  '',
  1,
  8,
  0,
  NULL
);

COMMIT;

