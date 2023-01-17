#line 1 "C:/Users/Talles/Documents/Talles/01_W3E/07-PROJETOS_IOT/ALTAVIS/BOMBAS/PCB_GPIOS - P16F - SLAVE/PCB_TITAN_PUMPCONTROLLER.c"
#line 13 "C:/Users/Talles/Documents/Talles/01_W3E/07-PROJETOS_IOT/ALTAVIS/BOMBAS/PCB_GPIOS - P16F - SLAVE/PCB_TITAN_PUMPCONTROLLER.c"
unsigned char FlagAutoReuso = 0;
unsigned char FlagLigaV2V = 0;
unsigned char FlagReenvmsg1 = 0;
unsigned char FlagReenvmsg2 = 0;
unsigned char _Aux=0;
unsigned char Dta[20];
unsigned char *Pot;
unsigned char ii;
volatile unsigned long int ticks = 0;
unsigned long tempoLed;
unsigned long tempoSmsg;

void Init_cfgMCU();
void DecodificaProtocolo();
void SendStateProtocol(unsigned char GPIO, unsigned char txt[4]);
void sendports();
void REEnviarDados(unsigned char *retData);
void Timers_Init();
void Delay1();
void Delay2();
void uart_rx_enable( void );
void uart_rx_disable( void );
void MBTransmit_On_RS485( void );
void MBReceive_On_RS485( void );
#line 46 "C:/Users/Talles/Documents/Talles/01_W3E/07-PROJETOS_IOT/ALTAVIS/BOMBAS/PCB_GPIOS - P16F - SLAVE/PCB_TITAN_PUMPCONTROLLER.c"
void UART_RCV() iv 0x0004 ics ICS_AUTO {
 unsigned char sdata;
 if(TMR0IF_bit == 1)
 {
 ++ticks;
 TMR0 = 100;
 TMR0IF_bit = 0;
 }
 else
 if(PIR1.RCIF == 1)
 {
 sdata = UART1_Read();
 if(sdata == '[')
 {
 Pot = Dta;
 _Aux = 1;
 }
 else
 if(sdata == ']' && _Aux == 1)
 {
 _Aux = 0;


 DecodificaProtocolo();
 }
 else
 if (_Aux == 1)
 {
 *Pot = sdata;
 ++Pot;

 }
 PIR1.RCIF = 0;
 }

}



void main() {
 Init_cfgMCU();
 UART1_Init(9600);
 Delay_ms(100);

 Timers_Init();

 PIR1.RCIF = 0;
 PIE1.RCIE = 1;
 tempoLed =  (50+ticks) ;
 tempoSmsg =  (500+ticks) ;

 while( 1 )
 {
 if(FlagAutoReuso==1)
 {
 if(( (PORTB.RB0) ==0 ||  (PORTB.RB1) ==0) &&  (!PORTB.RB2) ==0) (PORTB.RB6) =0;
 else
  (PORTB.RB6) =1;
 }
 else
 if( (!PORTB.RB2) ==0&&FlagLigaV2V==1)
 { (PORTB.RB6) =0;

 }
 else
 {
  (PORTB.RB6) =1;


 }

 if(FlagReenvmsg1==1)
 {
 REEnviarDados("C1OK");
 FlagReenvmsg1=0;
 }
 else if(FlagReenvmsg2==1)
 {
 REEnviarDados("C2OK");
 FlagReenvmsg2=0;
 }
 Delay1();
 Delay2();
 }
}



void Init_cfgMCU()
{
 ANSEL = 0;
 ANSELH = 0;

 TRISB = 0x3F;
 TRISA.TRISA0 = 0;

 PORTB.RB6 = 1;
 PORTB.RB7 = 0;
 PORTA.RA0=0;
}

void DecodificaProtocolo()
 {
 unsigned char* tmp;


 if(Dta[0] == 'V' && Dta[1] == '2' && Dta[2] == 'V')
 {FlagLigaV2V = (Dta[3] - '0');
 tmp = &FlagReenvmsg1;
 *tmp = 1;
 }
 else
 if(Dta[0] == 'A' && Dta[1] == 'U' && Dta[2] == 'T')
 {FlagAutoReuso = (Dta[3] - '0');
 tmp = &FlagReenvmsg2;
 *tmp = 1;
 }
 }

 void sendports()
 {
 SendStateProtocol( (PORTB.RB0) ,"ED0");
 Delay_ms(10);
 SendStateProtocol( (PORTB.RB1) ,"ED1");
 Delay_ms(10);
 SendStateProtocol( (!PORTB.RB2) ,"ED2");
 Delay_ms(10);
 SendStateProtocol( (!PORTB.RB3) ,"ED3");
 Delay_ms(10);
 SendStateProtocol( (!PORTB.RB4) ,"ED4");
 Delay_ms(10);
 SendStateProtocol( (!PORTB.RB5) ,"ED5");
 Delay_ms(10);
 SendStateProtocol(! (PORTB.RB6) ,"V2V");
 Delay_ms(10);
 SendStateProtocol(FlagAutoReuso,"AUT");
#line 188 "C:/Users/Talles/Documents/Talles/01_W3E/07-PROJETOS_IOT/ALTAVIS/BOMBAS/PCB_GPIOS - P16F - SLAVE/PCB_TITAN_PUMPCONTROLLER.c"
 }

 void SendStateProtocol(unsigned char GPIO, unsigned char txt[4])
 {
 uart_rx_disable();
 UART1_Write_Text("[");
 UART1_Write_Text(txt);
 if(GPIO==0)UART1_Write_Text("0");
 else
 UART1_Write_Text("1");
 UART1_Write_Text("]");
 uart_rx_enable();
 }

 void REEnviarDados(unsigned char *retData)
{
 uart_rx_disable();
 UART1_Write('[');

 while(*retData != 0)
 {
 UART1_Write(*retData);
 ++retData;
 }

 UART1_Write(']');
 uart_rx_enable();
}

void Timers_Init()
{
 OPTION_REG = 0x86;
 TMR0 = 100;
 INTCON = 0xE0;

 TMR0IF_bit = 0;
 TMR0IE_bit = 1;
}

void Delay1()
{
 if(! (ticks>tempoSmsg?1:0) )return;
 sendports();
 tempoSmsg =  (500+ticks) ;
}

void Delay2()
{
 if(! (ticks>tempoLed?1:0) )return;
 PORTB.RB7^=1;
 tempoLed =  (50+ticks) ;
}

void uart_rx_enable( void )
{

 MBReceive_On_RS485();
 PIE1.RCIE = 1;
}

void uart_rx_disable( void )
{
 MBTransmit_On_RS485();
 PIE1.RCIE = 0;
}

void MBTransmit_On_RS485( void ) {
#line 258 "C:/Users/Talles/Documents/Talles/01_W3E/07-PROJETOS_IOT/ALTAVIS/BOMBAS/PCB_GPIOS - P16F - SLAVE/PCB_TITAN_PUMPCONTROLLER.c"
 TRISA.TRISA0 = 0;
 PORTA.RA0=1;
}

void MBReceive_On_RS485( void )
{
 while (TXSTA.TRMT == 0) ;
#line 267 "C:/Users/Talles/Documents/Talles/01_W3E/07-PROJETOS_IOT/ALTAVIS/BOMBAS/PCB_GPIOS - P16F - SLAVE/PCB_TITAN_PUMPCONTROLLER.c"
 TRISA.TRISA0 = 0;
 PORTA.RA0=0;
}
