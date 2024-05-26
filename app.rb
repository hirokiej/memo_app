require 'sinatra'
require 'sinatra/reloader'
require 'json'

get '/' do

  if File.exist?('public/memos.json')
    memos = File.open('public/memos.json'){ |file| JSON.load(file) }
    @memos = memos || []
  else
    @memos =[]
  end
  erb :index
end

get '/new' do
  erb :new
end

post '/create' do
  memos = File.empty?('public/memos.json') ? [] : JSON.parse(File.read('public/memos.json'))
  title = params[:title]
  content = params[:content]
  id = memos.empty? ? 1 : memos.last['id'].to_i + 1
  memo = { 'id' => id, 'title' => title, 'content' => content}
  memos << memo
  File.open('public/memos.json', 'w' ) do |file|
    file.write(JSON.pretty_generate(memos))
  end
  redirect '/'
end

get '/memos/:id' do
  memo = File.open('public/memos.json'){ |file| JSON.load(file) }
  id = params[:id].to_i
  selected_memo = memo.find{ |memo| memo['id'] == id}
  @title = selected_memo['title']
  @content = selected_memo['content']
  @id = selected_memo['id']
  erb :memos
end

get '/memos/:id/edit' do
  memo = File.open('public/memos.json'){ |file| JSON.load(file) }
  id = params[:id].to_i
  selected_memo = memo.find{ |memo| memo['id'] == id}
  @title = selected_memo['title']
  @content = selected_memo['content']
  @id = selected_memo['id']
  erb :edit
end

patch '/memos/:id' do
  memo = File.open('public/memos.json'){ |file| JSON.load(file) }
  id = params[:id].to_i
  title = params[:title]
  content = params[:content]

  memo[id - 1] = { 'id' => id, 'title' => title, 'content' => content }
  File.open('public/memos.json', 'w' ) do |file|
    file.write(JSON.pretty_generate(memo))
  end
  redirect "/memos/#{id}"
end

delete '/memos/:id' do
  id = params[:id].to_i
  memos = File.open('public/memos.json'){ |file| JSON.load(file) }
  memos.delete_if{|memo| memo['id'] == id}
  File.open('public/memos.json', 'w' ) do |file|
    file.write(JSON.pretty_generate(memos))
  end
  redirect '/'
end