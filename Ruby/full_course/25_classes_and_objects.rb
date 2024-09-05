class Book
  attr_accessor :title, :author, :pages

  def initialize(title, author, pages)
    puts ("Creating book " + title)
    @title = title # self.title also works
    @author = author
    @pages = pages
  end

end

b1 = Book.new("Lord of the Rings", "JRR", 425)
puts b1.title
