class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method "#{name}" do
        instance_variable_get("@#{name}")
      end

      define_method("#{name}=") do |object|
        instance_variable_set("@#{name}", object)
      end
    end
  end
end


# class Cat
#   def favorite_color=(color)
#     @color = color
#   end
# end
