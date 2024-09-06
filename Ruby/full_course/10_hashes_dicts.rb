states = {
  "New York"=> "NY",
  "California"=> "CA"
}

puts states
puts states["New York"]
puts states["California"]
puts states.include? "New York"

puts states.value? "NY"
puts states.length
puts states.keys
