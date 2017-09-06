class Dog
  require 'pry'


  attr_accessor :name, :breed
  attr_reader :id


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(props)
    dog = self.new(props)
    dog.save
  end

  def self.find_by_id(x)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, x).map do |props|
      self.new_from_db(props)
    end[0]
  end

  def self.find_or_create_by(props)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, props[:name], props[:breed])
    if !dog.empty?
      props = dog[0]
      dog = self.new_from_db(props)
    else
      dog = self.create(props)
    end
    dog
  end

  def self.new_from_db(props)
    @id = props[0]
    @name = props[1]
    @breed = props[2]
    new_hash = {id: @id, name: @name, breed: @breed}
    self.new(new_hash)
  end

  def self.find_by_name(name)
     sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = ?
     SQL

    DB[:conn].execute(sql, name).map do |props|
      dog = self.new_from_db(props)
    end[0]


  end

  def initialize(props)
    @id = props[:id]
    @name = props[:name]
    @breed = props[:breed]
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
