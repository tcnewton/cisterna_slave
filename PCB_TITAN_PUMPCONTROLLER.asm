
_UART_RCV:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;PCB_TITAN_PUMPCONTROLLER.c,46 :: 		void UART_RCV() iv 0x0004 ics ICS_AUTO {
;PCB_TITAN_PUMPCONTROLLER.c,48 :: 		if(TMR0IF_bit == 1)
	BTFSS      TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
	GOTO       L_UART_RCV0
;PCB_TITAN_PUMPCONTROLLER.c,50 :: 		++ticks;
	MOVF       _ticks+0, 0
	MOVWF      R0+0
	MOVF       _ticks+1, 0
	MOVWF      R0+1
	MOVF       _ticks+2, 0
	MOVWF      R0+2
	MOVF       _ticks+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _ticks+0
	MOVF       R0+1, 0
	MOVWF      _ticks+1
	MOVF       R0+2, 0
	MOVWF      _ticks+2
	MOVF       R0+3, 0
	MOVWF      _ticks+3
;PCB_TITAN_PUMPCONTROLLER.c,51 :: 		TMR0                 = 100; //10ms
	MOVLW      100
	MOVWF      TMR0+0
;PCB_TITAN_PUMPCONTROLLER.c,52 :: 		TMR0IF_bit = 0;
	BCF        TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
;PCB_TITAN_PUMPCONTROLLER.c,53 :: 		}
	GOTO       L_UART_RCV1
L_UART_RCV0:
;PCB_TITAN_PUMPCONTROLLER.c,55 :: 		if(PIR1.RCIF == 1)
	BTFSS      PIR1+0, 5
	GOTO       L_UART_RCV2
;PCB_TITAN_PUMPCONTROLLER.c,57 :: 		sdata = UART1_Read();
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      UART_RCV_sdata_L0+0
;PCB_TITAN_PUMPCONTROLLER.c,58 :: 		if(sdata == '[')     //Ex: [V2V01] - [AUT]
	MOVF       R0+0, 0
	XORLW      91
	BTFSS      STATUS+0, 2
	GOTO       L_UART_RCV3
;PCB_TITAN_PUMPCONTROLLER.c,60 :: 		Pot = Dta;       //Salva o endereço da matriz no ponteiro
	MOVLW      _Dta+0
	MOVWF      _Pot+0
;PCB_TITAN_PUMPCONTROLLER.c,61 :: 		_Aux = 1;        //Flag que informa o início do protocolo
	MOVLW      1
	MOVWF      __Aux+0
;PCB_TITAN_PUMPCONTROLLER.c,62 :: 		}
	GOTO       L_UART_RCV4
L_UART_RCV3:
;PCB_TITAN_PUMPCONTROLLER.c,64 :: 		if(sdata == ']' && _Aux == 1)
	MOVF       UART_RCV_sdata_L0+0, 0
	XORLW      93
	BTFSS      STATUS+0, 2
	GOTO       L_UART_RCV7
	MOVF       __Aux+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_UART_RCV7
L__UART_RCV54:
;PCB_TITAN_PUMPCONTROLLER.c,66 :: 		_Aux = 0;
	CLRF       __Aux+0
;PCB_TITAN_PUMPCONTROLLER.c,69 :: 		DecodificaProtocolo();
	CALL       _DecodificaProtocolo+0
;PCB_TITAN_PUMPCONTROLLER.c,70 :: 		}
	GOTO       L_UART_RCV8
L_UART_RCV7:
;PCB_TITAN_PUMPCONTROLLER.c,72 :: 		if (_Aux == 1)
	MOVF       __Aux+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_UART_RCV9
;PCB_TITAN_PUMPCONTROLLER.c,74 :: 		*Pot = sdata;
	MOVF       _Pot+0, 0
	MOVWF      FSR
	MOVF       UART_RCV_sdata_L0+0, 0
	MOVWF      INDF+0
