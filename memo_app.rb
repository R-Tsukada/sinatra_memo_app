require 'sinatra'
require 'sinatra/reloader'
require 'json'

=begin
class MyApp < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  def initialize(json_file_path, json, json_data, list)
    @json_file_path = json_file_path
    @json = json
    @json_data = json_data
    @list = list
  end

  def self.json_data
    json_file_path = './memo.json'
    json = File.open(json_file_path).read
    json_data = JSON.parse(json)
    list = json_data["memos"]
    MyApp.new(json_file_path, json, json_data, list)
  end
=end
json_file_path = './memo.json'
json = File.open(json_file_path).read
json_data = JSON.parse(json)
list = json_data["memos"]

# ------------------トップページ----------------------
get '/' do
  @lists = list
  erb :top
end

# ------------------メモ新規作成----------------------
get '/new' do
  erb :post
end

post '/' do
  @title = params[:title]
  @text = params[:text]

  list.push({ "id" => json_data["memos"].size + 1, "title" => @title, "text" => @text })

  #ファイルの保存
  File.open(json_file_path, 'w') do |io|
    JSON.dump(json_data, io)
  end

  redirect to('/')
  erb :post
end

# ------------------メモ詳細----------------------
get '/:id' do
  @id = params[:id]

  @lists = list
  @lists.each do |file|
    if file["id"] == @id.to_i
      @title = file["title"]
      @text = file["text"]
    end
  end

  erb :show
end

delete '/:id' do
  @id = params[:id]

  @lists = list
  @lists.delete_at(@id.to_i - 1)

  # ファイルの保存
  File.open(json_file_path, 'w') do |io|
    JSON.dump(json_data, io)
  end

  redirect to('/')
  erb :top
end

# ------------------メモ編集----------------------
get '/:id/edit' do
  @id = params[:id]

  @lists = list
  @lists.each do |file|
    if file["id"] == @id.to_i
      @title = file["title"]
      @text = file["text"]
    end
  end

  erb :edit
end

patch '/:id/edit' do
  @id = params[:id]
  @memo_title = params[:memo_title]
  @memo_text = params[:memo_text]

  list[@id.to_i - 1] = { "id" => @id.to_i, "title" => @memo_title, "text" => @memo_text }

  # ファイルの保存
  File.open(json_file_path, 'w') do |io|
    JSON.dump(json_data, io)
  end

  redirect to('/')
  erb :edit
end
