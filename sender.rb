require 'socket'

class RrdPdSender
  def self.configure(ip, port=6311)
    @address = "127.0.0.1"
    @port = port
  end

  def self.send(*args)
    return unless @address && @port
    message = args.join('')
    udp.send(message, 0, @address, @port)
  end

  def self.task(message, &block)
    started = Time.now.to_f
    res = block.call
    elapsed = Time.now.to_f - started
    send(message, ':', elapsed)
    res
  end

  def self.udp
    @udp ||= begin
      Socket.do_not_reverse_lookup = true
      UDPSocket.new
    end
  end
end

if __FILE__ == $0
  RrdPdSender.configure("127.0.0.1")

  interrupted = false
  trap("INT") { interrupted = true }
  keys = [
    { :name => "PING", :range => [] },
    { :name => "TEST", :range => [0, 100] },
    { :name =>  "FOO", :range => [100, 500] },
    { :name =>  "BAR", :range => [300, 1000] }
  ]
  loop do
    keys.each do |key|
      chance = Math.cos((Time.now.min - 30) / 60.0 * 2) * 65.0 + 10
      next if rand(100) > chance
      message = [ key[:name] ]
      unless key[:range].empty?
        message << ":"
        message << (rand(key[:range][1] - key[:range][0]) + key[:range][0]).to_s
      end
      RrdPdSender.send(*message)
    end
    sleep(0.25)
    break if interrupted
  end
end