;PCB_TITAN_PUMPCONTROLLER.c,75 :: 		++Pot;
	INCF       _Pot+0, 1
;PCB_TITAN_PUMPCONTROLLER.c,77 :: 		}
L_UART_RCV9:
L_UART_RCV8:
L_UART_RCV4:
;PCB_TITAN_PUMPCONTROLLER.c,78 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;PCB_TITAN_PUMPCONTROLLER.c,79 :: 		}
L_UART_RCV2:
L_UART_RCV1:
;PCB_TITAN_PUMPCONTROLLER.c,81 :: 		}
L_end_UART_RCV:
L__UART_RCV61:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _UART_RCV

_main:

;PCB_TITAN_PUMPCONTROLLER.c,85 :: 		void main() {
;PCB_TITAN_PUMPCONTROLLER.c,86 :: 		Init_cfgMCU();
	CALL       _Init_cfgMCU+0
;PCB_TITAN_PUMPCONTROLLER.c,87 :: 		UART1_Init(9600);
	MOVLW      51
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;PCB_TITAN_PUMPCONTROLLER.c,88 :: 		Delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main10:
	DECFSZ     R13+0, 1
	GOTO       L_main10
	DECFSZ     R12+0, 1
	GOTO       L_main10
	DECFSZ     R11+0, 1
	GOTO       L_main10
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,89 :: 		Timers_Init();
	CALL       _Timers_Init+0
;PCB_TITAN_PUMPCONTROLLER.c,91 :: 		Timers_Init(); //Configura interrupt global (INTCON)
	CALL       _Timers_Init+0
;PCB_TITAN_PUMPCONTROLLER.c,93 :: 		PIR1.RCIF = 0;
	BCF        PIR1+0, 5
;PCB_TITAN_PUMPCONTROLLER.c,94 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;PCB_TITAN_PUMPCONTROLLER.c,95 :: 		tempoLed = start_timer(50);
	MOVLW      50
	MOVWF      _tempoLed+0
	CLRF       _tempoLed+1
	CLRF       _tempoLed+2
	CLRF       _tempoLed+3
	MOVF       _ticks+0, 0
	ADDWF      _tempoLed+0, 1
	MOVF       _ticks+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+1, 0
	ADDWF      _tempoLed+1, 1
	MOVF       _ticks+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+2, 0
	ADDWF      _tempoLed+2, 1
	MOVF       _ticks+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+3, 0
	ADDWF      _tempoLed+3, 1
;PCB_TITAN_PUMPCONTROLLER.c,96 :: 		tempoSmsg = start_timer(500);
	MOVLW      244
	MOVWF      _tempoSmsg+0
	MOVLW      1
	MOVWF      _tempoSmsg+1
	CLRF       _tempoSmsg+2
	CLRF       _tempoSmsg+3
	MOVF       _ticks+0, 0
	ADDWF      _tempoSmsg+0, 1
	MOVF       _ticks+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+1, 0
	ADDWF      _tempoSmsg+1, 1
	MOVF       _ticks+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+2, 0
	ADDWF      _tempoSmsg+2, 1
	MOVF       _ticks+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+3, 0
	ADDWF      _tempoSmsg+3, 1
;PCB_TITAN_PUMPCONTROLLER.c,98 :: 		while(TRUE)
L_main11:
;PCB_TITAN_PUMPCONTROLLER.c,100 :: 		if(FlagAutoReuso==1)
	MOVF       _FlagAutoReuso+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main13
;PCB_TITAN_PUMPCONTROLLER.c,102 :: 		if((CIST1==0 || CIST2==0) && CIST_PRINC==0)ACIONA_V2V=0;
	BTFSS      PORTB+0, 0
	GOTO       L__main57
	BTFSS      PORTB+0, 1
	GOTO       L__main57
	GOTO       L_main18
L__main57:
	BTFSS      PORTB+0, 2
	GOTO       L_main18
L__main56:
	BCF        PORTB+0, 6
	GOTO       L_main19
L_main18:
;PCB_TITAN_PUMPCONTROLLER.c,104 :: 		ACIONA_V2V=1;
	BSF        PORTB+0, 6
L_main19:
;PCB_TITAN_PUMPCONTROLLER.c,105 :: 		}
	GOTO       L_main20
