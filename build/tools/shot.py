import socket,sys,time
from PIL import Image
S=sys.argv[1]; n=sys.argv[2]
c=socket.socket(socket.AF_UNIX); c.connect(S+'/mon.sock'); time.sleep(.5); c.recv(4096)
c.send(('screendump %s/%s.ppm\n'%(S,n)).encode()); time.sleep(2)
Image.open('%s/%s.ppm'%(S,n)).save('%s/%s.png'%(S,n))
