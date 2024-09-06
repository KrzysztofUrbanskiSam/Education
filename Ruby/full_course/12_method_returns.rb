
def cube(num)
  return num ** 3, "Hi" # return can be omitted
end

puts cube 3
cube 4 # No print
puts cube 6

puts cube(7)[0]