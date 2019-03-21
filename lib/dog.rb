class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes={})
    @id = attributes[:id]
    @name = attributes[:name]
    @breed = attributes[:breed]
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, type TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    # new_dog = self.new(row)
    new_dog = self.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.create(attributes={})
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql,[name]).map { |row| self.new_from_db(row) }.first
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql,[id]).map { |row| self.new_from_db(row) }.first
  end

  def self.find_by_name_and_breed(name, breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL
    DB[:conn].execute(sql,[name], [breed]).map { |row| self.new_from_db(row) }
  end

  def self.find_or_create_by(attributes={})
    dogs = self.find_by_name_and_breed(attributes[:name], attributes[:breed])
    if dogs.empty?
      self.create(attributes)
    else
      dogs.first
    end
  end

  ### Instance methods ###
  def save
    if self.persist
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql,[self.name], [self.breed], [self.id])
  end

  def persist
    !!self.id
  end
end
