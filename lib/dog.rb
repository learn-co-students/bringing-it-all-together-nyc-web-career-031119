class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    attributes = {
      id: row[0],
      name: row[1],
      breed: row[2]
      }
    self.new(attributes)
  end

  def self.convert(db_array)
    db_array.map{|row| self.new_from_db(row)}
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.name = ?
    SQL
    convert(DB[:conn].execute(sql,name)).first
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs(name,breed)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    convert(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?",id)).first
  end

  def self.find_or_create_by(attributes)
    name = attributes[:name]
    breed = attributes[:breed]

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      self.find_by_id(dog[0][0])
    else
      self.create(attributes)
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?,
    breed = ?
    WHERE id = ?
    SQL

     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
