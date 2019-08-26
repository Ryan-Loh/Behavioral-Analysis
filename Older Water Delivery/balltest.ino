/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/AnalogReadSerial
*/
double xValue;
double avgX;
double sumX;
double numreads;
int  waterPin;
int numdelivered;

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  pinMode(A0, INPUT);
  pinMode(waterPin, OUTPUT);
  waterPin = 7;
  avgX = 0;
  sumX = 0;
  numdelivered = 0;
  numreads = 100;
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  avgX = 0;
  sumX = 0;
  for (int ii = 1; ii < numreads; ii++) {
    xValue = analogRead(A0);
    sumX = sumX + xValue;
  }
  avgX = sumX / numreads;
  avgX = avgX * (5.0 / 1024);
  avgX = avgX - 2.49;
  if (avgX > 0.2) {
    numdelivered = numdelivered + 1;
    digitalWrite(waterPin, HIGH);
    delay(20);
    digitalWrite(waterPin, LOW);
    Serial.print("Water Delivered: ");
    Serial.println(numdelivered);
    delay(1000);
  }

}
