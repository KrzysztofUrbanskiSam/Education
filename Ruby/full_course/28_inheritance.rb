class Chef

  def make_chicken
    puts "The chef makes chicken"
  end

  def make_salad
    puts "The chef makes salad"
  end

  def make_special_dish
    puts "The chef makes special dish"
  end

end

class ItalianChef < Chef

  def make_pizza
    puts "Chef makes pizza"
  end

  def make_special_dish
    puts "The chef makes special dish  - pizza wihtout pineapple"
  end
end

chef = Chef.new()
chef.make_chicken

chef2 = ItalianChef.new()
chef2.make_pizza()
chef2.make_salad()
chef2.make_special_dish()
