MODULE_NAME='Yamaha_DVDS2300MK2_UI'(DEV vdvDEVICE, DEV dvTP, 
                                 INTEGER nTransportBtns[], INTEGER nMenuBtns[], 
                                 INTEGER  nKeypadBtns[],   INTEGER nOtherBtns[])

(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  FILE CREATED ON: 6/02/2004 AT: 10:53:40               *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/15/2005  AT: 12:45:29        *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 1                                *)
(***********************************************************)
(*!!FILE REVISION: Rev 0                                   *)
(*  REVISION DATE: 10/21/2003                              *)
(*                                                         *)
(*  COMMENTS:                                              *)
(*                                                         *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)

DEFINE_VARIABLE

VOLATILE CHAR bDebug 

VOLATILE INTEGER bPower = 2      // Initialize to unknown state
VOLATILE CHAR sTransport[16] 
 
DEFINE_EVENT

BUTTON_EVENT[dvTP, nTransportBtns]
{
	PUSH:
	{
		STACK_VAR CHAR nBtnIndex                        // no more than 255 buttons in the array 
		nBtnIndex = GET_LAST(nTransportBtns)
		TO[ BUTTON.INPUT ] 
		SWITCH (nBtnIndex)
		{
				CASE 1:
				{
						SEND_COMMAND 0, "'DVD Transport control 301 reached'"
						SEND_COMMAND vdvDEVICE, "'POWER=1'"
				}
				CASE 2:
				{
						SEND_COMMAND vdvDEVICE, "'POWER=0'"
				}
				CASE 3:
				{
						SEND_COMMAND vdvDEVICE, "'TRANSPORT=PLAY'"
				}
				CASE 4:
				{
						SEND_COMMAND vdvDEVICE, "'TRANSPORT=STOP'"
				}
				CASE 5:
				{
						SEND_COMMAND vdvDEVICE, "'TRANSPORT=PAUSE'"
				}
				CASE 6:
				{
						SEND_COMMAND vdvDEVICE, "'TRANSPORT=NEXT'"
				}
				CASE 7:
				{
						SEND_COMMAND vdvDEVICE, "'TRANSPORT=PREVIOUS'"
				}
				CASE 8:
				{
						SEND_COMMAND vdvDEVICE, "'SCAN=+'"
				}
				CASE 9:
				{
						SEND_COMMAND vdvDEVICE, "'SCAN=-'"
				}
		}   // END OF - switch on button index         
	}
	RELEASE:
	{
	}
}

BUTTON_EVENT[dvTP, nMenuBtns]
{
    PUSH:
    {
        STACK_VAR CHAR nBtnIndex                        // no more than 255 buttons in the array        
        nBtnIndex = GET_LAST(nMenuBtns)
        TO[ BUTTON.INPUT ] 
        SWITCH (nBtnIndex)
        {
            CASE 1:
            {
                SEND_COMMAND vdvDEVICE, "'MENU'"
            }
            CASE 2:
            {
                SEND_COMMAND vdvDEVICE, "'TOPMENU'"
            }
            CASE 3:
            {
                SEND_COMMAND vdvDEVICE, "'RETURN'"
            }
            CASE 4:
            {
                SEND_COMMAND vdvDEVICE, "'MENUSELECT'"
            }
            CASE 5:
            {
                SEND_COMMAND vdvDEVICE, "'CURSOR=UP'"
            }
            CASE 6:
            {
                SEND_COMMAND vdvDEVICE, "'CURSOR=DOWN'"
            }
            CASE 7:
            {
                SEND_COMMAND vdvDEVICE, "'CURSOR=LEFT'"
            }
            CASE 8:
            {
                SEND_COMMAND vdvDEVICE, "'CURSOR=RIGHT'"
            }
            CASE 9:
            {
                SEND_COMMAND vdvDEVICE, "'FOLDER'"
            }
        }
    }
    RELEASE:
    {
    }
}

BUTTON_EVENT[dvTP, nKeypadBtns]
{
    PUSH:
    {
        STACK_VAR CHAR nBtnIndex                        // no more than 255 buttons in the array        
        TO[ BUTTON.INPUT ] 
        nBtnIndex = GET_LAST(nKeypadBtns)
        IF (nBtnIndex = 11)
            SEND_COMMAND vdvDEVICE,"'NUMPAD=+10'"
        ELSE
            SEND_COMMAND vdvDEVICE, "'NUMPAD=',ITOA(nBtnIndex-1)"
    }
    RELEASE:
    {
    }
}

BUTTON_EVENT[dvTP, nOtherBtns]
{
    PUSH:
    {
        STACK_VAR CHAR nBtnIndex
        TO[ BUTTON.INPUT ] 
        nBtnIndex = GET_LAST(nOtherBtns)
        SWITCH (nBtnIndex)
        {
            CASE 1:
            {
                SEND_COMMAND vdvDEVICE,"'CLEAR'"
            }
            CASE 2:
            {
                SEND_COMMAND vdvDEVICE,"'ANGLE=+'"
            }
            CASE 3:
            {
                SEND_COMMAND vdvDEVICE,"'SUBTITLE=T'"
            }
            CASE 4:
            {
                SEND_COMMAND vdvDEVICE,"'AUDIO=T'"
            }
            CASE 5:
            {
                SEND_COMMAND vdvDEVICE,"'REPEATAB'"
            }
            CASE 6:
            {
                SEND_COMMAND vdvDEVICE,"'MARKER'"
            }
        }
    }
}

DATA_EVENT[vdvDEVICE]
{
    STRING:
    {
        STACK_VAR char sName[32]
        STACK_VAR CHAR bTempState
        IF (bDebug)     
            SEND_STRING 0,"'Rcvd from Comm:',DATA.TEXT" 
        sName = REMOVE_STRING (DATA.TEXT,'=',1)
        SWITCH (sName) 
        {
            CASE 'DEBUG=' :            // debug = <state> 
            {
                bDebug = ATOI(DATA.TEXT) 
            }
            CASE 'POWER=' :
            {   
                bPower = ATOI(DATA.TEXT)
            }
            CASE 'TRANSPORT=' :
            {
                sTransport = DATA.TEXT
            }
            CASE 'VERSION=' :
            {
                // print version if you like
            }
        }   // END OF -switch on name 
    }
    COMMAND:
    {
    }
    ONLINE:
    {
    }
    OFFLINE:
    {
    }
}

DATA_EVENT[dvTP]
{
   STRING:
    {
    }
    COMMAND:
    {
    }
    ONLINE:
    {
        send_command dvTP, "'@PPX'"                    // close all popups
    }
    OFFLINE:
    {
    }
}

DEFINE_PROGRAM

//[dvTP,nTransportBtns[1]] = (bPower = 1)        // power ON
//[dvTP,nTransportBtns[2]] = (bPower = 0)        // power OFF

[dvTP,nTransportBtns[3]] = (sTransport = 'PLAY') 
[dvTP,nTransportBtns[4]] = (sTransport = 'STOP')
[dvTP,nTransportBtns[5]] = (sTransport = 'PAUSE')
[dvTP,nTransportBtns[8]] = ( (sTransport = 'SLOW+') OR (sTRANSPORT = 'FAST+') ) 
[dvTP,nTransportBtns[9]] = ( (sTransport = 'SLOW-') OR (sTRANSPORT = 'FAST-') ) 
