class RxPacket {
  late int gyroYaw;
  late int gyroPitch;
  late int gyroRoll;
  late int accX;
  late int accY;
  late int accZ;
  late int bikeBattery; //
  late int bikeSpeed; // in mph
  late int bikeMode;
}

class TxPacket {
  late int bikeMode;
  late int lightsRed;
  late int lightsGreen;
  late int lightsBlue;
  late int lightsAlpha;
}
