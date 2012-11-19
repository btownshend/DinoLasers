This is a short demo application in python that receives accelerometer data from an iOS device via UDP.  It makes use of the App Store application, "Accelerometer Data Pro" by Wavefront Labs ($4.99).   

The python code receives continuous updates from iOS devices running the app on the same subnet of a LAN, connected via WiFi.   It both plots the data stream and logs the values to a CSV file for further analysis.  Each line includes the IP address of the device, a timestamp, and then the x,y,z accelaration values.

Note that for the final application, it would be preferable to develop a new app that also sends the gyroscope data from the iPhone 4 and later to allow separation of tilt information from acceleration.

Brent Townshend
11/19/2012
