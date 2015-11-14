require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @db_data ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      from
        "#{self::table_name}"
    SQL
    @db_data.first.map! {|column| column.to_sym}
  end

  def self.finalize!
    columns = self.columns
    columns.each do |column|
      define_method("#{column}") do
        attributes["#{column}".to_sym]
      end

      define_method("#{column}=") do |value|
        attributes["#{column}".to_sym] = value
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    to_s.downcase + "s"
  end

  def self.all
    array_of_hashes = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
  SQL
  parse_all(array_of_hashes)
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end
    objects
  end

  def self.find(id)
    db_entry = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?
    SQL
    self.parse_all(db_entry).first
  end

  def initialize(params = {})
    params.each do |param_name, value|
      attr_sym = param_name.to_sym
      raise "unknown attribute '#{param_name}'" unless self.class.columns.include?(attr_sym)
      send("#{param_name}=",value)
    end
  end

  def attributes
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    attributes.values
  end

  def insert
    columns = self.class.columns.join(", ")
    num_question_marks = columns.size
    column_names = "(#{columns})"
    question_marks = []
    num_question_marks.times do
      question_marks << "?"
    end
    question_string = "(#{question_marks.join(",")})"
    query_string = <<-SQL
    INSERT INTO
      #{self.table_name} #{column_names}
    VALUES
      question_string
    SQL
    DBConnection.execute(query_string, *attribute_values) #we need to pass values to be sanatized by SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
