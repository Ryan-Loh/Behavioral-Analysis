/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogReadSerial

  LEFT = - values, RIGHT = + values
*/
#include <math.h>
double xValue;
double avgX;
double sumX;
double numreads;
int Trigger = 0;
int leftTriggerPin = 8;
int rightTriggerPin = 9;
int  TriggerPin = 13;
float zeroVy1 = 2.51;
float zeroVy0 = 2.50;
float stepV = 0.145;
int numdelivered;
float latBallMotion;
int stopSign = 10001;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(115200);
  pinMode(A0, INPUT);
  pinMode(TriggerPin, INPUT);
  pinMode(leftTriggerPin, OUTPUT);
  pinMode(rightTriggerPin, OUTPUT);

  Trigger = 0;
  avgX = 0;
  sumX = 0;
  numreads = 50;

}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  Trigger = digitalRead(TriggerPin);

  avgX = 0;
  sumX = 0;
  for (int ii = 1; ii < numreads; ii++) {
    xValue = analogRead(A0);
    sumX = sumX + xValue;
  }
  avgX = sumX / numreads;

  avgX = 5 * (sumX / numreads) / 1024;
  avgX = round((avgX - zeroVy1) / stepV);
  latBallMotion = avgX * -4.5241;
  if (Trigger == HIGH) {
    Serial.println(latBallMotion, BIN);
  }
  if (Trigger == LOW) {
    Serial.println(99);
  }
}
