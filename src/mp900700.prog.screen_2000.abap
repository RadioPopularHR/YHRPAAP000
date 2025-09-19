PROCESS BEFORE OUTPUT.
*         general infotype-independent operations
  MODULE BEFORE_OUTPUT.
  CALL SUBSCREEN subscreen_empl   INCLUDING empl_prog empl_dynnr.
  MODULE BEFORE_OUTPUT_TC.
  CALL SUBSCREEN subscreen_header INCLUDING header_prog header_dynnr.
*         infotype specific operations
  MODULE P9007.
*
  MODULE HIDDEN_DATA.
*
*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC9007'
  MODULE TC9007_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC9007_CHANGE_COL_ATTR.
  LOOP AT   WT_TC9007
       INTO WT_TC9007
       WITH CONTROL TC9007
       CURSOR TC9007-CURRENT_LINE.
*&SPWIZARD:   MODULE TC9007_CHANGE_FIELD_ATTR
  ENDLOOP.
*
PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC9007'
  LOOP AT WT_TC9007.
    CHAIN.
      FIELD WT_TC9007-ACCAO.
      FIELD WT_TC9007-ENTIDADE.
      FIELD WT_TC9007-DATA.
      MODULE TC9007_MODIFY ON CHAIN-REQUEST.
    endchain.
  ENDLOOP.
*&SPWIZARD: MODULE TC9007_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC9007_CHANGE_COL_ATTR.

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
    FIELD P9007-BEGDA.
    FIELD P9007-ENDDA.
    FIELD P9007-SUBTY.
    MODULE INPUT_STATUS ON CHAIN-REQUEST.
  ENDCHAIN.
*---------------------------------------------------------------------*
*      process functioncodes before input-checks                      *
*---------------------------------------------------------------------*
  MODULE PRE_INPUT_CHECKS.
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
    FIELD P9007-BEGDA.
    FIELD P9007-ENDDA.
    FIELD RP50M-SPRTX.
    FIELD P9007-SUBTY.
    FIELD T591S-STEXT.
    module VALORES_INFOTIPO.
    MODULE POST_INPUT_CHECKS.
  ENDCHAIN.
*



