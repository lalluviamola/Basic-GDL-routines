PRO FRONTEND_EVENT, event

  COMPILE_OPT hidden

  ; Test for context menu events
  if (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_CONTEXT') $
  then begin

    ; Obtain the widget ID of the context menu base.
    contextBase = WIDGET_INFO(event.ID, FIND_BY_UNAME = 'contextMenu')

    ; Display the context menu and send its events to the
    ; other event handler routines.
    WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase

 endif

  ; Test for button event to end application
  if (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON') $
  then begin

     WIDGET_CONTROL, event.TOP, /DESTROY

  endif

END
