File.open("employees.txt", "r") do |file|
  puts file.read()
  puts file.read().include? "Tom"

  # Cannot use those below since in 2nd line I already read entire file
  # puts file.readline() # first line
  # puts file.readline() # next line

end

puts "-"*20
File.open("employees.txt", "r") do |file|

  for line in file.readlines()
      puts line
  end
end

puts "-"*20
file1 = File.open("employees.txt", "r")
puts file1.read()
puts file1.read().include? "Celina"
file1.close()