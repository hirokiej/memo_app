# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

MEMOS_FILE = 'public/memos.json'

helpers do
  def escape_html(text)
    Rack::Utils.escape_html(text)
  end

  def load_memos
    File.exist?(MEMOS_FILE) ? JSON.parse(File.read(MEMOS_FILE)) : File.open(MEMOS_FILE, 'w') { |file| file.write([]) }
  end

  def save_memos(memos)
    File.open(MEMOS_FILE, 'w') do |file|
      file.write(JSON.generate(memos))
    end
  end

  def find_memo(id)
    load_memos.find { |memo| memo['id'] == id }
  end

  def find_memo_index(id)
    load_memos.each_with_index do |memo, index|
      return index if memo['id'] == id
    end
  end

  def calculate_new_memo_id
    memos = load_memos
    memos.empty? ? 1 : memos.last['id'].to_i + 1
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
  memos = load_memos
  title = params[:title]
  content = params[:content]
  id = calculate_new_memo_id
  memos << { 'id' => id, 'title' => title, 'content' => content }
  save_memos(memos)
  redirect '/'
end

get '/memos/:id' do
  @id = params[:id].to_i
  memo = find_memo(@id)
  @title = memo['title']
  @content = memo['content']
  erb :memos
end

get '/memos/:id/edit' do
  @id = params[:id].to_i
  memo = find_memo(@id)
  @title = memo['title']
  @content = memo['content']
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos

  id = params[:id].to_i
  title = params[:title]
  content = params[:content]

  memo = find_memo(id)
  index = find_memo_index(id)

  if memo
    memo['title'] = title
    memo['content'] = content
    memos[index] = memo
  else
    erb :oops
  end

  save_memos(memos)

  redirect "/memos/#{id}"
end

delete '/memos/:id' do
  id = params[:id].to_i
  memos = load_memos
  memos.delete_if { |memo| memo['id'] == id }
  save_memos(memos)
  redirect '/'
end

not_found do
  status 404
  erb :oops
end
