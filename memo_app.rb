require 'sinatra'
require 'sinatra/reloader'
require 'json'

  def json
    json_file_path = './memo.json'
    json = File.open(json_file_path).read
    json_data = JSON.parse(json)
  end

  def json_load(json_file_path, json, json_data)
    @json_file_path = json_file_path
    @json = json
    @json_data = json_data
    @list = @json_data["memos"]
  end

  # ------------------トップページ----------------------
  get '/' do
    @contents= File.open("memo.json") do |file|
      JSON.load(file)
    end
    erb :top
  end

  # ------------------メモ新規作成----------------------
  get '/new' do
    erb :post
  end

  post '/' do
    @title = params[:title]
    @text = params[:text]
    json_file_path = './memo.json'
    json = File.open(json_file_path).read
    json_data = JSON.parse(json)
    list = json_data["memos"]
    list.push({ "id" => json_data["memos"].size + 2, "title" => @title, "text" => @text})

    File.open(json_file_path, 'w') do |io|
      JSON.dump(json_data, io)
    end

    redirect to('/')
    erb :post
  end

  # ------------------メモ詳細----------------------
  get '/:id' do
    @id = params[:id]
    @contents = File.open("memo.json") do |file|
      JSON.load(file)
    end
    erb :show
  end

  delete '/:id' do
    @id = params[:id]
    json_file_path = './memo.json'

    json_data = File.open(json_file_path) do |io|
      JSON.load(io)
    end

    json_data["memos"].delete_at(@id.to_i - 2)

    File.open(json_file_path, 'w') do |io|
      JSON.dump(json_data, io)
    end

    redirect to('/')
    erb :top
  end

  # ------------------メモ編集----------------------
  get '/:id/edit' do
    @id = params[:id]
    @contents = File.open("memo.json") do |file|
      JSON.load(file)
    end
    erb :edit
  end

  patch '/:id/edit' do
    @id = params[:id]
    @memo_title = params[:memo_title]
    @memo_text = params[:memo_text]

    json_file_path = './memo.json'
    json = File.open(json_file_path).read
    json_data = JSON.parse(json)
    list = json_data["memos"]
    list[@id.to_i - 1] = { "id" => @id.to_i, "title" => @memo_title, "text" => @memo_text }

    File.open(json_file_path, 'w') do |io|
      JSON.dump(json_data, io)
    end

    redirect to('/')
    erb :edit
  end
