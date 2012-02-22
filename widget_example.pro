; Main event-handler routine 
PRO tab_widget_example2_event, ev 
 
  ; Retrieve the anonymous structure contained in the user value of 
  ; the top-level base widget. 
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash 
 
  ; Retrieve the total number of tabs in the tab widget and 
  ; the index of the current tab. 
  numTabs = WIDGET_INFO(stash.TopTab, /TAB_NUMBER) 
  thisTab = WIDGET_INFO(stash.TopTab, /TAB_CURRENT) 
 
  ; If the current tab is the first tab, desensitize the 
  ; 'Previous' button. 
  IF (thisTab EQ 0) THEN BEGIN 
    WIDGET_CONTROL, stash.bPrev, SENSITIVE=0 
  ENDIF ELSE BEGIN 
    WIDGET_CONTROL, stash.bPrev, SENSITIVE=1 
  ENDELSE 
 
  ; If the current tab is the last tab, desensitize the 
  ; 'Next' button. 
  IF (thisTab EQ numTabs - 1) THEN BEGIN 
    WIDGET_CONTROL, stash.bNext, SENSITIVE=0 
  ENDIF ELSE BEGIN 
    WIDGET_CONTROL, stash.bNext, SENSITIVE=1 
  ENDELSE 
 
  ; If the user clicked either the 'Next' or 'Previous' button, 
  ; cycle through the tabs by calling the 'TWE2_SwitchTab' 
  ; procedure. 
  IF (ev.ID EQ stash.bNext) THEN $ 
    TWE2_SwitchTab, thisTab, numTabs, stash, /NEXT 
  IF (ev.ID EQ stash.bPrev) THEN $ 
    TWE2_SwitchTab, thisTab, numTabs, stash, /PREV 
 
  ; If the user clicked the 'Done' button, print out the values of 
  ; the various widgets, as contained in the 'retStruct' 
  ; structure. In a real application, this step would probably 
  ; adjust settings in the application to reflect the changes made 
  ; by the user. Finally, destroy the widgets. 
  IF (ev.ID EQ stash.bDone) THEN BEGIN 
    PRINT, 'BGroup1 selected indices: ', stash.retStruct.BGROUP1 
    PRINT, 'BGroup2 selected index: ', stash.retStruct.BGROUP2 
    PRINT, 'Slider value: ', stash.retStruct.SLIDER 
    PRINT, 'Text value: ', stash.retStruct.TEXT 
    WIDGET_CONTROL, ev.TOP, /DESTROY 
  ENDIF 
 
  ; If the user clicked the 'Cancel' button, print out a message 
  ; and destroy the widgets. In a real application, this step would 
  ; allow the user to discard any changes made via the tabbed 
  ; interface before sending them to the application. 
  IF (ev.ID EQ stash.bCancel) THEN BEGIN 
    PRINT, 'Update Cancelled' 
    WIDGET_CONTROL, ev.TOP, /DESTROY 
  ENDIF 
 
END 
 
; Event function to store the value of a widget in the correct 
; field of the 'retStruct' structure. Note that rather than 
; referring to the structure fields by name, we refer to them 
; by index. This allows us to save the index value of the 
; appropriate structure field in the user value of the widget 
; that generates the event, which in turn allows us to use the 
; same function to save the values of all of the widgets whose 
; values we want to save. 
; 
FUNCTION TWE2_saveValue, ev 
  ; Get the 'stash' structure. 
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash 
  ; Get the value and user value from the widget that 
  ; generated the event. 
  WIDGET_CONTROL, ev.ID, GET_VALUE=val, GET_UVALUE=uval 
  ; Set the value of the correct field in the 'retStruct' 
  ; structure, using the field's index number (stored in 
  ; the widget's user value). 
  stash.retStruct.(uval) = val 
  ; Reset the top-level widget's user value to the updated 
  ; 'stash' structure. 
  WIDGET_CONTROL, ev.TOP, SET_UVALUE=stash 
END 
 
; Procedure to cycle through the tabs when the user clicks 
; the 'Next' or 'Previous' buttons. 
PRO TWE2_SwitchTab, thisTab, numTabs, stash, NEXT=NEXT, PREV=PREV 
 
  ; If user clicked the 'Next' button, we can just add one to 
  ; the current tab number and use the MOD operator to cycle 
  ; back to the first tab. 
  IF KEYWORD_SET(NEXT) THEN nextTab = (thisTab + 1) MOD numTabs 
 
  ; If the user clicked the 'Previous' button, we must explicitly 
  ; handle the case when the user is on the first tab. 
  IF KEYWORD_SET(PREV) THEN BEGIN 
    IF (thisTab EQ 0) THEN BEGIN 
      nextTab = numTabs - 1 
    ENDIF ELSE BEGIN 
      nextTab = (thisTab - 1) 
    ENDELSE 
  ENDIF 
 
