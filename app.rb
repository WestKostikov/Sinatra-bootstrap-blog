require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
  db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'insert into Barbers (name) values (?)', [barber]
      end    
  end
end

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

before do
  db = get_db
  @barbers = db.execute 'select * from Barbers'
end

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS "Users"
    (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "username" TEXT,
      "phone" TEXT,
      "datetime" TEXT,
      "barber" TEXT,
      "color" TEXT
    )'

    'CREATE TABLE IF NOT EXISTS "Barbers" (
  "id"  INTEGER,
  "name"  TEXT,
  PRIMARY KEY("id" AUTOINCREMENT)
)'

  seed_db db, ['Даниил', 'Павел', 'Егор', 'Максим', 'Артём', 'Дмитрий']

end

def save_form_data_to_database
  db = get_db
  db.execute 'INSERT INTO Users (username, phone, datetime, barber, color)
  VALUES (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]
  db.close
end


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/About' do
	erb :about
end

get '/Visit' do
	erb :visit
end

get '/Contacts' do
	erb :contacts
end

post '/Visit' do
	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

  save_form_data_to_database

	# хеш для валидации параметров
hh = { 	:username => 'Введите имя',
  		:phone => 'Введите телефон',
  		:datetime => 'Введите дату и время' }

  	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

  	if @error != ''
    return erb :visit
  end

 
  
	erb "<h2>Отлично, Вы записались!</h2>"
end


get '/showusers' do
    db = get_db

    @results = db.execute 'select * from Users order by id desc'

    erb :showusers
end


