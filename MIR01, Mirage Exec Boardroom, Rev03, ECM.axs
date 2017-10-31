PROGRAM_NAME='MIR01, Mirage Exec Boardroom, Rev03, ECM'
(***********************************************************)
(*  FILE CREATED ON: 02/14/2005  AT: 13:25:49              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/21/2005  AT: 11:19:02        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvSwitcher =  5001:1:0							(* 232 - Extron 7SC Switcher; 				9600:8:N:1 *)
dvPlasma   =  5001:2:0							(* 232 - Samsung PPM50H3 Plasma;		 19200:8:N:1 *)
dvDVD      =  5001:3:0							(* 232 - Yamaha S2300MK2 DVD; 				9600:8:N:1 *)

dvVCR      =  5001:9:0							(* IR - Sony SVO-1430 VCR; 	  			sony0182.irl *)

dvCodec    =  5001:10:0							(* AXB-TC - Polycom ViewStation MP; polycomx.irl *)

dvMVP      = 10001:1:0							(* MVP-8400 - 8.4" Modero Viewpoint Touch Panel  *)

(*vvv Virtual Device Definitions go below vvvvvvvvvvvvvvvvv*)

vdvDVD     = 33003:1:0							(* Virtual Device for Yamaha DVD Module          *)
vdvVCR     = 33004:1:0							(* Virtual Device for JVC VCR Module 						 *)

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

plasmaVid		= $00										(* Samsung Plasma Constants *)
plasmaSVid	= $04
plasmaComp1 = $09
plasmaComp2	= $0A
plasmaRGB1	= $15
plasmaRGB2	= $16
plasmaDVI		= $18

plasmaRGBWide = $10
plasmaRGBNorm = $19

plasmaID    = $FE

#WARN 'Please Set Plasma Warmup Time Here'
plasmaWarmUp = 100									(* Plasma Warm Up Time in 1/10 seconds *)

volMax			= 100
volMin			= 0
volIncr			= 2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

//DEV dvTP[] = { dvMVP }

NON_VOLATILE INTEGER nCurInput
VOLATILE INTEGER nCurMenu

NON_VOLATILE INTEGER nPlasmaPower
NON_VOLATILE INTEGER nPlasmaAspect

NON_VOLATILE INTEGER nVolLevel
NON_VOLATILE INTEGER nMuteLevel
NON_VOLATILE INTEGER nMuteState

INTEGER dcDVD_XportBtn[] = 

{
		301,  	// power on  
		302,  	// power off
		31,  		// play
		32,  		// stop
		33,  		// pause 
		34,  		// skip next
		35,  		// skip previous
		36,  		// scan forward
		37   		// scan back 
}

INTEGER dcDVD_MenuBtn[] =
{
		43, 		// menu
		257, 		// top menu
		44, 		// return
		42, 		// menu select 'enter'
		38, 		// cursor up
		39, 		// cursor down
		40, 		// cursor left
		41, 		// cursor right
		257  		// folder
}

INTEGER dcDVD_KeypBtn[] =
{
		50, 		// digit 0         
		51,
		52,
		53,
		54,
		55,
		56,
		57,
		58,
		59,  		// digit 9 
		257
}

INTEGER dcDVD_OtherBtn[] =
{
		45,     // CLEAR button
		46,     // ANGLE button
		47,     // SUBTITLE button
		48,     // AUDIO button
		257,    // REPEAT AB 
		257     // MARKER 
}

INTEGER dcVCR_XPortBtn[] = { 71, 72, 73, 74, 75, 76, 77, 257 }
INTEGER dcVCR_KeypBtn[]  = { 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162 }
INTEGER dcVCR_KeypFct[]  = {  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  21,  22,  23 }

INTEGER dcCodec_KeypadBtn[] = { 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112 }
INTEGER dcCodec_KeypadFct[] = {  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  56,  57 }

INTEGER dcCodec_MenuBtn[]   = { 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123 }
INTEGER dcCodec_MenuFct[]   = {  48,  49,  51,  50,  52,  43,  58,  47,  55,  44,  59 }

INTEGER dcCodec_OtherBtn[]  = { 124, 125, 126, 127, 128, 129, 130 }
INTEGER dcCodec_OtherFct[]  = {  45,  46,  53,  54,  24,  25,  26 }

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(*added by Ethan Mann on 3/9/09.  boardroom users turn off plasma from screen which throws off the 
		programs ability to track it.  added funtion to get plasma on input selection*)
DEFINE_FUNCTION PLASMA_POWER(dev dvDevice, integer nID,INTEGER nSTATE)
{
	IF ( nSTATE )					// Power On Plasma
	{
		ON[ nPlasmaPower ]
		CALL 'Samsung PPM50H3 Power' ( dvPlasma, plasmaID, nPlasmaPower )
		WAIT plasmaWarmUp 'Plasma Warmup Time'
			CALL 'Samsung PPM50H3 Input' ( dvPlasma, plasmaID, plasmaRGB2 )			// !!REV02
		OFF[ nMuteState ]
		CALL 'Extron Sys7SC Mute' ( dvSwitcher, nMuteState )									// !!REV02
	}
	ELSE
	{
		OFF[ nPlasmaPower ]
		CALL 'Samsung PPM50H3 Power' ( dvPlasma, plasmaID, nPlasmaPower )
	}	
}
//DEFINE_FUNCTION PLASMA_POWER_ON()
//{
//	ON[nPlasmaPower]
//	STACK_VAR INTEGER nCkSum
//	nCkSum = ($11 + plasmaID + $01 + $01) % $100
//	SEND_STRING dvPlasma, "$AA,$11,$FE,$01,$01,nCkSum"
//}
DEFINE_CALL 'Samsung PPM50H3 Power' ( dev dvDevice, integer nID, integer nState )
{
	STACK_VAR INTEGER nCkSum
	nCkSum = ($11 + nID + $01 + nState) % $100
	SEND_STRING dvDevice, " $AA, $11, nID, $01, nState, nCkSum"
}
DEFINE_CALL 'Samsung PPM50H3 Input' ( dev dvDevice, integer nID, integer nInput )
{
	STACK_VAR INTEGER nCkSum
	nCkSum = ($14 + nID + $01 + nInput) % $100
	SEND_STRING dvDevice, " $AA, $14, nID, $01, nInput, nCkSum"
}
DEFINE_CALL 'Samsung PPM50H3 Aspect Ratio' ( dev dvDevice, integer nID, integer nAspect )
{
	STACK_VAR INTEGER nCkSum
	nCkSum = ($15 + nID + $01 + nAspect) % $100
	SEND_STRING dvDevice, " $AA, $15, nID, $01, nAspect, nCkSum"
}
(*** !!REV01 - Volume control changed to Extron
DEFINE_CALL 'Samsung PPM50H3 Volume' ( dev dvDevice, integer nID, integer nLevel )
{
	STACK_VAR INTEGER nCkSum
	nCkSum = ($12 + nID + $01 + nLevel) % $100
	SEND_STRING dvDevice, " $AA, $12, nID, $01, nLevel, nCkSum"
}
DEFINE_CALL 'Samsung PPM50H3 Mute' ( dev dvDevice, integer nID, integer nState )
{
	STACK_VAR INTEGER nCkSum
	nCkSum = ($13 + nID + $01 + nState) % $100
	SEND_STRING dvDevice, " $AA, $13, nID, $01, nState, nCkSum"
}
****)

DEFINE_CALL 'Extron Sys7SC Volume' ( dev dvDevice, integer nLevel )
{
	SEND_STRING dvDevice, "ITOA( nLevel ),'V'"
}
DEFINE_CALL 'Extron Sys7SC Mute' ( dev dvDevice, integer nState )
{
	SEND_STRING dvDevice, "ITOA( nState ),'Z'"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE MODULES GO BELOW                     *)
(***********************************************************)

DEFINE_MODULE 'Yamaha_DVDS2300MK2_Comm' mdlDVD_COMM1( vdvDVD, dvDVD )
DEFINE_MODULE 'Yamaha_DVDS2300MK2_UI' mdlDVD_UI1( vdvDVD, dvMVP, dcDVD_XportBtn, dcDVD_MenuBtn, dcDVD_KeypBtn, dcDVD_OtherBtn )
																								 
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvSwitcher]							(* 232 - Extron 7SC Switcher; 				9600:8:N:1 *)
{
	ONLINE:
	{
		SEND_COMMAND DATA.DEVICE, 'SET BAUD 9600,N,8,1 485 DISABLE'
		SEND_COMMAND DATA.DEVICE, 'HSOFF'
	}
}
DATA_EVENT[dvPlasma]								(* 232 - Samsung PPM50H3 Plasma;		 19200:8:N:1 *)
{
	ONLINE:
	{
		SEND_COMMAND DATA.DEVICE, 'SET BAUD 19200,N,8,1 485 DISABLE'
		SEND_COMMAND DATA.DEVICE, 'HSOFF'
	}
	STRING:
	{
		LOCAL_VAR CHAR TEMP_STR[1]
		IF(FIND_STRING(DATA.TEXT,"'A',$11",1))
		{
			TEMP_STR = MID_STRING(DATA.TEXT,7,1)
			nPlasmaPower = ATOI(TEMP_STR)
		}
	}
}
DATA_EVENT[dvVCR]										(* IR - Sony SVO-1430 VCR; 	  			sony0182.irl *)
DATA_EVENT[dvCodec]									(* AXB-TC - Polycom ViewStation MP; polycomx.irl *)
{
	ONLINE:
	{
		SEND_COMMAND DATA.DEVICE, 'SET MODE IR'
		SEND_COMMAND DATA.DEVICE, 'CARON'
	}
}
DATA_EVENT[dvMVP]										(* MVP-7500 - Modero ViewPoint								   *)
{
	ONLINE:
	{
		SEND_COMMAND DATA.DEVICE, '@PPN-WELCOME'
	}
}

BUTTON_EVENT[dvMVP,11]								(* Select Computers *)
{
	PUSH:
	{
		nCurMenu = 1
		
		CANCEL_WAIT 'change channel to 0'
		SYSTEM_CALL 'FUNCTION' ( dvVCR, 2, 0 )		// Stop VCR			// !!REV02
		WAIT 7 'change channel to 0'
			SEND_COMMAND dvVCR, "'XCH1'"			// PULSE IR '0'
	}
}

BUTTON_EVENT[dvMVP,21]								(* Select Laptop #1 *)
BUTTON_EVENT[dvMVP,22]								(* Select Laptop #2 *)
BUTTON_EVENT[dvMVP,23]								(* Select System PC *)
{
	PUSH:
	{
		nCurInput = BUTTON.INPUT.CHANNEL - 20
		SEND_STRING dvSwitcher, "ITOA( nCurInput ),'!'"
		ON[nPlasmaPower]
		CALL 'Samsung PPM50H3 Power' (dvPlasma,plasmaID,nPlasmaPower)
	}
}
BUTTON_EVENT[dvMVP,12]								(* Select DVD/CD *)
{
	PUSH:
	{
		nCurMenu = 2
		nCurInput = 4
		SEND_STRING dvSwitcher, "ITOA( nCurInput ),'!'"
		SEND_STRING 0, "'sELECT dvd PUSHED'"
//		DO_PUSH ( dvMVP, 301 )				// Power On DVD
		SEND_COMMAND dvDVD, "'POWER=1'"
		ON[nPlasmaPower]
		CALL 'Samsung PPM50H3 Power' (dvPlasma,plasmaID,nPlasmaPower)
		CANCEL_WAIT 'change channel to 0'
		SYSTEM_CALL 'FUNCTION' ( dvVCR, 2, 0 )		// Stop VCR			// !!REV02
		WAIT 7 'change channel to 0'
			SEND_COMMAND dvVCR, "'XCH1'"			// PULSE IR '0'
	}
}
BUTTON_EVENT[dvMVP,13]								(* Select VHS VCR *)
BUTTON_EVENT[dvMVP,15]								(* Select TV Tuner *)
{
	PUSH:
	{
		nCurMenu = BUTTON.INPUT.CHANNEL - 10
		nCurInput = 5
		SEND_STRING dvSwitcher, "ITOA( nCurInput ),'!'"		
		IF (nCurMenu=3)								// If VCR is Selected											// !!REV02
		{
			SEND_COMMAND dvVCR, "'XCH1'"
		}
		ELSE IF (nCurMenu=5)								// If TV Tuner Selected
		{
			SYSTEM_CALL 'FUNCTION' ( dvVCR, 2, 0 )		// Stop VCR
			SEND_COMMAND dvVCR, "'XCH3'"
		}
		ON[nPlasmaPower]
		CALL 'Samsung PPM50H3 Power' (dvPlasma,plasmaID,nPlasmaPower)
		CANCEL_WAIT 'change channel to 0'																				// !!REV02
	}
}

BUTTON_EVENT[dvMVP,16]								(* Select Aux Input *)
{
	PUSH:
	{
		nCurMenu = 6
		nCurInput = 7
		SEND_STRING dvSwitcher, "ITOA( nCurInput ),'!'"
		ON[nPlasmaPower]
		CALL 'Samsung PPM50H3 Power' (dvPlasma,plasmaID,nPlasmaPower)
		CANCEL_WAIT 'change channel to 0'
		SYSTEM_CALL 'FUNCTION' ( dvVCR, 2, 0 )		// Stop VCR			// !!REV02
		WAIT 7 'change channel to 0'
			SEND_COMMAND dvVCR, "'XCH1'"			// PULSE IR '0'
	}
}
BUTTON_EVENT[dvMVP,14]								(* Select Video Conference *)
{
	PUSH:
	{
		nCurMenu = 4
		nCurInput = 6
		SEND_STRING dvSwitcher, "ITOA( nCurInput ),'!'"
		ON[nPlasmaPower]
		CALL 'Samsung PPM50H3 Power' (dvPlasma,plasmaID,nPlasmaPower)
		CANCEL_WAIT 'change channel to 0'
		SYSTEM_CALL 'FUNCTION' ( dvVCR, 2, 0 )		// Stop VCR			// !!REV02
		WAIT 7 'change channel to 0'
			SEND_COMMAND dvVCR, "'XCH1'"			// PULSE IR '0'
	}
}

BUTTON_EVENT[dvMVP,dcVCR_XPortBtn]			 (* VCR Transports *)
{
	PUSH:
	{
		SYSTEM_CALL [1] 'VCR2' ( dvVCR, BUTTON.INPUT.DEVICE, dcVCR_XPortBtn[1], dcVCR_XPortBtn[2], dcVCR_XPortBtn[3], dcVCR_XPortBtn[4], dcVCR_XPortBtn[5], dcVCR_XPortBtn[6], dcVCR_XPortBtn[7], dcVCR_XPortBtn[8], 0  )
	}
	RELEASE:
	{
		SYSTEM_CALL [1] 'VCR2' ( dvVCR, BUTTON.INPUT.DEVICE, dcVCR_XPortBtn[1], dcVCR_XPortBtn[2], dcVCR_XPortBtn[3], dcVCR_XPortBtn[4], dcVCR_XPortBtn[5], dcVCR_XPortBtn[6], dcVCR_XPortBtn[7], dcVCR_XPortBtn[8], 0  )
	}
}

BUTTON_EVENT[dvMVP,dcVCR_KeypBtn]
{
	PUSH:
	{
		STACK_VAR INTEGER nBtnIdx
		nBtnIdx = GET_LAST( dcVCR_KeypBtn )
		TO[dvVCR, dcVCR_KeypFct[nBtnIdx]]
	}
}

BUTTON_EVENT[dvMVP,dcCodec_KeypadBtn]   (* Polycom Keypad Functions *)
{
	PUSH:
	{
		STACK_VAR INTEGER nBtnIdx
		nBtnIdx = GET_LAST ( dcCodec_KeypadBtn )
		TO[dvCodec, dcCodec_KeypadFct[ nBtnIdx ]]
	}
}
BUTTON_EVENT[dvMVP,dcCodec_MenuBtn]   		(* Polycom Menu Functions *)
{
	PUSH:
	{
		STACK_VAR INTEGER nBtnIdx
		nBtnIdx = GET_LAST ( dcCodec_MenuBtn )
		TO[dvCodec, dcCodec_MenuFct[ nBtnIdx ]]
	}
}
BUTTON_EVENT[dvMVP,dcCodec_OtherBtn]   	(* Polycom Other Functions *)
{
	PUSH:
	{
		STACK_VAR INTEGER nBtnIdx
		nBtnIdx = GET_LAST ( dcCodec_OtherBtn )
		TO[dvCodec, dcCodec_OtherFct[ nBtnIdx ]]
	}
}

BUTTON_EVENT[dvMVP,201]							(* Increase Plasma Volume Level *)
{
	PUSH:
	{
		TO[ BUTTON.INPUT ]
		IF ( nMuteState )
		{
			OFF[ nMuteState ]
			nVolLevel = nMuteLevel
//			CALL 'Samsung PPM50H3 Mute' ( dvPlasma, plasmaID, nMuteState )
			CALL 'Extron Sys7SC Mute' ( dvSwitcher, nMuteState )							// !!REV01
		}
		
		IF ( nVolLevel <= ( volMax - volIncr ) )
			nVolLevel = nVolLevel + volIncr
		ELSE
			nVolLevel = volMax
			
//		CALL 'Samsung PPM50H3 Volume' ( dvPlasma, plasmaID, nVolLevel )
		CALL 'Extron Sys7SC Volume' ( dvSwitcher, nVolLevel )							// !!REV01
	}
	HOLD[3,REPEAT]:
	{
		IF ( nVolLevel <= ( volMax - volIncr ) )
			nVolLevel = nVolLevel + volIncr
		ELSE
			nVolLevel = volMax
			
//		CALL 'Samsung PPM50H3 Volume' ( dvPlasma, plasmaID, nVolLevel )
		CALL 'Extron Sys7SC Volume' ( dvSwitcher, nVolLevel )							// !!REV01
	}
}
BUTTON_EVENT[dvMVP,202]							(* Decrease Plasma Volume Level *)
{
	PUSH:
	{
		TO[ BUTTON.INPUT ]
		IF ( nMuteState )
		{
			OFF[ nMuteState ]
			nVolLevel = nMuteLevel
//			CALL 'Samsung PPM50H3 Mute' ( dvPlasma, plasmaID, nMuteState )
			CALL 'Extron Sys7SC Mute' ( dvSwitcher, nMuteState )							// !!REV01
		}
		
		IF ( nVolLevel >= ( volMin + volIncr ) )
			nVolLevel = nVolLevel - volIncr
		ELSE
			nVolLevel = volMin
			
//		CALL 'Samsung PPM50H3 Volume' ( dvPlasma, plasmaID, nVolLevel )
		CALL 'Extron Sys7SC Volume' ( dvSwitcher, nVolLevel )							// !!REV01
	}
	HOLD[3,REPEAT]:
	{
		IF ( nVolLevel >= ( volMin + volIncr ) )
			nVolLevel = nVolLevel - volIncr
		ELSE
			nVolLevel = volMin
			
//		CALL 'Samsung PPM50H3 Volume' ( dvPlasma, plasmaID, nVolLevel )
		CALL 'Extron Sys7SC Volume' ( dvSwitcher, nVolLevel )							// !!REV01
	}
}
BUTTON_EVENT[dvMVP,203]							(* Mute/Unmute Plasma Volume Level *)
{
	PUSH:
	{
		nMuteState = !nMuteState
//		CALL 'Samsung PPM50H3 Mute' ( dvPlasma, plasmaID, nMuteState )
		CALL 'Extron Sys7SC Mute' ( dvSwitcher, nMuteState )							// !!REV01
		
		IF ( nMuteState )
		{
			nMuteLevel = nVolLevel
			nVolLevel = 0
		}
		ELSE
		{
			nVolLevel = nMuteLevel
		}
	}
}

BUTTON_EVENT[dvMVP,211] 							(* Plasma Normal Aspect Ratio *)
{
	PUSH:
	{
		nPlasmaAspect = plasmaRGBNorm
		CALL 'Samsung PPM50H3 Aspect Ratio' ( dvPlasma, plasmaID, plasmaRGBNorm )
	}
}
BUTTON_EVENT[dvMVP,212] 							(* Plasma Wide Aspect Ratio *)
{
	PUSH:
	{
		nPlasmaAspect = plasmaRGBWide
		CALL 'Samsung PPM50H3 Aspect Ratio' ( dvPlasma, plasmaID, plasmaRGBWide )
	}
}

BUTTON_EVENT[dvMVP,251]							(* System Shutdown *)
{
	PUSH:
	{
			nCurMenu = 0
			nCurInput = 0
			OFF[ nPlasmaPower ]
			PLASMA_POWER(dvPlasma,plasmaID,nPlasmaPower)
			ON[ nMuteState ]
			CALL 'Extron Sys7SC Mute' ( dvSwitcher, nMuteState )							// !!REV02
			
//			DO_PUSH ( dvMVP, 302 )				(* Power Off DVD *)
			SEND_COMMAND dvDVD, "'POWER=0'"
			DO_PUSH ( dvMVP, 312 )				(* Power Off VCR *)
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

WAIT 10 SEND_LEVEL dvMVP, 1, (((nVolLevel - volMin) * 255) / (volMax-volMin))			// !!REV01

[dvMVP,11] = (nCurMenu=1)
[dvMVP,12] = (nCurMenu=2)
[dvMVP,13] = (nCurMenu=3)
[dvMVP,14] = (nCurMenu=4)
[dvMVP,15] = (nCurMenu=5)
[dvMVP,16] = (nCurMenu=6)

[dvMVP,21] = (nCurInput=1)
[dvMVP,22] = (nCurInput=2)
[dvMVP,23] = (nCurInput=3)

SYSTEM_CALL [1] 'VCR2' ( dvVCR, dvMVP, dcVCR_XPortBtn[1], dcVCR_XPortBtn[2], dcVCR_XPortBtn[3], dcVCR_XPortBtn[4], dcVCR_XPortBtn[5], dcVCR_XPortBtn[6], dcVCR_XPortBtn[7], dcVCR_XPortBtn[8], 0  )

[dvMVP,dcVCR_KeypBtn[ 1]] = [dvVCR, dcVCR_KeypFct[ 1]]
[dvMVP,dcVCR_KeypBtn[ 2]] = [dvVCR, dcVCR_KeypFct[ 2]]
[dvMVP,dcVCR_KeypBtn[ 3]] = [dvVCR, dcVCR_KeypFct[ 3]]
[dvMVP,dcVCR_KeypBtn[ 4]] = [dvVCR, dcVCR_KeypFct[ 4]]
[dvMVP,dcVCR_KeypBtn[ 5]] = [dvVCR, dcVCR_KeypFct[ 5]]
[dvMVP,dcVCR_KeypBtn[ 6]] = [dvVCR, dcVCR_KeypFct[ 6]]
[dvMVP,dcVCR_KeypBtn[ 7]] = [dvVCR, dcVCR_KeypFct[ 7]]
[dvMVP,dcVCR_KeypBtn[ 8]] = [dvVCR, dcVCR_KeypFct[ 8]]
[dvMVP,dcVCR_KeypBtn[ 9]] = [dvVCR, dcVCR_KeypFct[ 9]]
[dvMVP,dcVCR_KeypBtn[10]] = [dvVCR, dcVCR_KeypFct[10]]
[dvMVP,dcVCR_KeypBtn[11]] = [dvVCR, dcVCR_KeypFct[11]]
[dvMVP,dcVCR_KeypBtn[12]] = [dvVCR, dcVCR_KeypFct[12]]
[dvMVP,dcVCR_KeypBtn[13]] = [dvVCR, dcVCR_KeypFct[13]]

[dvMVP,dcCodec_KeypadBtn[ 1]] = [dvCodec, dcCodec_KeypadFct[ 1]]
[dvMVP,dcCodec_KeypadBtn[ 2]] = [dvCodec, dcCodec_KeypadFct[ 2]]
[dvMVP,dcCodec_KeypadBtn[ 3]] = [dvCodec, dcCodec_KeypadFct[ 3]]
[dvMVP,dcCodec_KeypadBtn[ 4]] = [dvCodec, dcCodec_KeypadFct[ 4]]
[dvMVP,dcCodec_KeypadBtn[ 5]] = [dvCodec, dcCodec_KeypadFct[ 5]]
[dvMVP,dcCodec_KeypadBtn[ 6]] = [dvCodec, dcCodec_KeypadFct[ 6]]
[dvMVP,dcCodec_KeypadBtn[ 7]] = [dvCodec, dcCodec_KeypadFct[ 7]]
[dvMVP,dcCodec_KeypadBtn[ 8]] = [dvCodec, dcCodec_KeypadFct[ 8]]
[dvMVP,dcCodec_KeypadBtn[ 9]] = [dvCodec, dcCodec_KeypadFct[ 9]]
[dvMVP,dcCodec_KeypadBtn[10]] = [dvCodec, dcCodec_KeypadFct[10]]
[dvMVP,dcCodec_KeypadBtn[11]] = [dvCodec, dcCodec_KeypadFct[11]]
[dvMVP,dcCodec_KeypadBtn[12]] = [dvCodec, dcCodec_KeypadFct[12]]

[dvMVP,dcCodec_MenuBtn[ 1]] = [dvCodec, dcCodec_MenuFct[ 1]]
[dvMVP,dcCodec_MenuBtn[ 2]] = [dvCodec, dcCodec_MenuFct[ 2]]
[dvMVP,dcCodec_MenuBtn[ 3]] = [dvCodec, dcCodec_MenuFct[ 3]]
[dvMVP,dcCodec_MenuBtn[ 4]] = [dvCodec, dcCodec_MenuFct[ 4]]
[dvMVP,dcCodec_MenuBtn[ 5]] = [dvCodec, dcCodec_MenuFct[ 5]]
[dvMVP,dcCodec_MenuBtn[ 6]] = [dvCodec, dcCodec_MenuFct[ 6]]
[dvMVP,dcCodec_MenuBtn[ 7]] = [dvCodec, dcCodec_MenuFct[ 7]]
[dvMVP,dcCodec_MenuBtn[ 8]] = [dvCodec, dcCodec_MenuFct[ 8]]
[dvMVP,dcCodec_MenuBtn[ 9]] = [dvCodec, dcCodec_MenuFct[ 9]]
[dvMVP,dcCodec_MenuBtn[10]] = [dvCodec, dcCodec_MenuFct[10]]
[dvMVP,dcCodec_MenuBtn[11]] = [dvCodec, dcCodec_MenuFct[11]]

[dvMVP,dcCodec_OtherBtn[ 1]] = [dvCodec, dcCodec_OtherFct[ 1]]
[dvMVP,dcCodec_OtherBtn[ 2]] = [dvCodec, dcCodec_OtherFct[ 2]]
[dvMVP,dcCodec_OtherBtn[ 3]] = [dvCodec, dcCodec_OtherFct[ 3]]
[dvMVP,dcCodec_OtherBtn[ 4]] = [dvCodec, dcCodec_OtherFct[ 4]]
[dvMVP,dcCodec_OtherBtn[ 5]] = [dvCodec, dcCodec_OtherFct[ 5]]
[dvMVP,dcCodec_OtherBtn[ 6]] = [dvCodec, dcCodec_OtherFct[ 6]]
[dvMVP,dcCodec_OtherBtn[ 7]] = [dvCodec, dcCodec_OtherFct[ 7]]

[dvMVP,203] = nMuteState																						// !!REV01

[dvMVP,211] = (nPlasmaAspect=plasmaRGBNorm) && nPlasmaPower
[dvMVP,212] = (nPlasmaAspect=plasmaRGBWide) && nPlasmaPower

WAIT 432000 'KEEP ALIVE' // THIS KEEPS COMMUNICATION BETWEEN THE PANEL AND MASTER ALIVE
{
	SEND_COMMAND dvMVP,'WAKE'
}
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)