L_main13:
;PCB_TITAN_PUMPCONTROLLER.c,107 :: 		if(CIST_PRINC==0&&FlagLigaV2V==1)
	BTFSS      PORTB+0, 2
	GOTO       L_main23
	MOVF       _FlagLigaV2V+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main23
L__main55:
;PCB_TITAN_PUMPCONTROLLER.c,108 :: 		{ACIONA_V2V=0;//liga V2V
	BCF        PORTB+0, 6
;PCB_TITAN_PUMPCONTROLLER.c,110 :: 		}
	GOTO       L_main24
L_main23:
;PCB_TITAN_PUMPCONTROLLER.c,113 :: 		ACIONA_V2V=1;
	BSF        PORTB+0, 6
;PCB_TITAN_PUMPCONTROLLER.c,114 :: 		FlagLigaV2V=0;
	CLRF       _FlagLigaV2V+0
;PCB_TITAN_PUMPCONTROLLER.c,115 :: 		}
L_main24:
L_main20:
;PCB_TITAN_PUMPCONTROLLER.c,117 :: 		if(FlagReenvmsg1==1)
	MOVF       _FlagReenvmsg1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main25
;PCB_TITAN_PUMPCONTROLLER.c,119 :: 		REEnviarDados("C1OK");
	MOVLW      ?lstr1_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_REEnviarDados_retData+0
	CALL       _REEnviarDados+0
;PCB_TITAN_PUMPCONTROLLER.c,120 :: 		FlagReenvmsg1=0;
	CLRF       _FlagReenvmsg1+0
;PCB_TITAN_PUMPCONTROLLER.c,121 :: 		}
	GOTO       L_main26
L_main25:
;PCB_TITAN_PUMPCONTROLLER.c,122 :: 		else if(FlagReenvmsg2==1)
	MOVF       _FlagReenvmsg2+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main27
;PCB_TITAN_PUMPCONTROLLER.c,124 :: 		REEnviarDados("C2OK");
	MOVLW      ?lstr2_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_REEnviarDados_retData+0
	CALL       _REEnviarDados+0
;PCB_TITAN_PUMPCONTROLLER.c,125 :: 		FlagReenvmsg2=0;
	CLRF       _FlagReenvmsg2+0
;PCB_TITAN_PUMPCONTROLLER.c,126 :: 		}
L_main27:
L_main26:
;PCB_TITAN_PUMPCONTROLLER.c,127 :: 		Delay1();
	CALL       _Delay1+0
;PCB_TITAN_PUMPCONTROLLER.c,128 :: 		Delay2();
	CALL       _Delay2+0
;PCB_TITAN_PUMPCONTROLLER.c,129 :: 		}
	GOTO       L_main11
;PCB_TITAN_PUMPCONTROLLER.c,130 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_Init_cfgMCU:

;PCB_TITAN_PUMPCONTROLLER.c,134 :: 		void Init_cfgMCU()
;PCB_TITAN_PUMPCONTROLLER.c,136 :: 		ANSEL = 0;
	CLRF       ANSEL+0
;PCB_TITAN_PUMPCONTROLLER.c,137 :: 		ANSELH = 0;      // (I/O digital)
	CLRF       ANSELH+0
;PCB_TITAN_PUMPCONTROLLER.c,139 :: 		TRISB = 0x3F; //DIGITAL OUTPUT RB7-RB6 - DIGITAL INPUT RB0..5
	MOVLW      63
	MOVWF      TRISB+0