; Display the selected tab. 
  WIDGET_CONTROL, stash.TopTab, SET_TAB_CURRENT=nextTab 
 
END 
 
; Widget creation routine. 
PRO tab_widget_example2, LOCATION=location 
 
  ; Create the top-level base and the tab. 
  wTLB = WIDGET_BASE(/COLUMN, /BASE_ALIGN_TOP) 
  wTab = WIDGET_TAB(wTLB, LOCATION=location) 
 
  ; Create the first tab base, containing a label and two 
  ; button groups. For the button groups, set the user value 
  ; equal to the index of the field in the 'retStruct' structure 
  ; that will hold the widget's value. Specify the 
  ; 'TWE2_saveValue' function as the event-handler. 
  wT1 = WIDGET_BASE(wTab, TITLE='TAB 1', /COLUMN) 
  wLabel = WIDGET_LABEL(wT1, VALUE='Choose values') 
  wBgroup1 = CW_BGROUP(wT1, ['one', 'two', 'three'], $ 
    /ROW, /NONEXCLUSIVE, /RETURN_NAME, UVALUE=0, $ 
    EVENT_FUNC='TWE2_saveValue') 
  wBgroup2 = CW_BGROUP(wT1, ['red', 'green', 'blue'], $ 
    /ROW, /EXCLUSIVE, /RETURN_NAME, UVALUE=1, $ 
    EVENT_FUNC='TWE2_saveValue') 
 
  ; Create the second tab base, containing a label and 
  ; a slider. For the slider, set the user value equal 
  ; to the index of the field in the 'retStruct' structure 
  ; that will hold the widget's value. Specify the 
  ; 'TWE2_saveValue' function as the event-handler. 
  wT2 = WIDGET_BASE(wTab, TITLE='TAB 2', /COLUMN) 
  wLabel = WIDGET_LABEL(wT2, VALUE='Move the Slider') 
  wSlider = WIDGET_SLIDER(wT2, UVALUE=2, $ 
    EVENT_FUNC='TWE2_saveValue') 
 
  ; Create the third tab base, containing a label and 
  ; a text-entry field. for the text widget, set the user 
  ; value equal to the index of the field in the 'retStruct' 
  ; structure that will hold the widget's value. Specify the 
  ; 'TWE2_saveValue' function as the event-handler. 
  wT3 = WIDGET_BASE(wTab, TITLE='TAB 3', /COLUMN) 
  wLabel = WIDGET_LABEL(wT3, VALUE='Enter some text') 
  wText= WIDGET_TEXT(wT3, /EDITABLE, /ALL_EVENTS, UVALUE=3, $ 
    EVENT_FUNC='TWE2_saveValue') 
 
  ; Create a base widget to hold the navigation and 'Done' buttons, 
  ; and the buttons themselves. Since the first tab is displayed 
  ; initially, make the 'Previous' button insensitive to start. 
  wControl = WIDGET_BASE(wTLB, /ROW) 
  bPrev = WIDGET_BUTTON(wControl, VALUE='<< Prev', SENSITIVE=0) 
  bNext = WIDGET_BUTTON(wControl, VALUE='Next >>') 
  bDone = WIDGET_BUTTON(wControl, VALUE='Done') 
  bCancel = WIDGET_BUTTON(wControl, VALUE='Cancel') 
 
  ; Create an anonymous structure to hold the widget value data 
  ; we are interested in retrieving. Note that we will refer to 
  ; the structure fields by their indices rather than their 
  ; names, so order is important. 
  retStruct={ BGROUP1:[0,0,0], BGROUP2:0, SLIDER:0L, TEXT:'empty'} 
 
  ; Create an anonymous structure to hold widget IDs and the 
  ; data structure. This structure becomes the user value of the 
  ; top-level base widget. 
  stash = { bDone:bDone, bCancel:bCancel, bNext:bNext, $ 
            bPrev:bPrev, TopTab:wTab, retStruct:retStruct} 
 
  ; Realize the widgets, set the user value of the top-level 
  ; base, and call XMANAGER to manage everything. 
  WIDGET_CONTROL, wTLB, /REALIZE 
  WIDGET_CONTROL, wTLB, SET_UVALUE=stash 
  XMANAGER, 'tab_widget_example2', wTLB, /NO_BLOCK 
 
END 
