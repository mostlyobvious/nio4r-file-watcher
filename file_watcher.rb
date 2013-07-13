require 'nio'
require 'rb-kqueue'

Thread.new do
  File.open('dummy.log', 'w') do |f|
    f.sync = true

    10.times do |i|
      f.puts(i)
      sleep(1)
    end
  end
end

mark = 0
file = File.open('dummy.log')

queue = KQueue::Queue.new
queue.watch_file('dummy.log', :write) do
  file.seek(mark)
  stat = file.stat
  mark = stat.size
  data = file.read
  puts data unless data.empty?
end

selector = NIO::Selector.new
selector.register(IO.new(queue.fd), :r)

loop do
  selector.select do
    queue.process
  end
end
