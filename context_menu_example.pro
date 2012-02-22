;  $Id:
;  //depot/idl/IDL_70/idldir/examples/doc/widgets/context_menu_example.pro#1 $

;  Copyright (c) 2005-2007, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Widget Application
; Techniques"
; chapter of the _Building IDL Applications_ manual.
;
; To see the context menu in action, run this program and click the
; right mouse button in the draw widget.


; Define event handlers for context menu button events. Note that
; these example event handlers don't do anything interesting; a
; real application would use these handlers for more complicated
; tasks.

PRO CME_11Event, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Context Menu 1 Selection 1 pressed'
END

PRO CME_12Event, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Context Menu 1 Selection 2 pressed'
END

PRO CME_21Event, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Context Menu 2 Selection 1 pressed'
END

PRO CME_22Event, event
  COMPILE_OPT hidden
  PRINT, ' '
  PRINT, 'Context Menu 2 Selection 2 pressed'
END

; Define main event handler
PRO context_menu_example_event, event

  COMPILE_OPT hidden

  ; Test for context menu events
  IF (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_CONTEXT') $
    THEN BEGIN
    ; Obtain the widget ID of the context menu base.
    contextBase = WIDGET_INFO(event.ID, FIND_BY_UNAME = 'contextMenu')
    ; Display the context menu and send its events to the
    ; other event handler routines.
    WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
 ENDIF

  ; Test for button event to end application
  IF (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON') $
    THEN BEGIN
    WIDGET_CONTROL, event.TOP, /DESTROY
 ENDIF

END

; Create GUI
PRO context_menu_example

  topLevelBase = WIDGET_BASE(/COLUMN, XSIZE = 120, YSIZE = 80)
  wText = WIDGET_TEXT(topLevelBase, VALUE="Context Menu Test", $
    /ALL_EVENTS, $
    /CONTEXT_EVENTS)
  wList = WIDGET_LIST(topLevelBase, VALUE=['one','two', 'three'], $
    /CONTEXT_EVENTS)
  contextBase1 = WIDGET_BASE(wText,  /CONTEXT_MENU, $
    UNAME="contextMenu")
  contextBase2 = WIDGET_BASE(wList,  /CONTEXT_MENU, $
    UNAME="contextMenu")
  doneButton = WIDGET_BUTTON(topLevelBase, VALUE="Done")

  ; Initialize the buttons of the context menus.
  cb11 = WIDGET_BUTTON(contextBase1, VALUE = 'Text selection 1', $
    EVENT_PRO = 'CME_11Event')
  cb12 = WIDGET_BUTTON(contextBase1, VALUE = 'Text selection 2', $
    EVENT_PRO = 'CME_12Event')
  cb21 = WIDGET_BUTTON(contextBase2, VALUE = 'List selection 1', $
    EVENT_PRO = 'CME_21Event')
  cb22 = WIDGET_BUTTON(contextBase2, VALUE = 'List selection 2', $
    EVENT_PRO = 'CME_22Event')

  ; Display the GUI.
  WIDGET_CONTROL, topLevelBase, /REALIZE

  ; Handle the events from the GUI.
  XMANAGER, 'context_menu_example', topLevelBase, /NO_BLOCK

END
