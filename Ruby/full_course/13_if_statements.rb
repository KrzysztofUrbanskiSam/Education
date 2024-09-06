ismale = true
istall = false

# Only bools in condition
if (ismale and istall)
  puts "You are male tall"

elsif ismale and !istall
  puts "You are short male"

else
  puts "You are female"
end
