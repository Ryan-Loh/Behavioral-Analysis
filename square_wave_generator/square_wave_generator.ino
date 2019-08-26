//Square wave signal generator
//Enter freq: 'on-time' of square wave in ms
//Enter dfreq: 'down-time' of square wave in ms
//Enter numPulse: number of pulses of each signal
//Enter delaybtsig: delay between signals in ms

const int DATAPIN = 2;
int freq = 1;
int dfreq = 100;
int numPulse = 5;
int delaybtsig = 3000;

void setup()
{
  Serial.begin(9600);
  pinMode(DATAPIN, OUTPUT);
}

void loop()
{
  if (numPulse > 1) {
    for (int ii = 1; ii < numPulse; ii++) {
      digitalWrite(DATAPIN, HIGH);
      delay(freq);
      digitalWrite(DATAPIN, LOW);
      delay(dfreq);
    }
    delay(delaybtsig);
    return;
  }
  else if (numPulse == 1) {
    digitalWrite(DATAPIN, HIGH);
    delay(freq);
    digitalWrite(DATAPIN, LOW);
    delay(delaybtsig);
  }

}