;PCB_TITAN_PUMPCONTROLLER.c,140 :: 		TRISA.TRISA0 = 0;
	BCF        TRISA+0, 0
;PCB_TITAN_PUMPCONTROLLER.c,142 :: 		PORTB.RB6 = 1;
	BSF        PORTB+0, 6
;PCB_TITAN_PUMPCONTROLLER.c,143 :: 		PORTB.RB7 = 0;
	BCF        PORTB+0, 7
;PCB_TITAN_PUMPCONTROLLER.c,144 :: 		PORTA.RA0=0;
	BCF        PORTA+0, 0
;PCB_TITAN_PUMPCONTROLLER.c,145 :: 		}
L_end_Init_cfgMCU:
	RETURN
; end of _Init_cfgMCU

_DecodificaProtocolo:

;PCB_TITAN_PUMPCONTROLLER.c,147 :: 		void DecodificaProtocolo()
;PCB_TITAN_PUMPCONTROLLER.c,152 :: 		if(Dta[0] == 'V' && Dta[1] == '2' && Dta[2] == 'V')
	MOVF       _Dta+0, 0
	XORLW      86
	BTFSS      STATUS+0, 2
	GOTO       L_DecodificaProtocolo30
	MOVF       _Dta+1, 0
	XORLW      50
	BTFSS      STATUS+0, 2
	GOTO       L_DecodificaProtocolo30
	MOVF       _Dta+2, 0
	XORLW      86
	BTFSS      STATUS+0, 2
	GOTO       L_DecodificaProtocolo30
L__DecodificaProtocolo59:
;PCB_TITAN_PUMPCONTROLLER.c,153 :: 		{FlagLigaV2V = (Dta[3] - '0');
	MOVLW      48
	SUBWF      _Dta+3, 0
	MOVWF      _FlagLigaV2V+0
;PCB_TITAN_PUMPCONTROLLER.c,154 :: 		tmp = &FlagReenvmsg1;
	MOVLW      _FlagReenvmsg1+0
	MOVWF      R1+0
;PCB_TITAN_PUMPCONTROLLER.c,155 :: 		*tmp = 1;
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVLW      1
	MOVWF      INDF+0
;PCB_TITAN_PUMPCONTROLLER.c,156 :: 		}   //Todo valor (0 a 9) ASCII pode ser convertido para número subtraindo por '0'
	GOTO       L_DecodificaProtocolo31
L_DecodificaProtocolo30:
;PCB_TITAN_PUMPCONTROLLER.c,158 :: 		if(Dta[0] == 'A' && Dta[1] == 'U' && Dta[2] == 'T')
	MOVF       _Dta+0, 0
	XORLW      65
	BTFSS      STATUS+0, 2
	GOTO       L_DecodificaProtocolo34
	MOVF       _Dta+1, 0
	XORLW      85
	BTFSS      STATUS+0, 2
	GOTO       L_DecodificaProtocolo34
	MOVF       _Dta+2, 0
	XORLW      84
	BTFSS      STATUS+0, 2
	GOTO       L_DecodificaProtocolo34
L__DecodificaProtocolo58:
;PCB_TITAN_PUMPCONTROLLER.c,159 :: 		{FlagAutoReuso = (Dta[3] - '0');
	MOVLW      48
	SUBWF      _Dta+3, 0
	MOVWF      _FlagAutoReuso+0
;PCB_TITAN_PUMPCONTROLLER.c,160 :: 		tmp = &FlagReenvmsg2;
	MOVLW      _FlagReenvmsg2+0
	MOVWF      R1+0
;PCB_TITAN_PUMPCONTROLLER.c,161 :: 		*tmp = 1;
	MOVF       R1+0, 0
	MOVWF      FSR
	MOVLW      1
	MOVWF      INDF+0
;PCB_TITAN_PUMPCONTROLLER.c,162 :: 		}
L_DecodificaProtocolo34:
L_DecodificaProtocolo31:
;PCB_TITAN_PUMPCONTROLLER.c,163 :: 		}
L_end_DecodificaProtocolo:
	RETURN
