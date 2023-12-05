
REPORT  ytest MESSAGE-ID qc NO STANDARD PAGE HEADING..



DATA: customer          TYPE scustom,
      bookings          TYPE ty_bookings,
      connections       TYPE ty_connections,
      fm_name           TYPE rs38l_fnam,
      fp_docparams      TYPE sfpdocparams,
      fp_outputparams   TYPE sfpoutputparams.

DATA:gt_lips TYPE tt_lips  .
DATA:gt_docs TYPE tt_lips  .
DATA:gt_lips_print TYPE tt_lips  .
DATA:ls_lips TYPE LINE OF tt_lips  .
DATA:ls_docs TYPE LINE OF tt_lips  .

START-OF-SELECTION.

* GETTING THE DATA
  SELECT * FROM lips INTO TABLE gt_lips
    WHERE vbeln gt '0080000101' .

  gt_docs = gt_lips.

  DELETE ADJACENT DUPLICATES FROM gt_docs COMPARING vbeln.


* PRINT:


  fp_outputparams-preview = abap_true.

* Sets the output parameters and opens the spool job
  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.

  ENDIF.

* Get the name of the generated function module
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZTEST_FORM'
    IMPORTING
      e_funcname = fm_name.
  IF sy-subrc <> 0.

  ENDIF.

  DATA:v_name TYPE stxbitmaps-tdname VALUE 'GHS_SKULL.BMP'.                      " Contains logo name which is in se78
  DATA:w_binary TYPE xstring.

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp  " Get a BDS Graphic in BMP Format (Using a Cache)
    EXPORTING
      p_object       = 'GRAPHICS'
      p_name         = v_name                               " Name of the logo as in se78
      p_id           = 'BMAP'
      p_btype        = 'BCOL'                               " BCOL'( whether the image is in color or black and white )
    RECEIVING
      p_bmp          = w_binary
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.


  LOOP AT gt_docs INTO ls_docs.

    FREE gt_lips_print.
    LOOP AT gt_lips INTO ls_lips WHERE vbeln = ls_docs-vbeln .

      APPEND ls_lips TO  gt_lips_print.

    ENDLOOP.


* Call the generated function module
    CALL FUNCTION fm_name
      EXPORTING
        /1bcdwb/docparams = fp_docparams
        i_waerk           = 'EUR'
        i_item            = gt_lips_print
        i_logo            = w_binary
      EXCEPTIONS
        usage_error       = 1
        system_error      = 2
        internal_error    = 3.
    IF sy-subrc <> 0.

    ENDIF.

exit.
  ENDLOOP.

* Close the spool job
  CALL FUNCTION 'FP_JOB_CLOSE'
*   IMPORTING
*    E_RESULT             =
    EXCEPTIONS
      usage_error           = 1
      system_error          = 2
      internal_error        = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.

  ENDIF.
