friends = Array["Kevin", "Oskar", 1, 2, 3, false]

puts friends

puts "--------------" * 2
puts friends[0, 20]
puts friends[-1]

puts "--------------" * 2
friends[0] = "Adam"
puts friends[0]

puts "--------------" * 2
# Just empty start array
cars = Array.new
cars[0] = "Porsche"
cars[1] = "Seat" # But we can insert into 10th position
cars.append("Peugeot")
puts cars
puts cars.length()
puts cars.include? "Seat"
puts cars.include? "eat"
puts cars.reverse()

puts "============="
puts cars.sort

