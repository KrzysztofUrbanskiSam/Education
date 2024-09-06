lucky_nums = [4, 8, 15, 16, 23, 42]

# num = 10 / 0

begin
  puts lucky_nums["100"]
  num = 10 / 0
rescue ZeroDivisionError
  puts "Oh no error zero division"

rescue TypeError => e
  puts e
  puts "Oh no Type error"
end