; end of _DecodificaProtocolo

_sendports:

;PCB_TITAN_PUMPCONTROLLER.c,165 :: 		void sendports()
;PCB_TITAN_PUMPCONTROLLER.c,167 :: 		SendStateProtocol(CIST1,"ED0");
	MOVLW      0
	BTFSC      PORTB+0, 0
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr3_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,168 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports35:
	DECFSZ     R13+0, 1
	GOTO       L_sendports35
	DECFSZ     R12+0, 1
	GOTO       L_sendports35
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,169 :: 		SendStateProtocol(CIST2,"ED1");
	MOVLW      0
	BTFSC      PORTB+0, 1
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr4_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,170 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports36:
	DECFSZ     R13+0, 1
	GOTO       L_sendports36
	DECFSZ     R12+0, 1
	GOTO       L_sendports36
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,171 :: 		SendStateProtocol(CIST_PRINC,"ED2");
	BTFSC      PORTB+0, 2
	GOTO       L__sendports66
	BSF        3, 0
	GOTO       L__sendports67
L__sendports66:
	BCF        3, 0
L__sendports67:
	MOVLW      0
	BTFSC      3, 0
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr5_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,172 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports37:
	DECFSZ     R13+0, 1
	GOTO       L_sendports37
	DECFSZ     R12+0, 1
	GOTO       L_sendports37
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,173 :: 		SendStateProtocol(CX_RUA,"ED3");
	BTFSC      PORTB+0, 3
	GOTO       L__sendports68
	BSF        3, 0
	GOTO       L__sendports69
L__sendports68:
	BCF        3, 0
L__sendports69:
	MOVLW      0
	BTFSC      3, 0
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr6_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,174 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports38:
	DECFSZ     R13+0, 1
	GOTO       L_sendports38
	DECFSZ     R12+0, 1
	GOTO       L_sendports38
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,175 :: 		SendStateProtocol(SOBRECARGA_CISTERNA,"ED4");
	BTFSC      PORTB+0, 4
	GOTO       L__sendports70
	BSF        3, 0
	GOTO       L__sendports71
L__sendports70:
	BCF        3, 0
L__sendports71:
	MOVLW      0
	BTFSC      3, 0
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr7_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,176 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports39:
	DECFSZ     R13+0, 1
	GOTO       L_sendports39
	DECFSZ     R12+0, 1
	GOTO       L_sendports39
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,177 :: 		SendStateProtocol(SOBRECARGA_PISCINA,"ED5");
	BTFSC      PORTB+0, 5
	GOTO       L__sendports72
	BSF        3, 0
	GOTO       L__sendports73
L__sendports72:
	BCF        3, 0
L__sendports73:
	MOVLW      0
	BTFSC      3, 0
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr8_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,178 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports40:
	DECFSZ     R13+0, 1
	GOTO       L_sendports40
	DECFSZ     R12+0, 1
	GOTO       L_sendports40
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,179 :: 		SendStateProtocol(!ACIONA_V2V,"V2V");
	BTFSC      PORTB+0, 6
	GOTO       L__sendports74
	BSF        3, 0
	GOTO       L__sendports75
L__sendports74:
	BCF        3, 0
L__sendports75:
	MOVLW      0
	BTFSC      3, 0
	MOVLW      1
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr9_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,180 :: 		Delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_sendports41:
	DECFSZ     R13+0, 1
	GOTO       L_sendports41
	DECFSZ     R12+0, 1
	GOTO       L_sendports41
	NOP
;PCB_TITAN_PUMPCONTROLLER.c,181 :: 		SendStateProtocol(FlagAutoReuso,"AUT");
	MOVF       _FlagAutoReuso+0, 0
	MOVWF      FARG_SendStateProtocol_GPIO+0
	MOVLW      ?lstr10_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_SendStateProtocol_txt+0
	CALL       _SendStateProtocol+0
