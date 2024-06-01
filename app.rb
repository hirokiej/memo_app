# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

MEMOS_FILE = 'public/memos.json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def load_memos(memos_file)
    File.open(memos_file) { |file| JSON.parse(file.read) }
  end

  def save_memos(memos)
    File.open(MEMOS_FILE, 'w') do |file|
      file.write(JSON.pretty_generate(memos))
    end
  end

  def find_memo(memos, id)
    memos.find { |memo| memo['id'] == id }
  end
end

get '/' do
  if File.exist?(MEMOS_FILE)
    memos = load_memos(MEMOS_FILE)
    @memos = memos || []
  else
    @memos = []
  end
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  memos = File.empty?(MEMOS_FILE) ? [] : JSON.parse(File.read(MEMOS_FILE))
  title = params[:title]
  content = params[:content]
  id = memos.empty? ? 1 : memos.last['id'].to_i + 1
  memo = { 'id' => id, 'title' => title, 'content' => content }
  memos << memo
  save_memos(memos)
  redirect '/'
end

get '/memos/:id' do
  memos = load_memos(MEMOS_FILE)
  id = params[:id].to_i
  selected_memo = find_memo(memos, id)
  @title = selected_memo['title']
  @content = selected_memo['content']
  @id = selected_memo['id']
  erb :memos
end

get '/memos/:id/edit' do
  memos = load_memos(MEMOS_FILE)
  id = params[:id].to_i
  selected_memo = find_memo(memos, id)
  @title = selected_memo['title']
  @content = selected_memo['content']
  @id = selected_memo['id']
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos(MEMOS_FILE)
  id = params[:id].to_i
  title = params[:title]
  content = params[:content]
  selected_memo = find_memo(memos, id)
  if selected_memo
    selected_memo['title'] = title
    selected_memo['content'] = content
  end
  save_memos(memos)
  redirect "/memos/#{id}"
end

delete '/memos/:id' do
  id = params[:id].to_i
  memos = load_memos(MEMOS_FILE)
  memos.delete_if { |memo| memo['id'] == id }
  save_memos(memos)
  redirect '/'
end

not_found do
  status 404
  erb :oops
end
