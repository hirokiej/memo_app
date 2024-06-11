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
    if File.exist?(MEMOS_FILE)
      File.open(MEMOS_FILE) { |file| JSON.parse(file.read) }
    else
      []
    end
  end

  def save_memos(memos)
    File.open(MEMOS_FILE, 'w') do |file|
      file.write(JSON.generate(memos))
    end
  end

  def find_memo(id)
    memos = load_memos
    memos.find { |memo| memo['id'] == id }
  end

  def cal_memo_id(memos)
    memos.empty? ? 1 : memos.last['id'].to_i + 1
  end
end

get '/' do
  if File.exist?(MEMOS_FILE)
    memos = load_memos
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
  memos = load_memos
  title = params[:title]
  content = params[:content]
  id = cal_memo_id(memos)
  memo = { 'id' => id, 'title' => title, 'content' => content }
  memos << memo
  save_memos(memos)
  redirect '/'
end

get '/memos/:id' do
  id = params[:id].to_i
  memo = find_memo(id)
  @title = memo['title']
  @content = memo['content']
  @id = memo['id']
  erb :memos
end

get '/memos/:id/edit' do
  id = params[:id].to_i
  memo = find_memo(id)
  @title = memo['title']
  @content = memo['content']
  @id = memo['id']
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  id = params[:id].to_i
  title = params[:title]
  content = params[:content]
  memo = find_memo(id)
  if memo
    memo['title'] = title
    memo['content'] = content
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
