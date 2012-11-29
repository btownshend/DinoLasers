import hypermedia.net.*;    // import UDP library

UDP udp;  // define the UDP object (sets up)
 
/**
 * init
 */
void setup() {
 size(480,640);
 background(0);
 smooth();
  // create a new datagram connection on port 6000
  // and wait for incoming message
  udp = new UDP( this, 10552 ); 
  udp.log( true );        // <-- printout the connection activity
  udp.listen( true );
}

int boxSize = 100;
int x = -boxSize;

void draw() {
    if (x > width) {
        x = -boxSize;
    }
    fill(128);
    rect(x, height - boxSize, boxSize, boxSize);
    x++;
}
 
// void receive( byte[] data ) {            // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
   
   
  // get the "real" message =
  String message = new String( data );
  println("message: " + message);
  
  /*
  String[] parts = split(message, "&");
  
  int sentX = int(parts[0]);
  int sentY = int(parts[1]);    //"24" -> 24
   
   
  line(width-sentX , sentY , random(0, 480), 0);
  stroke (random(0, 150));
 
   
  // print the result
  println( "receive: x = \""+sentX+"\" y = \""+sentY+"\"");
  */
}


void keyPressed() {
    String statusString = udp.isClosed() ? "Closed" : "Open";
    println("Socket is: " + statusString);
}
 
