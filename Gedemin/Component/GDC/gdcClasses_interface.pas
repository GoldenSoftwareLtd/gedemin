unit gdcClasses_interface;

interface

type
  TgdcDocumentClassPart = (
    dcpHeader,        // dcpHeader - шапка документа
    dcpLine           // dcpLine - позиция документа
  );

  TIsCheckNumber = (
    icnNever,         // не проверять уникальность номера
    icnAlways,        // проверять для всех документов
    icnYear,          // проверять только в течение года
    icnMonth          // проверять только в течение месяца
  );

implementation

end.