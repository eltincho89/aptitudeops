import socket,time,sys
S=sys.argv[1]
c=socket.socket(socket.AF_UNIX); c.connect(S+'/mon.sock'); time.sleep(.5); c.recv(4096)
for k in sys.argv[2:]:
    if k.startswith('sleep'): time.sleep(float(k[5:])); continue
    c.send(('sendkey %s\n'%k).encode()); time.sleep(.25)
