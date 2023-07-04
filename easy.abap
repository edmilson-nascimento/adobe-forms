REPORT ytest.

DATA:
  customer_01     TYPE scustom,
  bookings        TYPE ty_bookings,
  connections     TYPE ty_connections,
  fm_name         TYPE rs38l_fnam,
  fp_docparams    TYPE sfpdocparams,
  fp_outputparams TYPE sfpoutputparams.

DATA:
  form_name TYPE fpname VALUE 'ZTESTE'.

* GETTING THE DATA
fp_outputparams-preview  = abap_on .
fp_outputparams-nodialog = abap_on .

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
  RETURN .
ENDIF.

* Get the name of the generated function module
CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
  EXPORTING
    i_name     = form_name
  IMPORTING
    e_funcname = fm_name.
IF sy-subrc <> 0.
  RETURN .
ENDIF.

* Call the generated function module
CALL FUNCTION fm_name
  EXPORTING
    /1bcdwb/docparams = fp_docparams
    customer          = customer_01
    bookings          = bookings
    connections       = connections
*   IMPORTING
*   /1BCDWB/FORMOUTPUT       =
  EXCEPTIONS
    usage_error       = 1
    system_error      = 2
    internal_error    = 3.
IF sy-subrc <> 0.
  RETURN .
ENDIF.

* Close the spool job
CALL FUNCTION 'FP_JOB_CLOSE'
*   IMPORTING
*    E_RESULT             =
  EXCEPTIONS
    usage_error    = 1
    system_error   = 2
    internal_error = 3
    OTHERS         = 4.
IF sy-subrc <> 0.
  RETURN .
ENDIF.