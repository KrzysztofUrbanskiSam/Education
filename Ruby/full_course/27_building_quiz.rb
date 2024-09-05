class Question
  attr_accessor :prompt, :answer

  def initialize(prompt, answer)
    @prompt = prompt
    @answer = answer
  end
end

p1 = "What color are apples?\n(a)red\n(b)purple\n(c)violet"
p2 = "What color are bananas?\n(a)red\n(b)purple\n(c)yellow"
p3 = "What color are pears\n(a)yellow\n(b)green\n(c)orange"


questions = [
  Question.new(p1, "a"),
  Question.new(p2, "c"),
  Question.new(p3, "b")
]

def run_test(questions)
  answer = ""
  score = 0

  for qustion in questions
    puts qustion.prompt
    answer = gets.chomp()

    if answer == qustion.answer
      score += 1
    end

  end

  puts ("You got "+ score.to_s + "/" + questions.length().to_s)
end

run_test(questions)