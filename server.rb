require 'pg'
require 'sinatra'
require 'json'
require 'pry'

 def db_connection
  begin
    connection = PG.connect(dbname: 'slacker_news')

  yield(connection)

  ensure
    connection.close
  end
end


########## Test Methods ############

def test_title(title)
  if title == ""
    false
  end
end

def test_url(url)
  if !url.include?("http://") && !url.include?("https://") && !url.include?("www.")
    false
  end
end

def test_description(description)
  if description.length < 20
    false
  end
end

####################################

get '/' do
  query = "SELECT * FROM articles"
  articles = db_connection do |conn|
    conn.exec(query)
  end
  @articles = articles.to_a
  erb :index
end


get '/comment' do
  @errors
  erb :comment
end


post '/comment' do
  ptitle = params["title"]
  purl = params["url"]
  pdescription = params["description"]

  @errors = []

  if test_title(ptitle) == false
    @errors << "No title."
  end

  if test_url(purl) == false
    @errors << "Invalid URL."
  end

  if test_description(pdescription) == false
    @errors << "Description must be more than 20 characters."
  end


  if @errors.count >= 1
    erb :comment
  else
    articles = db_connection do |conn|
    query = "INSERT INTO articles (title, url, description, created_at) VALUES ('#{ptitle}', '#{purl}', '#{pdescription}', now())"
    conn.exec(query)
  end
  redirect '/'
  end
end
