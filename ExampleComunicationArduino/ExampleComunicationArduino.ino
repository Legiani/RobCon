//Program spínaní 4 pinu pomocí RobConu

//Konzoli nastavit na 9600
#include <SoftwareSerial.h>

//Definování MOTORU
#define MAZ 5  // Motand A doZADU
#define MAP 6  // Motand A doPREDU
#define MBP 11  // Motand B doPREDU
#define MBZ 10  // Motand B doZADU

//TX připojíme na Arduino D3
#define TX_PIN 3
 
//RX připojíme na Arduino D2
#define RX_PIN 2
 
//Vytvoří objekt pro komunikaci se zařízením
SoftwareSerial mySerial(TX_PIN,RX_PIN);

//proměnná pro příchozí příkaz
char command;
//proměnná pro předposlední příchozí znak
char secondCommand;

void setup() {
    //Definovani MOTORU
    pinMode(MAZ, OUTPUT);
    pinMode(MAP, OUTPUT);
    pinMode(MBP, OUTPUT);
    pinMode(MBZ, OUTPUT);

    //rychlost komunikace Arduina a BLE
    mySerial.begin(9600);

    //rychlost komunikace Arduino a PC
    Serial.begin(9600);
}
   
void loop() {
  //V případě aktivity v komunikaci
  if (mySerial.available()){
    //Zápis příchozího znaku do proměnné command a druhého příchozího znaku do secondCommand
    secondCommand = command;
    command = mySerial.read();

    //Kontrolní výpis příchozích znaku do PC
    Serial.write("\n A:");
    Serial.write(command);
    Serial.write("\n S:");
    Serial.write(secondCommand); 

    //Switch pro vyběr akce
    switch (command) {
      case 'n':
        digitalWrite(MAZ, LOW);
        digitalWrite(MAP, HIGH);
        break;
      case 'p':
        digitalWrite(MBZ, LOW);
        digitalWrite(MBP, HIGH);
        break;
      case 'd':
        digitalWrite(MAP, LOW);
        digitalWrite(MAZ, HIGH);
        break;
      case 'l':
        digitalWrite(MBP, LOW);
        digitalWrite(MBZ, HIGH);
        break;
      //"b" je negujcí prefix  
      case 'b':
        switch (secondCommand) {
          case 'n':
            digitalWrite(MAP, LOW);
            break;
          case 'p':
            digitalWrite(MBP, LOW);
            break;
          case 'd':
            digitalWrite(MAZ, LOW);
            break;
          case 'l':
            digitalWrite(MBZ, LOW);
            break;
        }
        break;
    }
  }
}
