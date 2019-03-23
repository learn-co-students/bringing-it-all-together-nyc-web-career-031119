class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: name, breed: breed)
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
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

  def self.new_from_db(row)
    new_dog = Dog.new
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog.id = row[0]
    new_dog
  end

  def self.all
    sql = "SELECT * FROM dogs"
    result = DB[:conn].execute(sql)
    result.map do |row|
      self.new_from_db(row)
    end
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    self.new_from_db(result)
    if result != nil
      self.new_from_db(result)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    if result != nil
      self.new_from_db(result)
    end
  end

  def self.find_by_breed(breed)
    sql = "SELECT * FROM dogs WHERE breed = ?"
    result = DB[:conn].execute(sql, breed)[0]
    if result != nil
      self.new_from_db(result)
    end
  end

  def self.find_or_create_by(attributes)
    dog_check =self.all.select do |dog|
      dog.name == attributes[:name] && dog.breed == attributes[:breed]
    end
    if dog_check.length == 0
      self.create(attributes)
    else
      dog_check[0]
    end
  end
end
