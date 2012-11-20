import SocketServer
#from pylab import *

PORTNO = 10552

csvfile=open('accel.csv','wb');
cntr=0;
rrate=10;
t0=0;

class handler(SocketServer.DatagramRequestHandler):
    def handle(self):
        global cntr, t0
        newmsg = self.rfile.readline().rstrip()
        print "Client %s said ``%s''" % (self.client_address[0], newmsg)
        '''
        spmsg=newmsg.split(',');
        if cntr==0:
            t0=float(spmsg[1]);
        t=float(spmsg[1])-t0;
        scatter(t,float(spmsg[2]),hold=1);
        csvfile.write("%s,%f,%f,%f,%f\n"%(self.client_address[0],t,float(spmsg[2]),float(spmsg[3]),float(spmsg[4])));
        #  self.wfile.write(self.server.oldmsg)
        self.server.oldmsg = newmsg
        cntr=cntr+1;
        if mod(cntr,rrate)==0:
            draw();

        ion()
        '''
s = SocketServer.UDPServer(('',PORTNO), handler)
print "Awaiting UDP messages on port %d" % PORTNO
s.oldmsg = "This is the starting message."
s.serve_forever()
