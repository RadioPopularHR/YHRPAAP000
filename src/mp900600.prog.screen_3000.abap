PROCESS BEFORE OUTPUT.
*---------------------------------------------------------------------*
*       Setzt PFSTATUS und fuehrt Bildmodifikationen durch.           *
*---------------------------------------------------------------------*
  MODULE BEFORE_OUTPUT.
  CALL SUBSCREEN subscreen_empl INCLUDING empl_prog empl_dynnr.
  MODULE ASSIGN_TC3000.
  MODULE VARIATION_TC.
*---------------------------------------------------------------------*
*       Holt Infotypsaetze fuer die Anzeige.                          *
*---------------------------------------------------------------------*
  LOOP.
    MODULE PSLIST_TC.
*---------------------------------------------------------------------*
*       Infotypspezifischer Modul fuer Textanzeige.                   *
*---------------------------------------------------------------------*
    MODULE P9006L.
  ENDLOOP.
  CALL SUBSCREEN SUBSCREEN_HEADER INCLUDING HEADER_PROG HEADER_DYNNR.
*
PROCESS AFTER INPUT.
*---------------------------------------------------------------------*
*       Eingabe von 'E' im OK-Code                                    *
*---------------------------------------------------------------------*
  MODULE EXIT AT EXIT-COMMAND.
*---------------------------------------------------------------------*
*       Verarbeitung nach der Eingabe.                                *
*---------------------------------------------------------------------*
  LOOP.
    FIELD RP50M-SELE2 MODULE MARK ON REQUEST.
  ENDLOOP.
*---------------------------------------------------------------------*
*       Bei der Eingabe vom Gueltigkeitsintervall oder Infosubtyp     *
*       wird ein neuer Bereich zur Anzeige ausgewaehlt.               *
*---------------------------------------------------------------------*
  CALL SUBSCREEN subscreen_empl.
  CHAIN.
    FIELD RP50M-BEGDA.
    FIELD RP50M-ENDDA.
    FIELD RP50M-SUBTY.
    MODULE SELECT_FOR_LIST ON CHAIN-REQUEST.
  ENDCHAIN.
  FIELD RP50M-PAGEA ON REQUEST MODULE TOP_OF_LIST.
  MODULE ADJUST_LIST_TC.
*---------------------------------------------------------------------*
*       Allgemeine Funktionscodebearbeitung.                          *
*---------------------------------------------------------------------*
  MODULE POST_INPUT_CHECKS.
