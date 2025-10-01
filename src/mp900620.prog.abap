*----------------------------------------------------------------------*
*                                                                      *
*       Output-modules for infotype 9006                               *
*                                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       MODULE  P9006 OUTPUT                                           *
*----------------------------------------------------------------------*
*       Default values, Texts                                          *
*----------------------------------------------------------------------*
MODULE p9006 OUTPUT.
  CLEAR: t591s-stext, t554d-wdgtx.
  IF save_objps CO ' 0' OR save_objps NE P9006-objps.
    MOVE: p9006-begda TO save_begda,
          p9006-endda TO save_endda,
          p9006-objps TO save_objps.
  ENDIF.
  IF psyst-nselc EQ yes.
* read text fields etc.; do this whenever the screen is show for the
*  first time:
   PERFORM P9006.
    IF psyst-iinit = yes AND psyst-ioper = insert.
* generate default values; do this the very first time on insert only:
*     PERFORM GET_DEFAULT.
    ENDIF.
  ENDIF.

  PERFORM buscar_textos.
  ILINE_INDEX = 1.
  REFRESH ISCREEN.
  CLEAR   ISCREEN.
ENDMODULE.                    "P9006 OUTPUT
*----------------------------------------------------------------------*
*       MODULE  P9006L OUTPUT                                          *
*----------------------------------------------------------------------*
*       read texts for listscreen
*----------------------------------------------------------------------*
MODULE p9006l OUTPUT.
* PERFORM RExxxx.
  PERFORM LINE.
ENDMODULE.                    "P9006L OUTPUT
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_TEXTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM buscar_textos .

  IF NOT p9006-class IS INITIAL.

    SELECT SINGLE classdesc INTO ythr00001-classdesc FROM ythr00001
      WHERE
        class = p9006-class.
    IF sy-subrc <> 0.
      CLEAR ythr00001-classdesc.
    ENDIF.
  ELSE.
    CLEAR ythr00001-classdesc.
  ENDIF.

ENDFORM.                    " BUSCAR_TEXTOS

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC2001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc2001_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_aux2001 LINES tc2001-lines.
ENDMODULE.                    "TC2001_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC2001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc2001_get_lines OUTPUT.
  g_tc2001_lines = sy-loopc.
ENDMODULE.                    "TC2001_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DOCREF  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE docref OUTPUT.

  IF psyst-ioper = 'INS'.
    CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object = 'YHR0000001'
      quantity = '1'
     IMPORTING
         number = p9006-docref
*       quantity = ' '
*       RETURNCODE =
     EXCEPTIONS
       interval_not_found = 1
       number_range_not_intern = 2
       object_not_found = 3
       quantity_is_0 = 4
       quantity_is_not_1 = 5
       interval_overflow = 6
     OTHERS = 7.
    IF sy-subrc <> 0.
      MESSAGE e000(zfs) WITH 'Erro no intervalo de numeração YHR0000001'.
    ENDIF.

  ENDIF.

ENDMODULE.                 " DOCREF  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_2001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module FILL_2001 output.

  IF NOT p9006-begda IS INITIAL AND
  psyst-ioper EQ 'INS' AND
  psyst-iinit EQ 1.
    PERFORM fill.
  endif.

endmodule.                 " FILL_2001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC2001_INIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TC2001_INIT output.

  perform dynamic_variation_tc(sapfp50m)
    using psyst-dbild tc2001.
  describe table iline lines tc2001-lines.
  tc2001-lines = tc2001-lines + 15.

endmodule.                 " TC2001_INIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXTO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module TEXTO output.

  IF NOT T_AUX2001-AWART IS INITIAL.
    T_AUX2001-ATEXT = T554T-ATEXT.
  endif.

endmodule.                 " TEXTO  OUTPUT
