import socket,time,sys,json
S=sys.argv[1]; x=int(sys.argv[2]); y=int(sys.argv[3])
c=socket.socket(socket.AF_UNIX); c.connect(S+'/qmp.sock'); time.sleep(.3); c.recv(65536)
def q(o): c.send((json.dumps(o)+'\n').encode()); time.sleep(.3); return c.recv(65536)
q({"execute":"qmp_capabilities"})
ax=lambda a,v:{"type":"abs","data":{"axis":a,"value":v}}
q({"execute":"input-send-event","arguments":{"events":[ax("x",x*32767//1280),ax("y",y*32767//800)]}})
q({"execute":"input-send-event","arguments":{"events":[{"type":"btn","data":{"down":True,"button":"left"}}]}})
q({"execute":"input-send-event","arguments":{"events":[{"type":"btn","data":{"down":False,"button":"left"}}]}})
