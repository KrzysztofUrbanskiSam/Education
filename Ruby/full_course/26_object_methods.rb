class Student

  attr_accessor :name, :major, :gpa

  def initialize(name, major, gpa)
    @name = name
    @major = major
    @gpa = gpa
  end

  def has_honors()
    return @gpa > 4.0
  end

end

s1 = Student.new("Krzysztof", "Automatics", 3.4)
s2 = Student.new("Tom", "Art", 4.7)

puts s1.has_honors()
puts s2.has_honors()
