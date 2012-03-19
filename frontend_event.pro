PRO FRONTEND_EVENT, ev
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; PURPOSE:
;
;    This procedure is managed automatically by XMANAGER. It gets
;    events of the widgets and save settings on the pointer which
;    comes in the UVALUE of the widget.
;
; Input:          event
; Output:         -
; External calls: -
;
; Some information about EVENT structure:
;-----------------------------------------
; (Source:
; http://idlastro.gsfc.nasa.gov/idl_html_help/Widget_Event_Processing.html#wp1042229)
;
; As events arrive from the window system, IDL saves them in a queue
; for the target widget. The WIDGET_EVENT function delivers these
; events to the IDL program as IDL structures. Every widget event
; structure has the same first three fields: these are long integers
; named ID, TOP, and HANDLER:
 
; * ID is the widget ID of the widget that generated the event.
;
; * TOP is the widget ID of the top-level base containing ID.
;
; * HANDLER is the widget ID of the widget associated with the event
;   handling routine. The importance of HANDLER will become apparent
;   dealing with event routines and compound widgets.
;
; Given a widget event structure, you need to know what type of
; widget generated it without having to match the widget ID in the
; event structure to all the current widgets. This information is
; available by specifying the STRUCTURE_NAME keyword to the TAG_NAMES
; function


; Each widget can contain a user set value of any data type and
; organization. This value is not used by the widget in any way, and
; exists entirely for the convenience of the IDL programmer. This
; keyword allows you to obtain the current user value. 





; Retrieve the anonymous structure contained in the user value of 
; the top-level base widget. 
WIDGET_CONTROL, ev.TOP, GET_UVALUE = stash 

; If event was caused by a user movement of the slider...
if (TAG_NAMES(ev, /STRUCTURE_NAME) eq 'WIDGET_SLIDER') then begin

   ; ...annotate the chosen value 
   WIDGET_CONTROL, ev.ID, GET_VALUE = value
   (*stash.ptrInfo).value = value
   WIDGET_CONTROL, ev.TOP, SET_UVALUE = stash

endif

; If event was caused by the check-box...
if (TAG_NAMES(ev, /STRUCTURE_NAME) eq 'CW_BGROUP') then begin

   ; ...annotate the chosen option
   WIDGET_CONTROL, ev.ID, GET_VALUE = option
   (*stash.ptrInfo).option = option
   WIDGET_CONTROL, ev.TOP, SET_UVALUE = stash

endif

; If event was caused for pressing a button...

; For info about for returning values of Compound Widgets, read:
; http://idlastro.gsfc.nasa.gov/idl_html_help/Creating_a_Compound_Widget.html#wp1042483
if (TAG_NAMES(ev, /STRUCTURE_NAME) eq 'WIDGET_BUTTON') then begin
      
   ; ...check which was the button... 
   case ev.ID of

      stash.bCancel  : *stash.ptrStatus = 'Cancel'
      stash.bRefresh : *stash.ptrStatus = 'Refresh'
      stash.bDone    : *stash.ptrStatus = 'Done'

   endcase

   ; ...annotate it...
   WIDGET_CONTROL, ev.TOP, SET_UVALUE = stash

   ; ...and destroy the widget at any case
   ; (if bRefresh, the widget will be created again;
   ;  it's the cleaner solution I can guess today :/)
   WIDGET_CONTROL, ev.TOP, /DESTROY

endif


END
