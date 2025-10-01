*----------------------------------------------------------------------*
*                                                                      *
*       Subroutines for infotype 9006                                  *
*                                                                      *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: l_ok              TYPE sy-ucomm,
         l_offset          TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = STRLEN( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

     WHEN 'DELE'.                      "delete row
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
   ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE l_selline.
   IF sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
     IF l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     ELSE.
       <tc>-top_line = 1.
     ENDIF.
   ELSE.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <table> INDEX l_selline.
   <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE l_line.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name
                        p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <table> LINES <tc>-lines.

   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     IF <mark_field> = 'X'.
       DELETE <table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <tc>-lines = <tc>-lines - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_tc_new_top_line     TYPE i.
   DATA l_tc_name             LIKE feld-name.
   DATA l_tc_lines_name       LIKE feld-name.
   DATA l_tc_field_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
   ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
   IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
     l_tc_new_top_line = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
               entry_act             = <tc>-top_line
               entry_from            = 1
               entry_to              = <tc>-lines
               last_page_full        = 'X'
               loops                 = <lines>
               ok_code               = p_ok
               overlapping           = 'X'
          IMPORTING
               entry_new             = l_tc_new_top_line
          EXCEPTIONS
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
               OTHERS                = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD l_tc_field_name
              AREA  l_tc_name.

   IF syst-subrc = 0.
     IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD l_tc_field_name LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <tc>-top_line = l_tc_new_top_line.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_mark_lines USING p_tc_name
                                p_table_name
                                p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_demark_lines USING p_tc_name
                                  p_table_name
                                  p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = space.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  P9006
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM p9006 .

   LOCAL: pskey.
   DATA: p00_count TYPE p,
         p00_objps LIKE p9006-objps.
   DATA: w_9006 TYPE pa9006.

   IF p9006-begda CO ' '.
     p9006-begda = '18000101'.
   ENDIF.
   psyst-msgtp = 'S'.
   IF psyst-fstat EQ fcode_hz OR
   psyst-fstat EQ fcode_hv.
     MOVE: p9006-begda TO *p9006-begda, "Sichern von BEGDA und ENDDA
     p9006-endda TO *p9006-endda. "wenn OBJPS neu ermittelt wird
     PERFORM get_objid USING p9006-pernr
           p00_objps
           p9006-infty
           p9006-subty.
     MOVE p00_objps TO p9006-objps.
     IF psyst-ioper NE copy.
*      CLEAR: P0081-WDEIN, P0081-WDGRD.
     ENDIF.
     MOVE: *p9006-begda TO p9006-begda, "Zurueckladen der Datuemer aus
     *p9006-endda TO p9006-endda. "der *-Struktur
   ENDIF.
   REFRESH: iline.
   CLEAR  : iline, p00_count.
   PERFORM read_infotype(sapfp50p) USING p9006-pernr
         absence
         space
         space
         no_sprps
         p9006-begda
         p9006-endda
         all
         nop
         p2001.
   CLEAR seltab.
   SORT seltab BY begda.
   LOOP AT seltab.
     p2001 = cl_pt_container_util=>prelp_to_p2001( seltab-prelp ).
*    CHECK P2001-AINFT EQ PSPAR-INFTY AND
*          P2001-OBJPS EQ P9127-OBJPS.
     CHECK p2001-ainft EQ pspar-infty AND psyst-ioper <> 'INS'.
* Verificamos se existe ligação
*     select single * from ythr00018
*       WHERE
*         pernr      = P9127-pernr AND
*         begda_9127 = P9127-begda and
*         BEGDA_2001 = p2001-begda and
*         ENDDA_2001 = p2001-ENDDA.
*     check sy-subrc = 0.
     CHECK p2001-refnr = p9006-docref.
     MOVE-CORRESPONDING p2001 TO iline.
     APPEND iline.
   ENDLOOP.
   IF p00_count NE 0.
     PERFORM clear_psindex(sapfp50p).
   ENDIF.

 ENDFORM.                                                   " P9006
*&---------------------------------------------------------------------*
*&      Form  GET_OBJID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P9006_PERNR  text
*      -->P_P00_OBJPS  text
*      -->P_P9006_INFTY  text
*      -->P_P9006_SUBTY  text
*----------------------------------------------------------------------*
 FORM get_objid  USING get_pernr get_objps get_infty get_subty.
   DATA: get_high  TYPE p.
   LOCAL: p9006.
   CLEAR: get_objps.
   PERFORM read_infotype(sapfp50p) USING get_pernr
         get_infty
         get_subty
         space
         yes_sprps
         low_date
         high_date
         all
         nop
         p9006.
   get_high = 0.
   CLEAR seltab.
   LOOP AT seltab.
*   MOVE SELTAB TO P0081.                                      "XHB-UNI
     p9006 = cl_pt_container_util=>prelp_to_p9006( seltab-prelp ).
     IF p9006-objps GT get_high.                          "#EC PORTABLE
       MOVE p9006-objps TO get_high.
     ENDIF.
   ENDLOOP.
   ADD  1          TO get_high.
   UNPACK get_high TO get_objps.
   TRANSLATE get_objps USING ' 0'.

 ENDFORM.                    " GET_OBJID
*&---------------------------------------------------------------------*
*&      Form  FILL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM fill .

   LOOP AT iline WHERE opera EQ opera-insert.
     EXIT.
   ENDLOOP.
   IF sy-subrc NE 0.
     LOOP AT iline WHERE opera EQ opera-noopera.
       EXIT.
     ENDLOOP.
   ENDIF.
   CHECK sy-subrc NE 0.
   SELECT * FROM t554v WHERE infty EQ pspar-infty
   AND   moabw EQ t001p-moabw
   AND   begda LE p9006-begda
   AND   endda GE p9006-endda
   AND   auswa EQ active ORDER BY PRIMARY KEY.
     PERFORM re554s USING t001p-moabw   "Pruefe ob AWART am Beginndatum
           t554v-awart   "gueltig ist
           p9006-begda
           p9006-begda.
     IF sy-subrc EQ 0.
       MOVE-CORRESPONDING t554v TO iline.
       MOVE absence             TO iline-infty.
       MOVE t554v-awart         TO iline-subty.
*       CLEAR: ILINE-BEGDA,
*       ILINE-ENDDA.
       MOVE insert TO iline-opera.
       CLEAR : iline-begda, iline-endda.
*       ILINE-BEGDA = P9006-BEGDA.
*       ILINE-ENDDA = P9006-BEGDA.
       APPEND iline.
     ENDIF.
   ENDSELECT.
   CLEAR iline.

 ENDFORM.                    " FILL
*&---------------------------------------------------------------------*
*&      Form  RE554S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T001P_MOABW  text
*      -->P_T554V_AWART  text
*      -->P_P9006_BEGDA  text
*      -->P_P9006_BEGDA  text
*----------------------------------------------------------------------*
 FORM re554s USING 554s_moabw 554s_subty 554s_begda 554s_endda.

   SELECT * FROM t554s
     WHERE moabw EQ 554s_moabw AND
           subty EQ 554s_subty AND
           begda LE 554s_endda AND
           endda GE 554s_begda
   ORDER BY PRIMARY KEY.
   ENDSELECT.

 ENDFORM.                                                   " RE554S
*&---------------------------------------------------------------------*
*&      Form  LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM line .

   CLEAR: t_aux2001, iline.
   MOVE space TO t_aux2001-awart.
   iline_index = tc2001-current_line.
   READ TABLE iline INDEX iline_index.
   ADD 1 TO iline_index.
   WHILE sy-subrc    EQ 0 AND
   iline-opera EQ opera-delete.
     READ TABLE iline INDEX iline_index.
     ADD 1 TO iline_index.
   ENDWHILE.
   CHECK iline-opera NE opera-delete.
   MOVE-CORRESPONDING iline TO t_aux2001.
   MOVE-CORRESPONDING iline TO iscreen.
   MOVE iline-subty         TO t_aux2001-awart.
   APPEND iscreen.
   CLEAR t554t.
   IF t_aux2001-begda LT p9006-begda AND "Abwesenheit liegt vor Beginndatum
   t_aux2001-begda CN ' 0'.
     MESSAGE s447.                                          "QCSK101707
     MOVE t_aux2001-begda TO p9006-begda.   "veraendere Beginndatum
     PERFORM check_0007 USING p9006-pernr
           p9006-begda
           p9006-endda.
   ENDIF.
   IF t_aux2001-endda GT p9006-endda AND    "Abwesenheit endet nach Endedatum
   t_aux2001-endda CN ' 0'.
     MESSAGE s447.                                          "QCSK101707
     MOVE t_aux2001-endda TO p9006-endda.   "veraendere Endedatum
     PERFORM check_0007 USING p9006-pernr
           p9006-endda
           p9006-endda.
   ENDIF.
   IF psyst-ioper EQ delete OR fcode EQ delete.
     MOVE: save_begda TO p9006-begda,
     save_endda TO p9006-endda.
   ENDIF.

 ENDFORM.                    " LINE
*&---------------------------------------------------------------------*
*&      Form  CHECK_0007
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P9006_PERNR  text
*      -->P_P9006_BEGDA  text
*      -->P_P9006_ENDDA  text
*----------------------------------------------------------------------*
 FORM check_0007 USING ch7_pernr ch7_begda ch7_endda.
   PERFORM read_infotype(sapfp50p) USING ch7_pernr          "QNU181290
         infty_0007
         space
         space
         no_sprps
         ch7_begda
         ch7_endda
         first
         nop
         p0007.
   IF sy-subrc NE 0.
     MESSAGE s414 WITH infty_0007 ch7_begda ch7_endda.
   ENDIF.
 ENDFORM.                    " CHECK_0007
*&---------------------------------------------------------------------*
*&      Form  SHOW_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T001P_MOABW  text
*      -->P_PSPAR_INFTY  text
*----------------------------------------------------------------------*
 FORM show_values  USING sv_moabw sv_infty.
   DATA: BEGIN OF i_help_value OCCURS 4.                   "QCSK11K083237
           INCLUDE STRUCTURE help_value.                   "QCSK11K083237
   DATA: END OF i_help_value.                              "QCSK11K083237
   DATA: BEGIN OF i_valuetab OCCURS 20,                    "QCSK11K083237
     line(30),                                       "QCSK11K083237
   END OF i_valuetab.                                "QCSK11K083237
* Struktur des Helpviews                                  "QCSK11K083237
   i_help_value-tabname = 'T554V'.                         "QCSK11K083237
   i_help_value-fieldname = 'MOABW'.                       "QCSK11K083237
   i_help_value-selectflag = space.                        "QCSK11K083237
   APPEND i_help_value.                                    "QCSK11K083237
   i_help_value-tabname = 'T554V'.                         "QCSK11K083237
   i_help_value-fieldname = 'AWART'.                       "QCSK11K083237
   i_help_value-selectflag = 'X'.                          "QCSK11K083237
   APPEND i_help_value.                                    "QCSK11K083237
   i_help_value-tabname = 'T554T'.                         "QCSK11K083237
   i_help_value-fieldname = 'ATEXT'.                       "QCSK11K083237
   i_help_value-selectflag = space.                        "QCSK11K083237
   APPEND i_help_value.                                    "QCSK11K083237
   REFRESH i_valuetab.                                     "QCSK11K083237
* Inhalt des angezeigten Helpviews                        "QCSK11K083237
   SELECT * FROM t554v                                     "QCSK11K083237
   WHERE  moabw EQ sv_moabw                         "QCSK11K083237
   AND    infty EQ sv_infty.                        "QCSK11K083237
     i_valuetab = t554v-moabw.                             "QCSK11K083237
     APPEND i_valuetab.                                    "QCSK11K083237
     i_valuetab = t554v-awart.                             "QCSK11K083237
     APPEND i_valuetab.                                    "QCSK11K083237
     SELECT SINGLE * FROM t554t                            "QCSK11K083237
     WHERE  sprsl EQ sy-langu                       "QCSK11K083237
     AND    moabw EQ t554v-moabw                    "QCSK11K083237
     AND    awart EQ t554v-awart.                   "QCSK11K083237
     i_valuetab = t554t-atext.                             "QCSK11K083237
     APPEND i_valuetab.                                    "QCSK11K083237
   ENDSELECT.                                              "QCSK11K083237
* dynamischer Aufbau des Helpviews                        "QCSK11K083237
   CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'              "QCSK11K083237
   EXPORTING                                          "QCSK11K083237
     fieldname                 = 'AWART'           "QCSK11K083237
     tabname                   = 'T554V'           "QCSK11K083237
   IMPORTING                                          "QCSK11K083237
     select_value              = t_aux2001-awart       "QCSK11K083237
   TABLES                                             "QCSK11K083237
     fields                    = i_help_value      "QCSK11K083237
     valuetab                  = i_valuetab.       "QCSK11K083237
 ENDFORM.                    " SHOW_VALUES
*&---------------------------------------------------------------------*
*&      Form  CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FCODE  text
*----------------------------------------------------------------------*
 FORM check  USING    p_fcode.
   CHECK fcode       EQ save AND
   psyst-ioper NE delete.
   LOOP AT iline.
     IF iline-subty CN ' 0'.
       IF iline-begda CO ' 0' OR
       iline-endda CO ' 0'.
         CLEAR fcode.
         MESSAGE i442 WITH iline-subty.
       ENDIF.
     ENDIF.
   ENDLOOP.
   LOOP AT iline.
     CHECK iline-opera NE 'D'.                              "XHBK035317
     IF iline-begda LT p9006-begda AND
     iline-begda CN ' 0'.
       MOVE iline-begda TO p9006-begda.
     ENDIF.
     IF iline-endda GT p9006-endda AND
     iline-endda CN ' 0'.
       MOVE iline-endda TO p9006-endda.
     ENDIF.
   ENDLOOP.
 ENDFORM.                    " CHECK
*&---------------------------------------------------------------------*
*&      Form  WARNING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FCODE  text
*      -->P_PSYST_IOPER  text
*----------------------------------------------------------------------*
 FORM warning  USING war_fcode war_ioper.
   DATA: war_help_fcode(4),
         war_found         VALUE '0'.
   MOVE war_fcode TO war_help_fcode.
   CHECK war_help_fcode+0(3) EQ 'LIS'.
   CHECK war_ioper           NE display.
   MOVE no TO war_found.
   LOOP AT iline.
     IF iline-subty CN ' 0' AND
     iline-begda CN ' 0' AND
     iline-endda CN ' 0'.
       war_found = yes.
       EXIT.
     ENDIF.
   ENDLOOP.
   IF war_found EQ yes.
     MESSAGE w443.
   ENDIF.
 ENDFORM.                    " WARNING
*&---------------------------------------------------------------------*
*&      Module  ENDDA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 MODULE endda INPUT.

   IF psyst-ioper = 'INS' AND p9006-endda IS INITIAL.
     MOVE '99991231' TO p9006-endda.
   ENDIF.

 ENDMODULE.                 " ENDDA  INPUT
*&---------------------------------------------------------------------*
*&      Form  ABSENCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P2001_AWART  text
*      -->P_P2001_BEGDA  text
*      -->P_P2001_ENDDA  text
*      -->P_P9006  text
*      -->P_T001P_MOABW  text
*      -->P_MAN  text
*      -->P_YES  text
*----------------------------------------------------------------------*
 FORM absence  USING abs_awart abs_begda abs_endda abs_p9006 abs_moabw
       abs_gesch abs_mark.
   LOCAL: p9006.
   DATA:  abs_endda1   LIKE p9006-endda,
         abs_accident LIKE p9006-infty VALUE '9006'.
   IF abs_awart NE space.
*** Wird eine Abwesenheit manuell erfasst, dann darf diese Abw.
*** nicht noch zusaetzlich vorgeschlagen werden. Dies wird hier
*** abgefangen
     LOOP AT iline WHERE subty EQ abs_awart
     AND   opera EQ opera-insert.
       IF iline-begda CO ' 0' OR
       iline-endda CO  '0'.
         DELETE iline.
       ENDIF.
     ENDLOOP.
   ENDIF.
   IF abs_awart NE space.
     IF abs_begda CO ' 0' OR
     abs_endda CO ' 0'.
       MESSAGE w446 WITH abs_awart.
     ENDIF.
   ENDIF.
   CHECK abs_awart NE space AND
   abs_begda CN ' 0'  AND
   abs_endda CN ' 0'.
   IF abs_begda GT abs_endda.
     MESSAGE e421 WITH abs_begda abs_awart abs_endda.
   ENDIF.
   IF abs_p9006 EQ space.
     CLEAR p9006.
   ELSE.
     MOVE abs_p9006 TO p9006.
   ENDIF.
*** Pruefe gegen Tabelle T554V mit Beginndatum
   PERFORM re554v USING abs_accident
         abs_moabw
         abs_awart
         abs_begda
         abs_begda.
   IF sy-subrc NE 0.
     LOOP AT iline.
       CHECK iline-subty CN ' 0'.
       CHECK iline-begda CO ' 0' OR
       iline-endda CO ' 0'.
       DELETE iline.
     ENDLOOP.
     CLEAR: atab_arg, t554v.
     MOVE abs_accident TO t554v-infty.
     MOVE abs_moabw    TO t554v-moabw.
     MOVE abs_awart    TO t554v-awart.
     MOVE abs_begda    TO t554v-endda.
     MOVE t554v        TO atab_arg.
     CLEAR: t554v.
     MESSAGE e410 WITH 'T554V' atab_arg.
   ENDIF.
 ENDFORM.                    " ABSENCE
*&---------------------------------------------------------------------*
*&      Form  MANIPULATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P2001_AWART  text
*      -->P_P2001_BEGDA  text
*      -->P_P2001_ENDDA  text
*      -->P_SY_STEPL  text
*      -->P_P9006  text
*      -->P_T001P_MOABW  text
*----------------------------------------------------------------------*
 FORM manipulate  USING man_subty man_begda man_endda man_index
       man_p9006 man_moabw.
   LOCAL: p9006.
   MOVE man_p9006 TO p9006.
   READ TABLE iscreen INDEX man_index.  "Lese passenden Eintrag
   IF sy-subrc EQ 0.
     CHECK iscreen-subty NE man_subty OR"Liegt Aenderung vor
     iscreen-begda NE man_begda OR
     iscreen-endda NE man_endda.
     IF <psave> EQ <pnnnn>.
       MOVE <psave> TO *p9006.      "Aenderung bei Abwesenheiten erfasst,
       IF *p9006-uname+0(1) NE '1'. "damit das System feststellt, dass
         MOVE '1' TO *p9006-uname+0(1). "eine Aenderung erfolgt ist,
       ELSE.                            "wird <PSAVE> manipuliert.
         MOVE '2' TO *p9006-uname+0(1).
       ENDIF.
       MOVE *p9006 TO <psave>.
       CLEAR *p9006.
     ENDIF.
     LOOP AT iline WHERE subty EQ iscreen-subty  "Lese alten
     AND   begda EQ iscreen-begda  "Eintrag
     AND   endda EQ iscreen-endda.
       IF iline-opera EQ opera-noopera.
         MOVE opera-delete TO iline-opera."Alte Abwesenheitsart loeschen
         MODIFY iline.
         EXIT.
       ELSE.
         IF iline-opera NE opera-delete."Satz mit OPERA = INSERT wird
           DELETE iline.                "aus ILINE geloescht
           EXIT.
         ENDIF.
       ENDIF.
     ENDLOOP.
     CHECK man_subty NE space AND "Nur wenn alle 3 Felder nicht initial
     man_begda CN ' 0'  AND       "sind, wird ein neuer Satz in der
     man_endda CN ' 0'.           "ILINE hinzugefuegt
     MOVE: man_subty    TO iline-subty,
     man_begda    TO iline-begda,
     man_endda    TO iline-endda,
     absence      TO iline-infty,
     p9006-objps  TO iline-objps,
     opera-insert TO iline-opera.
     APPEND iline.                      "Fuelle ILINE mit neuem Satz
     psyst-inpst = input_done.          "Input-Status auf erfolgte Eing.
     READ TABLE iscreen INDEX man_index."Lese passenden Eintrag
     MOVE: man_subty TO iscreen-subty,  "Fuelle den neuen Eintrag in
     man_begda TO iscreen-begda,  "Tabelle ISCREEN
     man_endda TO iscreen-endda.
     MODIFY iscreen INDEX man_index.
   ENDIF.
 ENDFORM.                    " MANIPULATE
*&---------------------------------------------------------------------*
*&      Form  OVERLAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_STEPL  text
*      -->P_P2001_AWART  text
*      -->P_P2001_BEGDA  text
*      -->P_P2001_ENDDA  text
*----------------------------------------------------------------------*
 FORM overlap USING ove_index ove_awart ove_begda ove_endda.
   DATA: ove_num TYPE p.
   CLEAR ove_num.
   CHECK ove_awart CN ' 0'.
   READ TABLE iscreen INDEX ove_index.  "Hole alten Eintrag aus ISCREEN
   IF iscreen-subty CN ' 0'.
     LOOP AT iline.                     "Bearbeite seq. ILINE
       CHECK iline-opera EQ opera-noopera OR "Wenn ILINE-Satz am BS
       iline-opera EQ opera-insert.    "angezeigt wird ('I'/' ').
       IF iline-subty EQ iscreen-subty AND
       iline-begda EQ iscreen-begda AND
       iline-endda EQ iscreen-endda.
         ADD 1 TO ove_num.
       ENDIF.
       CHECK iline-subty NE iscreen-subty OR
       iline-begda NE iscreen-begda OR
       iline-endda NE iscreen-endda.
       IF iline-begda LE ove_endda AND
       iline-endda GE ove_begda.
         MESSAGE w422 WITH ove_awart iline-subty iline-begda iline-endda.
       ENDIF.
     ENDLOOP.
     IF ove_num GT 1.
       MESSAGE w422 WITH ove_awart ove_awart ove_begda ove_endda.
     ENDIF.
   ENDIF.
 ENDFORM.                    " OVERLAP
*&---------------------------------------------------------------------*
*&      Form  RE554V
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ABS_ACCIDENT  text
*      -->P_ABS_MOABW  text
*      -->P_ABS_AWART  text
*      -->P_ABS_BEGDA  text
*      -->P_ABS_BEGDA  text
*----------------------------------------------------------------------*
 FORM re554v USING 554v_infty 554v_moabw 554v_awart 554v_begda
       554v_endda.
   SELECT * FROM t554v WHERE infty EQ 554v_infty
   AND   moabw EQ 554v_moabw
   AND   awart EQ 554v_awart
   AND   begda LE 554v_endda
   AND   endda GE 554v_begda ORDER BY PRIMARY KEY.
     EXIT.
   ENDSELECT.
 ENDFORM.                                                   " RE554V
*&---------------------------------------------------------------------*
*&      Form  INSERT_2001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form INSERT_2001 .

   SORT ILINE BY OPERA SUBTY ASCENDING.
   CLEAR ILINE.
   LOOP AT ILINE.
     CLEAR DYNMEAS.
     CHECK ILINE-OPERA EQ OPERA-INSERT.
     ADD  1                   TO LAST_DMSNR.                "XLCK048406
     MOVE-CORRESPONDING ILINE TO DYNMEAS.
     MOVE INSERT              TO DYNMEAS-ACTIO.
     MOVE SUPRESS             TO DYNMEAS-SUPDG.
*   MOVE SY-TABIX            TO DYNMEAS-SEQNR.              "XLCK048406
     MOVE LAST_DMSNR          TO DYNMEAS-SEQNR.             "XLCK048406
     APPEND DYNMEAS.
     PERFORM APPEND_INITIAL_VALUES USING LAST_DMSNR 'INS'.  "XLCK048406
* Apagar registo na tabela de ligação
*     PERFORM operacao_0018 USING
*           'INS' p9006-pernr p9006-begda iline-begda iline-endda.
   ENDLOOP.
endform.                    " INSERT_2001
*&---------------------------------------------------------------------*
*&      Form  APPEND_INITIAL_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LAST_DMSNR  text
*      -->P_1809   text
*----------------------------------------------------------------------*
form APPEND_INITIAL_VALUES  USING AIV_NUM OPER.

   CLEAR initial_values.                                    "Note 373249
   MOVE AIV_NUM       TO INITIAL_VALUES-SEQNR.
   MOVE 'P2001-AINFT' TO INITIAL_VALUES-FIELD_NAME.
   MOVE PSPAR-INFTY   TO INITIAL_VALUES-FIELD_VALUE.
   APPEND INITIAL_VALUES.

   CLEAR initial_values.                                    "Note 373249
   MOVE AIV_NUM       TO INITIAL_VALUES-SEQNR.
   MOVE 'P2001-REFNR' TO INITIAL_VALUES-FIELD_NAME.
   MOVE P9006-DOCREF  TO INITIAL_VALUES-FIELD_VALUE.
   APPEND INITIAL_VALUES.

endform.                    " APPEND_INITIAL_VALUES
*&---------------------------------------------------------------------*
*&      Form  MODIFY_2001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form MODIFY_2001 .

   DATA: MOD_INDEX LIKE SY-INDEX.
   DATA: BEGIN OF MOD_LINE,
     SUBTY LIKE P0081-SUBTY,
     BEGDA LIKE P0081-BEGDA,
     ENDDA LIKE P0081-ENDDA,
   END OF MOD_LINE.
* PERFORM FILL_INITIAL_VALUES.                              "XLCK048406
   SORT ILINE BY OPERA SUBTY ASCENDING.
   MOVE 1 TO MOD_INDEX.                 "Initialisiere Index
   READ TABLE ILINE INDEX MOD_INDEX.    "Lese ersten Tabelleneintrag
   WHILE SY-SUBRC EQ 0.                 "Solange ein Satz gefunden wird
     IF ILINE-OPERA EQ OPERA-DELETE.    "Wenn der Satz zu loeschen ist
       MOVE ILINE-SUBTY  TO MOD_LINE-SUBTY. "Merke Argumente des Satzes
       MOVE ILINE-BEGDA  TO MOD_LINE-BEGDA.
       MOVE ILINE-ENDDA  TO MOD_LINE-ENDDA.
       LOOP AT ILINE WHERE INFTY EQ ABSENCE       "Untersuche, ob
       AND   SUBTY EQ MOD_LINE-SUBTY "es einen Satz
       AND   BEGDA EQ MOD_LINE-BEGDA "mit gleichem
       AND   ENDDA EQ MOD_LINE-ENDDA "Key und Opera
       AND   OPERA EQ OPERA-INSERT."insert gibt
         DELETE ILINE.                  "Loesche diesen Eintrag
       ENDLOOP.
       IF SY-SUBRC EQ 0.                "Hat einen Eintrag gefunden
         READ TABLE ILINE INDEX MOD_INDEX.  "Lese Eintrag mit DELETE
         MOVE OPERA-NOOPERA TO ILINE-OPERA. "Setze Eintrag auf NOOPERA
         MODIFY ILINE INDEX MOD_INDEX.
       ENDIF.
     ENDIF.
     ADD 1 TO MOD_INDEX.
     READ TABLE ILINE INDEX MOD_INDEX.  "Lese naechsten Eintrag
   ENDWHILE.
   SORT ILINE BY OPERA SUBTY ASCENDING.
   CLEAR ILINE.
* MOVE 1 TO MOD_INDEX.                                      "XLCK048406
   LOOP AT ILINE.
     CLEAR DYNMEAS.
     MOVE-CORRESPONDING ILINE TO DYNMEAS.
     IF ILINE-OPERA EQ OPERA-DELETE.
       ADD 1                  TO LAST_DMSNR.                "XLCK048406
       MOVE DELETE            TO DYNMEAS-ACTIO.
       MOVE SUPRESS           TO DYNMEAS-SUPDG.
*     MOVE MOD_INDEX         TO DYNMEAS-SEQNR.              "XLCK048406
*     ADD 1                  TO MOD_INDEX.                  "XLCK048406
       MOVE LAST_DMSNR        TO DYNMEAS-SEQNR.             "XLCK048406
       APPEND DYNMEAS.
* Apagar registo na tabela de ligação
*       PERFORM operacao_0018 USING
*             'DEL' p9006-pernr p9006-begda iline-begda iline-endda.

     ENDIF.
     IF ILINE-OPERA EQ OPERA-INSERT.
       ADD 1                  TO LAST_DMSNR.                "XLCK048406
       MOVE INSERT            TO DYNMEAS-ACTIO.
       MOVE SUPRESS           TO DYNMEAS-SUPDG.
*     MOVE MOD_INDEX         TO DYNMEAS-SEQNR.              "XLCK048406
*     ADD 1                  TO MOD_INDEX.                  "XLCK048406
       MOVE LAST_DMSNR        TO DYNMEAS-SEQNR.             "XLCK048406
       APPEND DYNMEAS.
       PERFORM APPEND_INITIAL_VALUES USING LAST_DMSNR SPACE."XLCK048406
* Inserir registo na tabela de ligação
*       PERFORM operacao_0018 USING
*             'INS' p9006-pernr p9006-begda iline-begda iline-endda.
     ENDIF.
   ENDLOOP.

endform.                    " MODIFY_2001
*&---------------------------------------------------------------------*
*&      Form  DELETE_2001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form DELETE_2001.

* PERFORM FILL_INITIAL_VALUES.                              "XLCK048406
   SORT ILINE BY OPERA SUBTY ASCENDING.
   CLEAR ILINE.
   LOOP AT ILINE.
     CLEAR DYNMEAS.
     CHECK ILINE-OPERA EQ OPERA-DELETE OR
     ILINE-OPERA EQ OPERA-NOOPERA.
     ADD 1                    TO LAST_DMSNR.                "XLCK048406
     MOVE-CORRESPONDING ILINE TO DYNMEAS.
     MOVE DELETE              TO DYNMEAS-ACTIO.
     MOVE SUPRESS             TO DYNMEAS-SUPDG.
*   MOVE SY-TABIX            TO DYNMEAS-SEQNR.              "XLCK048406
     MOVE LAST_DMSNR          TO DYNMEAS-SEQNR.             "XLCK048406
     APPEND DYNMEAS.
* Inserir registo na tabela de ligação
*     PERFORM operacao_0018 USING
*           'DEL' p9006-pernr p9006-begda iline-begda iline-endda.
   ENDLOOP.
endform.                    " DELETE_2001
