#define CIST1   (PORTB.RB0)
#define CIST2   (PORTB.RB1)
#define CIST_PRINC         (!PORTB.RB2)
#define CX_RUA             (!PORTB.RB3)
#define SOBRECARGA_CISTERNA        (!PORTB.RB4)
#define SOBRECARGA_PISCINA         (!PORTB.RB5)
#define ACIONA_V2V                 (PORTB.RB6)
#define TRUE                       1

#define start_timer(X) (X+ticks) //Retorna um timer_t para o tempo especificado.
#define timeout(X) (ticks>X?1:0) //TRUE se o tempo especificado na criação do timer já foi transcorrido.

unsigned char FlagAutoReuso = 0;
unsigned char FlagLigaV2V = 0;
unsigned char FlagReenvmsg1 = 0;
unsigned char FlagReenvmsg2 = 0;
unsigned char _Aux=0;
unsigned char Dta[20];
unsigned char *Pot;
unsigned char ii;
volatile unsigned long int ticks = 0;  //Variável responsável por armazenar o incremento do Tick Timer
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

/*
EASYPIC V7
SW1.1 ->ON  (UART RX-RC7)
SW2.1 ->ON  (UART TX-RC6)
SW3.2 ->ON  (LED-ON PORTB)
PULL-UP ->RB0...RB5
*/

void UART_RCV() iv 0x0004 ics ICS_AUTO {
 unsigned char sdata;
   if(TMR0IF_bit == 1)
   {
    ++ticks;
    TMR0                 = 100; //10ms
    TMR0IF_bit = 0;
   }
   else
   if(PIR1.RCIF == 1)
   {
    sdata = UART1_Read();
      if(sdata == '[')     //Ex: [V2V01] - [AUT]
       {
         Pot = Dta;       //Salva o endereço da matriz no ponteiro
         _Aux = 1;        //Flag que informa o início do protocolo
       }
       else
          if(sdata == ']' && _Aux == 1)
           {
              _Aux = 0;
              //Buffer (Dta) está cheio! -> LEDD01
              //Decodificar o Pacote
              DecodificaProtocolo();
           }
            else
              if (_Aux == 1)
               {
                 *Pot = sdata;
                  ++Pot;
                  //Não podemos incrementar Pot além do comprimento de Dta
               }
    PIR1.RCIF = 0;
   }

}



void main() {
  Init_cfgMCU();
  UART1_Init(9600);
  Delay_ms(100);
   //Configuração interrupção timer0
   Timers_Init(); //Configura interrupt global (INTCON)
   //Configuração da interrupção Serial
   PIR1.RCIF = 0;
   PIE1.RCIE = 1;
   tempoLed = start_timer(50);
   tempoSmsg = start_timer(500);

  while(TRUE)
    {
      if(FlagAutoReuso==1) //modo automatico
      {
        if((CIST1==0 || CIST2==0) && CIST_PRINC==0)ACIONA_V2V=0;  //aciona v2v (low signal)
        else
        ACIONA_V2V=1;
       }
      else  //modo manual
        if(CIST_PRINC==0&&FlagLigaV2V==1)
        {ACIONA_V2V=0;//liga V2V
         //send command desl flagLigaV2V
         }
        else
        {
         ACIONA_V2V=1;
         //flag retain on
         /*FlagLigaV2V=0;*/
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
   ANSELH = 0;      // (I/O digital)
   /*OPTION_REG         &= 0x7F;*/
   TRISB = 0x3F; //DIGITAL OUTPUT RB7-RB6 - DIGITAL INPUT RB0..5
   TRISA.TRISA0 = 0;
   /*WPUB = 0x3F;*/
   PORTB.RB6 = 1;
   PORTB.RB7 = 0;
   PORTA.RA0=0;
}

void DecodificaProtocolo()
 {
   unsigned char* tmp;
  //(Dta) -> [V2V1]  - aciona V2V 0:Off 1:On
  //(Dta) -> [AUT0] - liga reuso 0: manual , 1: automatico
  if(Dta[0] == 'V' && Dta[1] == '2' && Dta[2] == 'V')
    {FlagLigaV2V = (Dta[3] - '0');
     tmp = &FlagReenvmsg1;
     *tmp = 1;
    }   //Todo valor (0 a 9) ASCII pode ser convertido para número subtraindo por '0'
   else
  if(Dta[0] == 'A' && Dta[1] == 'U' && Dta[2] == 'T')
    {FlagAutoReuso = (Dta[3] - '0');
     tmp = &FlagReenvmsg2;
     *tmp = 1;
    }
 }
 
 void sendports()
 {
   SendStateProtocol(CIST1,"ED0");
   Delay_ms(10);
   SendStateProtocol(CIST2,"ED1");
   Delay_ms(10);
   SendStateProtocol(CIST_PRINC,"ED2");
   Delay_ms(10);
   SendStateProtocol(CX_RUA,"ED3");
   Delay_ms(10);
   SendStateProtocol(SOBRECARGA_CISTERNA,"ED4");
   Delay_ms(10);
   SendStateProtocol(SOBRECARGA_PISCINA,"ED5");
   Delay_ms(10);
   SendStateProtocol(!ACIONA_V2V,"V2V");
   Delay_ms(10);
   SendStateProtocol(FlagAutoReuso,"AUT");
   /*Delay_ms(10);
   SendStateProtocol(FlagAutoReuso,"AUT");
   Delay_ms(10);
   SendStateProtocol(ACIONA_V2V,"V2V");
   Delay_ms(10);
   SendStateProtocol(FlagLigaV2V,"F2=");*/
 }
 
 void SendStateProtocol(unsigned char GPIO, unsigned char txt[4])
 {//[rb01] -> portb.rb0 = 1
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
  UART1_Write('[');       //inicio do protocolo

    while(*retData != 0)
    {
      UART1_Write(*retData);   //Conteúdo do protocolo
      ++retData;
    }

   UART1_Write(']');    //fim do protocolo
   uart_rx_enable();
}

void Timers_Init()
{
 OPTION_REG         = 0x86;
 TMR0                 = 100; //10ms
 INTCON         = 0xE0;

 TMR0IF_bit = 0;
 TMR0IE_bit         = 1;
}

void Delay1()
{
 if(!timeout(tempoSmsg))return;
 sendports();
 tempoSmsg = start_timer(500);
}

void Delay2()
{
 if(!timeout(tempoLed))return;
 PORTB.RB7^=1; //ToggleLED
 tempoLed = start_timer(50);
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

   /*TRISE.TRISE0=0;
   LATE.RE0=1;  //RCO PINO R/T*/
   TRISA.TRISA0 = 0;
   PORTA.RA0=1;
}

void MBReceive_On_RS485( void )
{
    while (TXSTA.TRMT == 0) ;
   /*TRISE.TRISE0=0;
   LATE.RE0=0;  //RCO PINO R/T*/
   TRISA.TRISA0 = 0;
   PORTA.RA0=0;
}