
#include <Servo.h>

// CONFIGURE
#define D1_ROTATION_PIN   2 // S00
#define D1_FRONT_LEG_PIN  3 // S01...
#define D1_BACK_LEG_PIN   4 // S02
#define D1_HEAD_PIN       5 // S03
#define D2_PIN            6
#define D3_PIN            7
#define D4_PIN            8
#define D5_PIN            9
#define LED1_RED_PIN      10  // L00
#define LED1_GREEN_PIN    11  // L01
#define LED1_BLUE_PIN     12  // L02
// END CONFIGURE

#define NUM_LEDS          3
#define NUM_SERVOS        8
int servoPins[] = { D1_ROTATION_PIN,     // S00
                    D1_FRONT_LEG_PIN,    // S01
                    D1_BACK_LEG_PIN,     // S02 ...
                    D1_HEAD_PIN,
                    D2_PIN,
                    D3_PIN,
                    D4_PIN,
                    D5_PIN
                  };
int ledPins[] = { LED1_RED_PIN,
                  LED1_GREEN_PIN,
                  LED1_BLUE_PIN 
                };

#define p(x) Serial.print(x)

#define UPDATE_TIME      25

Servo servos[NUM_SERVOS];
float currAngles[NUM_SERVOS];
float toAngles[NUM_SERVOS];
unsigned long toTimes[NUM_SERVOS];
unsigned long lastUpdateTime = 0;


void setup()
{
  Serial.begin(115200);
  Serial.println("Starting");
  
  for (int i = 0; i < NUM_SERVOS; i++) {
    servos[i].attach(servoPins[i]);
    currAngles[i] = 90;
    toAngles[i] = 0;
    toTimes[i] = 0;
  }
  for (int i = 0; i < NUM_LEDS; i++) {
    pinMode(ledPins[i], OUTPUT);
    analogWrite(ledPins[i], 0);
  }
  Serial.println("Setup");  
}

String inBuffer = "";         // a string to hold incoming data
boolean cmdComplete = false;  // whether the string is complete

void serialEvent() {
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    Serial.println(inChar); 
    inBuffer += inChar;
    if (inChar == '\n') {
      cmdComplete = true;
      Serial.println("Got command: "); p(inBuffer); Serial.println();
    }
  }
}

void loop()
{
  // parse command if finished
  if (cmdComplete) {
    cmdComplete = false;
    String cmd = inBuffer;
    inBuffer = "";
    
    // e.g. S011200450 or L0099
    if (cmd.length() == 11 && cmd[0] == 'S') {
      int servoNum = cmd.substring(1,3).toInt();
      int toAngle  = cmd.substring(3,6).toInt();
      int time     = cmd.substring(6,10).toInt();

      if (servoNum >= NUM_SERVOS) {
        p("Invalid servo: "); p(servoNum); Serial.println();
        return;
      }
      
      toAngles[servoNum] = toAngle;
      toTimes[servoNum] = time + millis();
      p("Parsed command "); p(servoNum); p(" "); p(toAngle); p(" "); p(time); p("\n");
    } else if (cmd.length() == 6 && cmd[0] == 'L') {
      int ledNum = cmd.substring(1,3).toInt();
      int brightness  = cmd.substring(3,5).toInt();   
      
      if (ledNum >= NUM_LEDS) {
        p("Invalid led: "); p(ledNum); Serial.println();
        return;
      }      
      brightness = brightness*255/100;
      analogWrite(ledPins[ledNum], brightness);
      p("Writing "); p(brightness); p(" for led "); p(ledNum); p("\n");
    }
  }
  
  if (millis() - lastUpdateTime > UPDATE_TIME) {
    lastUpdateTime = millis();
    
    for (int i = 0; i < NUM_SERVOS; i++) {
      if (millis() >= toTimes[i])
        continue;
      
      int periodsLeft = ceil(float(toTimes[i] - millis()) / UPDATE_TIME);
      if (periodsLeft == 0)
        periodsLeft = 1;
      float angle = (toAngles[i] - currAngles[i]) / periodsLeft + currAngles[i];
      p("Servo="); p(i); p(" from angle="); p(currAngles[i]); p(" periodsLeft="); p(periodsLeft); p(" to angle="); p(angle); Serial.println();
      servos[i].write(int(angle));
      currAngles[i] = angle;
    }
  }
}
     