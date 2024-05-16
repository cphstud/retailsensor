#include <Wire.h>
#include <ds3231.h>
#include <SD.h>
#include <SPI.h>

// Pins for SD-Card
int PIN_SPI_CS = 7;


// Initialize DS1302 RTC
struct ts t; 

const int trigPin = 2;
const int echoPin = 4;

#define BUFF_MAX 128

File dataFile;

// Timing
unsigned long previousMillis = 0;
const long interval = 250;  // 4 readings per second


void setup() {
  Serial.begin(9600);
   // Initialize RTC
  // Initialize RTC
Wire.begin();
DS3231_init(DS3231_CONTROL_INTCN);
/*----------------------------------------------------------------------------
In order to synchronise your clock module, insert timetable values below !
----------------------------------------------------------------------------*/
t.hour=10; 
t.min=30;
t.sec=0;
t.mday=13;
t.mon=5;
t.year=2024;

DS3231_set(t); 


  if (!SD.begin(PIN_SPI_CS)) {
    Serial.println(F("SD CARD FAILED, OR NOT PRESENT!"));
    while (1); // don't do anything more:
  }

  Serial.println(F("SD CARD INITIALIZED."));

  if (!SD.exists("arduino.txt")) {
    Serial.println(F("arduino.txt doesn't exist. Creating arduino.txt file..."));
    // create a new file by opening a new file and immediately close it
    dataFile = SD.open("arduino.txt", FILE_WRITE);
    dataFile.close();
  }

  // recheck if file is created or not
  if (SD.exists("arduino.txt")) {
    Serial.println(F("arduino.txt exists on SD Card."));
      // Create/Open a file for writing data
    dataFile = SD.open("arduino.txt", FILE_WRITE);
  // Write headers to file
    dataFile.println("Timestamp (ms), Distance (cm)");
  }
    // Initialize HC-SR04 Pins
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);


}

void loop() {
 
  unsigned long currentMillis = millis();
  char buff[BUFF_MAX];

  if (currentMillis - previousMillis >= interval) {
    //printTime();
    previousMillis = currentMillis;

    // Get the distance
    long distance = getDistance();

    // Get current timestamp
    //Time t = rtc.time();

    //const String day = dayAsString(t.day);
    //Serial.println(day);
    dataFile = SD.open("datalog.txt", FILE_WRITE);
 
    DS3231_get(&t);
    snprintf(buff, BUFF_MAX, "%d.%02d.%02d %02d:%02d:%02d", t.year,t.mon, t.mday, t.hour, t.min, t.sec);
    Serial.print("Date : ");
    if (dataFile) {
      
      dataFile.print(buff);
      dataFile.print(",");
      dataFile.println(distance);
      dataFile.close();
    } else {
      Serial.println("Error opening datalog.txt");
    }

    // Print data to Serial
    Serial.print("day: ");
    Serial.print(buff);
    Serial.print(", Distance: ");
    Serial.print(distance);
    Serial.println(" cm");
  }

}



// Function to get distance from HC-SR04
long getDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH);
  long distance = duration * 0.034 / 2;

  return distance;
}