;PCB_TITAN_PUMPCONTROLLER.c,188 :: 		}
L_end_sendports:
	RETURN
; end of _sendports

_SendStateProtocol:

;PCB_TITAN_PUMPCONTROLLER.c,190 :: 		void SendStateProtocol(unsigned char GPIO, unsigned char txt[4])
;PCB_TITAN_PUMPCONTROLLER.c,192 :: 		uart_rx_disable();
	CALL       _uart_rx_disable+0
;PCB_TITAN_PUMPCONTROLLER.c,193 :: 		UART1_Write_Text("[");
	MOVLW      ?lstr11_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;PCB_TITAN_PUMPCONTROLLER.c,194 :: 		UART1_Write_Text(txt);
	MOVF       FARG_SendStateProtocol_txt+0, 0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;PCB_TITAN_PUMPCONTROLLER.c,195 :: 		if(GPIO==0)UART1_Write_Text("0");
	MOVF       FARG_SendStateProtocol_GPIO+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_SendStateProtocol42
	MOVLW      ?lstr12_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
	GOTO       L_SendStateProtocol43
L_SendStateProtocol42:
;PCB_TITAN_PUMPCONTROLLER.c,197 :: 		UART1_Write_Text("1");
	MOVLW      ?lstr13_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
L_SendStateProtocol43:
;PCB_TITAN_PUMPCONTROLLER.c,198 :: 		UART1_Write_Text("]");
	MOVLW      ?lstr14_PCB_TITAN_PUMPCONTROLLER+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;PCB_TITAN_PUMPCONTROLLER.c,199 :: 		uart_rx_enable();
	CALL       _uart_rx_enable+0
;PCB_TITAN_PUMPCONTROLLER.c,200 :: 		}
L_end_SendStateProtocol:
	RETURN
; end of _SendStateProtocol

_REEnviarDados:

;PCB_TITAN_PUMPCONTROLLER.c,202 :: 		void REEnviarDados(unsigned char *retData)
;PCB_TITAN_PUMPCONTROLLER.c,204 :: 		uart_rx_disable();
	CALL       _uart_rx_disable+0
;PCB_TITAN_PUMPCONTROLLER.c,205 :: 		UART1_Write('[');       //inicio do protocolo
	MOVLW      91
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;PCB_TITAN_PUMPCONTROLLER.c,207 :: 		while(*retData != 0)
L_REEnviarDados44:
	MOVF       FARG_REEnviarDados_retData+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_REEnviarDados45
;PCB_TITAN_PUMPCONTROLLER.c,209 :: 		UART1_Write(*retData);   //Conteúdo do protocolo
	MOVF       FARG_REEnviarDados_retData+0, 0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;PCB_TITAN_PUMPCONTROLLER.c,210 :: 		++retData;
	INCF       FARG_REEnviarDados_retData+0, 1
;PCB_TITAN_PUMPCONTROLLER.c,211 :: 		}
	GOTO       L_REEnviarDados44
L_REEnviarDados45:
;PCB_TITAN_PUMPCONTROLLER.c,213 :: 		UART1_Write(']');    //fim do protocolo
	MOVLW      93
	MOVWF      FARG_UART1_Write_data_+0
	CALL       _UART1_Write+0
;PCB_TITAN_PUMPCONTROLLER.c,214 :: 		uart_rx_enable();
	CALL       _uart_rx_enable+0
;PCB_TITAN_PUMPCONTROLLER.c,215 :: 		}
L_end_REEnviarDados:
	RETURN
; end of _REEnviarDados

_Timers_Init:

;PCB_TITAN_PUMPCONTROLLER.c,217 :: 		void Timers_Init()
;PCB_TITAN_PUMPCONTROLLER.c,219 :: 		OPTION_REG         = 0x86;
	MOVLW      134
	MOVWF      OPTION_REG+0
