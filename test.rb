require 'socket'

Socket.do_not_reverse_lookup = true
udp = UDPSocket.new
udp.send("TEST:10", 0, "127.0.0.1", 6311)
