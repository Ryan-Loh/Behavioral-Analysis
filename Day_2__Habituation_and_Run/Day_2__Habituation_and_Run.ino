/*
Day 2+ Habituation and running:

This program:
1) Reads ball data of Vx0 (forward)
2) Converts raw-->voltage-->cm/s-->cm traveled
3) If (TRIGGER = HIGH) and cm traveled (thresh) surpasses value defined
  20ms of water will be delivered to pin 7 of board.
4) To visualize forward trajectory over time
  Tools -> Serial Plotter
  Scale plotter by changing threshold or Serial.print values.
*/


double xValue;
double avgX;
double sumX;
double numreads;
double trigger;
double timeStart;
double timeEnd;
double sampTime;
int waterPin;
int numdelivered;
int thresh;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  // triggerPin = A1
  // ballPin = A0
  Serial.begin(9600);
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  waterPin = 7;
  pinMode(waterPin, OUTPUT);
  avgX = 0;
  sumX = 0;
  trigger = 0;
  thresh = 10;
  numdelivered = 0;
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  avgX = 0;
  sumX = 0;
  trigger = analogRead(A1);
  while (trigger > 1000) {
    xValue = analogRead(A0);
    xValue = 5.00 * xValue / 1024;
    xValue = (round((xValue - 2.52) * 5.4480)/0.145) * (.012);
    if (xValue < 0){
      xValue = 0;
    }
    sumX = sumX + xValue;
    delay(1);
    Serial.print(0);
    Serial.print(" ");
    Serial.print(thresh);
    Serial.print(" ");
    Serial.print(thresh + 10);
    Serial.print(" ");
    Serial.println(sumX);
    trigger = analogRead(A1);
    if (trigger < 10 && sumX > thresh) {
      numdelivered = numdelivered + 1;
      digitalWrite(waterPin, HIGH);
      delay(20);
      digitalWrite(waterPin, LOW);
    }
  }
}