;PCB_TITAN_PUMPCONTROLLER.c,220 :: 		TMR0                 = 100; //10ms
	MOVLW      100
	MOVWF      TMR0+0
;PCB_TITAN_PUMPCONTROLLER.c,221 :: 		INTCON         = 0xE0;
	MOVLW      224
	MOVWF      INTCON+0
;PCB_TITAN_PUMPCONTROLLER.c,223 :: 		TMR0IF_bit = 0;
	BCF        TMR0IF_bit+0, BitPos(TMR0IF_bit+0)
;PCB_TITAN_PUMPCONTROLLER.c,224 :: 		TMR0IE_bit         = 1;
	BSF        TMR0IE_bit+0, BitPos(TMR0IE_bit+0)
;PCB_TITAN_PUMPCONTROLLER.c,225 :: 		}
L_end_Timers_Init:
	RETURN
; end of _Timers_Init

_Delay1:

;PCB_TITAN_PUMPCONTROLLER.c,227 :: 		void Delay1()
;PCB_TITAN_PUMPCONTROLLER.c,229 :: 		if(!timeout(tempoSmsg))return;
	MOVF       _ticks+3, 0
	SUBWF      _tempoSmsg+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delay180
	MOVF       _ticks+2, 0
	SUBWF      _tempoSmsg+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delay180
	MOVF       _ticks+1, 0
	SUBWF      _tempoSmsg+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delay180
	MOVF       _ticks+0, 0
	SUBWF      _tempoSmsg+0, 0
L__Delay180:
	BTFSC      STATUS+0, 0
	GOTO       L_Delay146
	MOVLW      1
	MOVWF      ?FLOC___Delay1T106+0
	GOTO       L_Delay147
L_Delay146:
	CLRF       ?FLOC___Delay1T106+0
L_Delay147:
	MOVF       ?FLOC___Delay1T106+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Delay148
	GOTO       L_end_Delay1
L_Delay148:
;PCB_TITAN_PUMPCONTROLLER.c,230 :: 		sendports();
	CALL       _sendports+0
;PCB_TITAN_PUMPCONTROLLER.c,231 :: 		tempoSmsg = start_timer(500);
	MOVLW      244
	MOVWF      _tempoSmsg+0
	MOVLW      1
	MOVWF      _tempoSmsg+1
	CLRF       _tempoSmsg+2
	CLRF       _tempoSmsg+3
	MOVF       _ticks+0, 0
	ADDWF      _tempoSmsg+0, 1
	MOVF       _ticks+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+1, 0
	ADDWF      _tempoSmsg+1, 1
	MOVF       _ticks+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+2, 0
	ADDWF      _tempoSmsg+2, 1
	MOVF       _ticks+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+3, 0
	ADDWF      _tempoSmsg+3, 1
;PCB_TITAN_PUMPCONTROLLER.c,232 :: 		}
L_end_Delay1:
	RETURN
; end of _Delay1

_Delay2:

;PCB_TITAN_PUMPCONTROLLER.c,234 :: 		void Delay2()
;PCB_TITAN_PUMPCONTROLLER.c,236 :: 		if(!timeout(tempoLed))return;
	MOVF       _ticks+3, 0
	SUBWF      _tempoLed+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delay282
	MOVF       _ticks+2, 0
	SUBWF      _tempoLed+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delay282
	MOVF       _ticks+1, 0
	SUBWF      _tempoLed+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delay282
	MOVF       _ticks+0, 0
	SUBWF      _tempoLed+0, 0
L__Delay282:
	BTFSC      STATUS+0, 0
	GOTO       L_Delay249
	MOVLW      1
	MOVWF      R1+0
	GOTO       L_Delay250
L_Delay249:
	CLRF       R1+0
L_Delay250:
	MOVF       R1+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_Delay251
	GOTO       L_end_Delay2
