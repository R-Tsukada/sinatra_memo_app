require 'sinatra'
require 'sinatra/reloader'
require 'json'

json_file_path = './memo.json'
json = File.open(json_file_path).read
json_data = JSON.parse(json)
list = json_data["memos"]

def file_save_to_json(json_file_path, json_data)
  File.open(json_file_path, 'w') do |io|
    JSON.dump(json_data, io)
  end
end

def new_file(list, json_data)
  list.push({ "id" => json_data["memos"].size + 1, "title" => @title, "text" => @text })
end

def change_file(list)
  list[@id.to_i - 1] = { "id" => @id.to_i, "title" => @memo_title, "text" => @memo_text }
end

def file_title_and_text(list)
  list.each do |file|
    if file["id"] == @id.to_i
      @title = file["title"]
      @text = file["text"]
    end
  end
end

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

  new_file(list, json_data)

  #ファイルの保存
  file_save_to_json(json_file_path, json_data)

  redirect to('/')
  erb :post
end

# ------------------メモ詳細----------------------
get '/:id' do
  @id = params[:id]

  file_title_and_text(list)

  erb :show
end

delete '/:id' do
  @id = params[:id]

  @lists = list
  @lists.delete_at(@id.to_i - 1)

  # ファイルの保存
  file_save_to_json(json_file_path, json_data)

  redirect to('/')
  erb :top
end

# ------------------メモ編集----------------------
get '/:id/edit' do
  @id = params[:id]

  file_title_and_text(list)

  erb :edit
end

patch '/:id/edit' do
  @id = params[:id]
  @memo_title = params[:memo_title]
  @memo_text = params[:memo_text]

  change_file(list)

  # ファイルの保存
  file_save_to_json(json_file_path, json_data)

  redirect to('/')
  erb :edit
end
#end
