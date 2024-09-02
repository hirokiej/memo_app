# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

CONN ||= PG.connect(dbname: 'my_memo_db')
CONN.exec('CREATE TABLE IF NOT EXISTS memos(id SERIAL PRIMARY KEY, title TEXT NOT NULL, content TEXT NOT NULL)')

helpers do
  def escape_html(text)
    Rack::Utils.escape_html(text)
  end

  def load_memos
    CONN.exec('SELECT * FROM memos')
  end

  def create_memo(title, content)
    CONN.exec_params('INSERT INTO memos (title, content) VALUES($1, $2)', [title, content])
  end

  def find_memo(id)
    CONN.exec_params('SELECT * FROM memos WHERE id = $1', [id])
  end

  def update_memo(title, content, id)
    CONN.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id])
  end

  def delete_memo(id)
    CONN.exec_params('DELETE FROM memos WHERE ID = $1', [id])
  end
end

get '/' do
  @memos = load_memos
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  create_memo(params[:title], params[:content])

  redirect '/'
end

get '/memos/:id' do
  memos = find_memo(params[:id])

  @title = memos[0]['title']
  @content = memos[0]['content']
  erb :memos
end

get '/memos/:id/edit' do
  memos = find_memo(params[:id])

  @id = params[:id]
  @title = memos[0]['title']
  @content = memos[0]['content']
  erb :edit
end

patch '/memos/:id' do
  update_memo(params[:title], params[:content], params[:id])

  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  delete_memo(params[:id])

  redirect '/'
end

not_found do
  status 404
  erb :oops
end
