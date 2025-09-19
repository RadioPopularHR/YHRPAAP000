PROCESS BEFORE OUTPUT.
*         general infotype-independent operations
  MODULE BEFORE_OUTPUT.
  CALL SUBSCREEN subscreen_empl   INCLUDING empl_prog empl_dynnr.
  CALL SUBSCREEN subscreen_header INCLUDING header_prog header_dynnr.
* Aqui vamos buscar um numero unico que será usado para ligar ao 2001
  MODULE DOCREF.
*         infotype specific operations
  MODULE P9006.
*
  MODULE FILL_2001.
*
  MODULE TC2001_INIT.
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC2001'
*  MODULE TC2001_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC2001_CHANGE_COL_ATTR.
  LOOP WITH CONTROL TC2001.
    MODULE P9006L.
    SELECT * FROM T554T WHERE SPRSL = SYST-LANGU
    AND   MOABW = T001P-MOABW
    AND   AWART = T_AUX2001-AWART
    INTO T554T
    WHENEVER NOT FOUND NO-MESSAGE.
    MODULE TEXTO.
*&SPWIZARD:   MODULE TC2001_CHANGE_FIELD_ATTR
  ENDLOOP.
*
  MODULE HIDDEN_DATA.
*
PROCESS AFTER INPUT.
*---------------------------------------------------------------------*
*  process exit commands
*---------------------------------------------------------------------*
  MODULE EXIT AT EXIT-COMMAND.
*---------------------------------------------------------------------*
*         processing after input
*---------------------------------------------------------------------*
*
*         check and mark if there was any input: all fields that
*         accept input HAVE TO BE listed here
*---------------------------------------------------------------------*
  CHAIN.
    FIELD P9006-BEGDA.
    FIELD P9006-ENDDA.
    FIELD P9006-DTOCO.
    FIELD P9006-OBSER.
    FIELD P9006-CLASS.
    MODULE INPUT_STATUS ON CHAIN-REQUEST.
  ENDCHAIN.
*---------------------------------------------------------------------*
*      process functioncodes before input-checks                      *
*---------------------------------------------------------------------*
  MODULE WARNING.
  MODULE PRE_INPUT_CHECKS.
  MODULE ENDDA.

  LOOP WITH CONTROL tc2001.                                 "XHBK034307
    CHAIN.
      FIELD: T_AUX2001-AWART, T_AUX2001-BEGDA, T_AUX2001-ENDDA.
      MODULE ADJUST_ENDDAS ON CHAIN-INPUT.                  "XHBK035317
*     MODULE ABSENCE ON CHAIN-INPUT.                         "QCSK101911
      MODULE ABSENCE ON CHAIN-REQUEST.                      "QCSK101911
    ENDCHAIN.
    FIELD T_AUX2001-AWART.
    SELECT * FROM T554V WHERE INFTY = P9006-INFTY
    AND   MOABW = T001P-MOABW
    AND   AWART = T_AUX2001-AWART
    AND   ENDDA = HIGH_DATE
    WHENEVER NOT FOUND NO-MESSAGE.
  ENDLOOP.
*---------------------------------------------------------------------*
*         input-checks:                                               *
*---------------------------------------------------------------------*

*   insert check modules here:

*  ...

*---------------------------------------------------------------------*
*     process function code: ALL fields that appear on the
*      screen HAVE TO BE listed here (including output-only fields)
*---------------------------------------------------------------------*
  CHAIN.
    FIELD P9006-BEGDA.
    FIELD P9006-ENDDA.
    FIELD RP50M-SPRTX.
    FIELD P9006-DTOCO.
    FIELD P9006-OBSER.
    FIELD P9006-CLASS.
    MODULE CHECK.
*    MODULE POST_INPUT_CHECKS.
    MODULE POST_CHECKS.
    MODULE MEASURE.
    MODULE ZFCODE.
  ENDCHAIN.
*
PROCESS ON VALUE-REQUEST.                                 "QCSK11K083237
  FIELD T_AUX2001-AWART MODULE SHOW_VALUES.
"QCSK11K083237
