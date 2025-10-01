*----------------------------------------------------------------------*
*                                                                      *
*       Input-modules for infotype 9006                                *
*                                                                      *
*----------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'TC2001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC2001_MODIFY INPUT.
  MODIFY T_AUX2001
    FROM T_AUX2001
    INDEX TC2001-CURRENT_LINE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC2001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE TC2001_USER_COMMAND INPUT.
  FCODE = SY-UCOMM.
  PERFORM USER_OK_TC USING    'TC2001'
                              'T_AUX2001'
                              ' '
                     CHANGING FCODE.
  SY-UCOMM = FCODE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SHOW_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module SHOW_VALUES input.

  PERFORM SHOW_VALUES USING T001P-MOABW PSPAR-INFTY.

endmodule.                 " SHOW_VALUES  INPUT
*&---------------------------------------------------------------------*
*&      Module  POST_CHECKS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module POST_CHECKS input.
* PERFORM XTOC(SAPFP50M) USING SY-DYNNR AKT_DYNNR.               "K80009
  MOVE SY-DYNNR TO AKT_DYNNR.                                    "K80009
  IF AKT_DYNNR(1) EQ T582A-EDYNR(1).                       "Einzelbild
    PERFORM POST_INPUT_EDYNR.       " form ABPER, form UPDATE_BUFFER
*   PERFORM FCODE_EDYNR.            " Fcode SAVE, LIST,BACK,LEAVE,DSYS
*   PERFORM END_OF_SCREEN.          " Dyn.Massn., naechstes Bild
  ELSE.
    PERFORM FCODE(SAPFP50M).                                "Listbild
  ENDIF.
endmodule.                 " POST_CHECKS  INPUT
*&---------------------------------------------------------------------*
*&      Module  WARNING  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module WARNING input.

  PERFORM WARNING USING FCODE
                        PSYST-IOPER.

endmodule.                 " WARNING  INPUT
*&---------------------------------------------------------------------*
*&      Module  ADJUST_ENDDAS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module ADJUST_ENDDAS input.

  IF T_AUX2001-BEGDA IS INITIAL or T_AUX2001-ENDDA IS INITIAL.
    message E239(PG).
  endif.
  IF T_AUX2001-ENDDA > P9006-ENDDA.
    MESSAGE I204(PG) WITH T_AUX2001-BEGDA T_AUX2001-ENDDA.
*    T_AUX2001-ENDDA = P9006-ENDDA.
    PERFORM ABSENCE USING P2001-AWART
          T_AUX2001-BEGDA
          T_AUX2001-ENDDA
          P9006
          T001P-MOABW
          MAN
          YES.
    PERFORM MANIPULATE USING T_AUX2001-AWART
          T_AUX2001-BEGDA
          T_AUX2001-ENDDA
          SY-STEPL
          P9006
          T001P-MOABW.
    PERFORM OVERLAP USING SY-STEPL
          T_AUX2001-AWART
          T_AUX2001-BEGDA
          T_AUX2001-ENDDA.
  ENDIF.

endmodule.                 " ADJUST_ENDDAS  INPUT
*&---------------------------------------------------------------------*
*&      Module  ABSENCE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module ABSENCE input.

  PERFORM ABSENCE USING T_AUX2001-AWART
        T_AUX2001-BEGDA
        T_AUX2001-ENDDA
        P9006
        T001P-MOABW
        MAN
        YES.
  PERFORM MANIPULATE USING T_AUX2001-AWART
        T_AUX2001-BEGDA
        T_AUX2001-ENDDA
        SY-STEPL
        P9006
        T001P-MOABW.
  PERFORM OVERLAP USING SY-STEPL
        T_AUX2001-AWART
        T_AUX2001-BEGDA
        T_AUX2001-ENDDA.

endmodule.                 " ABSENCE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module CHECK input.

  PERFORM CHECK USING FCODE.

endmodule.                 " CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  MEASURE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module MEASURE input.

  DATA: MEA_ACTIO LIKE PSPAR-ACTIO.
  CHECK FCODE EQ SAVE.
  CLEAR                    PSPAR-ACTIO.
  MOVE PSPAR-ACTIO      TO MEA_ACTIO.   "Merken PSPAR-ACTIO
  MOVE 'MOD '           TO PSPAR-ACTIO. "Aendern
  MOVE NO               TO PSYST-DINIT. "Keine neue Initiali.
  IMPORT LAST_DMSNR FROM MEMORY ID 'LAST_DMSNR'.            "XLCK048406
  CASE PSYST-FSTAT.
  WHEN FCODE_HZ.
    PERFORM INSERT_2001.
  WHEN FCODE_AE.
    PERFORM MODIFY_2001.
  WHEN FCODE_LO.
    PERFORM DELETE_2001.
  ENDCASE.
  EXPORT LAST_DMSNR TO MEMORY ID 'LAST_DMSNR'.              "XLCK048406
  READ TABLE DYNMEAS INDEX 1.
  MOVE YES              TO SW_FROM_0080_0081.               "XQPK008952
  PERFORM PROCESS_MEASURE(SAPFP50M).
  MOVE NO               TO SW_FROM_0080_0081.               "XQPK008952
  MOVE MEA_ACTIO        TO PSPAR-ACTIO.
  CASE PSYST-FSTAT.                                       "QCSK11K090539
  WHEN FCODE_HZ.                                        "QCSK11K090539
    PSPAR-MSGNR = '102'.                                "QCSK11K090539
  WHEN FCODE_AE.                                        "QCSK11K090539
    LOOP AT ILINE WHERE OPERA NE SPACE.                 "QCSK11K090539
      EXIT.                                             "QCSK11K090539
    ENDLOOP.                                            "QCSK11K090539
    IF SY-SUBRC EQ 0.                                   "QCSK11K090539
      PSPAR-MSGNR = '103'.                              "QCSK11K090539
    ENDIF.                                              "QCSK11K090539
  WHEN FCODE_LO.                                        "QCSK11K090539
    PSPAR-MSGNR = '104'.                                "QCSK11K090539
  ENDCASE.

endmodule.                 " MEASURE  INPUT
*&---------------------------------------------------------------------*
*&      Module  ZFCODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module ZFCODE input.
    PERFORM FCODE_EDYNR.            " Fcode SAVE, LIST,BACK,LEAVE,DSYS
    PERFORM END_OF_SCREEN.
endmodule.                 " ZFCODE  INPUT
