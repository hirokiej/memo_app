# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

conn ||= PG.connect( dbname: 'my_memo_db' )
conn.exec('CREATE TABLE IF NOT EXISTS memos(id SERIAL PRIMARY KEY, title TEXT NOT NULL, content TEXT NOT NULL)')

helpers do
  def escape_html(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = conn.exec('SELECT * FROM memos')
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  title = params[:title]
  content = params[:content]
  
  conn.exec_params('INSERT INTO memos (title, content) VALUES($1, $2)',[title, content])

  redirect '/'
end

get '/memos/:id' do
  id = params[:id]
  memos = conn.exec_params('SELECT * FROM memos WHERE id = $1',[id])

  @title = memos[0]['title']
  @content = memos[0]['content']
  erb :memos
end

get '/memos/:id/edit' do
  id = params[:id]
  memos = conn.exec_params('SELECT * FROM memos WHERE id = $1',[id])

  @id = id
  @title = memos[0]['title']
  @content = memos[0]['content']
  erb :edit
end

patch '/memos/:id' do
  id = params[:id]
  title = params[:title]
  content = params[:content]

  conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id])

  redirect "/memos/#{id}"
end

delete '/memos/:id' do
  id = params[:id]
  conn.exec_params('DELETE FROM memos WHERE ID = $1', [id])
  redirect '/'
end

not_found do
  status 404
  erb :oops
end
