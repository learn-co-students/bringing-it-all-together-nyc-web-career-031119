class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
      SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    new_dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?;
      SQL
    new_dog = DB[:conn].execute(sql, id)[0]
    Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end

  def self.find_or_create_by(dog_attributes)
    sql = <<-SQL
      SELECT id
      FROM dogs
      WHERE name = ? AND breed = ?;
        SQL
    if !DB[:conn].execute(sql, dog_attributes[:name], dog_attributes[:breed])[0]
      self.create(dog_attributes)
    else
      self.find_by_id(DB[:conn].execute(sql, dog_attributes[:name], dog_attributes[:breed])[0][0])
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?;
      SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end