L_Delay251:
;PCB_TITAN_PUMPCONTROLLER.c,237 :: 		PORTB.RB7^=1; //ToggleLED
	MOVLW      128
	XORWF      PORTB+0, 1
;PCB_TITAN_PUMPCONTROLLER.c,238 :: 		tempoLed = start_timer(50);
	MOVLW      50
	MOVWF      _tempoLed+0
	CLRF       _tempoLed+1
	CLRF       _tempoLed+2
	CLRF       _tempoLed+3
	MOVF       _ticks+0, 0
	ADDWF      _tempoLed+0, 1
	MOVF       _ticks+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+1, 0
	ADDWF      _tempoLed+1, 1
	MOVF       _ticks+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+2, 0
	ADDWF      _tempoLed+2, 1
	MOVF       _ticks+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _ticks+3, 0
	ADDWF      _tempoLed+3, 1
;PCB_TITAN_PUMPCONTROLLER.c,239 :: 		}
L_end_Delay2:
	RETURN
; end of _Delay2

_uart_rx_enable:

;PCB_TITAN_PUMPCONTROLLER.c,241 :: 		void uart_rx_enable( void )
;PCB_TITAN_PUMPCONTROLLER.c,244 :: 		MBReceive_On_RS485();
	CALL       _MBReceive_On_RS485+0
;PCB_TITAN_PUMPCONTROLLER.c,245 :: 		PIE1.RCIE = 1;
	BSF        PIE1+0, 5
;PCB_TITAN_PUMPCONTROLLER.c,246 :: 		}
L_end_uart_rx_enable:
	RETURN
; end of _uart_rx_enable

_uart_rx_disable:

;PCB_TITAN_PUMPCONTROLLER.c,248 :: 		void uart_rx_disable( void )
;PCB_TITAN_PUMPCONTROLLER.c,250 :: 		MBTransmit_On_RS485();
	CALL       _MBTransmit_On_RS485+0
;PCB_TITAN_PUMPCONTROLLER.c,251 :: 		PIE1.RCIE = 0;
	BCF        PIE1+0, 5
;PCB_TITAN_PUMPCONTROLLER.c,252 :: 		}
L_end_uart_rx_disable:
	RETURN
; end of _uart_rx_disable

_MBTransmit_On_RS485:

;PCB_TITAN_PUMPCONTROLLER.c,254 :: 		void MBTransmit_On_RS485( void ) {
;PCB_TITAN_PUMPCONTROLLER.c,258 :: 		TRISA.TRISA0 = 0;
	BCF        TRISA+0, 0
;PCB_TITAN_PUMPCONTROLLER.c,259 :: 		PORTA.RA0=1;
	BSF        PORTA+0, 0
;PCB_TITAN_PUMPCONTROLLER.c,260 :: 		}
L_end_MBTransmit_On_RS485:
	RETURN
; end of _MBTransmit_On_RS485

_MBReceive_On_RS485:

;PCB_TITAN_PUMPCONTROLLER.c,262 :: 		void MBReceive_On_RS485( void )
;PCB_TITAN_PUMPCONTROLLER.c,264 :: 		while (TXSTA.TRMT == 0) ;
L_MBReceive_On_RS48552:
	BTFSC      TXSTA+0, 1
	GOTO       L_MBReceive_On_RS48553
	GOTO       L_MBReceive_On_RS48552
L_MBReceive_On_RS48553:
;PCB_TITAN_PUMPCONTROLLER.c,267 :: 		TRISA.TRISA0 = 0;
	BCF        TRISA+0, 0
;PCB_TITAN_PUMPCONTROLLER.c,268 :: 		PORTA.RA0=0;
	BCF        PORTA+0, 0
;PCB_TITAN_PUMPCONTROLLER.c,269 :: 		}
L_end_MBReceive_On_RS485:
	RETURN
; end of _MBReceive_On_RS485
