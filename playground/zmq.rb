require 'zmq'


context ZMQ::Context.new(1)

push_thread  = Thread.new do
  #Here we're creating our first socket. Sockets should not be shared among threads.
  push_sock = context.socket(ZMQ::DOWNSTREAM)
  #error_check(push_sock.setsockopt(ZMQ::LINGER, 0))
  p 'bind', push_sock.bind('tcp://127.0.0.1:2200')

  7.times do |i|
    msg = "#{i + 1} Potato"
    puts "Sending #{msg}"

    #This will block till a PULL socket connects`
    push_sock.send(msg)

    sleep 0.5
  end

  # always close a socket when we're done with it otherwise
  # the context termination will hang indefinitely
  push_sock.close
end

#Here we create two pull sockets, you'll see an alternating pattern
#of message reception between these two sockets
pull_threads = Array.new(2) do |i|
  Thread.new do
    pull_sock = context.socket(ZMQ::UPSTREAM)
    #pull_sock.setsockopt(ZMQ::LINGER, 0))
    sleep 1
    puts "Pull #{i} connecting"
    pull_sock.connect('tcp://127.0.0.1:2200')

    #Here we receive message strings; allocate a string to receive
    # the message into
    message = ''
    #On termination sockets raise an error where a call to #recv_string will
    # return an error, lets handle this nicely
    #Later, we'll learn how to use polling to handle this type of situation
    #more gracefully
    #while ZMQ::Util.resultcode_ok?(rc)
    loop do
      message = pull_sock.recv
      puts "Pull#{i}: I received a message '#{message}'"
    end

    # always close a socket when we're done with it otherwise
    # the context termination will hang indefinitely
    pull_sock.close
    puts "Socket closed; thread terminating"
  end
end


#Wait till we're done pushing messages
push_thread.join
puts "Done pushing messages"

#Terminate the context to close all sockets
p context.close
puts "Close context"

#Wait till the pull threads finish executing
pull_threads.each { |t| t.join }

puts "Done!"

