fork {
  puts "Starting DJ worker in a child process"
  Delayed::Worker.new.start
}
