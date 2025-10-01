*----------------------------------------------------------------------*
*                                                                      *
*       Output-modules for infotype 9007                               *
*                                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       MODULE  P9007 OUTPUT                                           *
*----------------------------------------------------------------------*
*       Default values, Texts                                          *
*----------------------------------------------------------------------*
MODULE P9007 OUTPUT.
  IF PSYST-NSELC EQ YES.
*
    IF NOT p9007-accao01 IS INITIAL.
      REFRESH wt_tc9007.
      DO 11 TIMES
        VARYING wt_tc9007-accao      FROM p9007-accao01      NEXT p9007-accao02
        VARYING wt_tc9007-entidade   FROM p9007-entid01      NEXT p9007-entid02
        VARYING wt_tc9007-data       FROM p9007-data01       NEXT p9007-data02.
        if not wt_tc9007-accao is INITIAL or not wt_tc9007-entidade is INITIAL.
          APPEND wt_tc9007.
        ENDIF.
      ENDDO.
    ENDIF.
* read text fields etc.; do this whenever the screen is show for the
*  first time:
*   PERFORM RExxxx.
    PERFORM output_p9007.
    IF PSYST-IINIT = YES AND PSYST-IOPER = INSERT.
* generate default values; do this the very first time on insert only:
*     PERFORM GET_DEFAULT.
    ENDIF.
  ENDIF.
ENDMODULE.
*----------------------------------------------------------------------*
*       MODULE  P9007L OUTPUT                                          *
*----------------------------------------------------------------------*
*       read texts for listscreen
*----------------------------------------------------------------------*
MODULE P9007L OUTPUT.
* PERFORM RExxxx.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC9007'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE TC9007_CHANGE_TC_ATTR OUTPUT.
*  DESCRIBE TABLE WT_TC9007 LINES TC9007-lines.
  TC9007-lines = 11.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  BEFORE_OUTPUT_TC  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module BEFORE_OUTPUT_TC output.

  PERFORM dynamic_variation_tc(sapfp50m) USING
                             psyst-dbild tc9007.

endmodule.                 " BEFORE_OUTPUT_TC  OUTPUT
