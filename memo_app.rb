# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

json_file_path = './memo.json'
json = File.open(json_file_path).read
json_data = JSON.parse(json)
list = json_data['memos']

def update_json_file(json_file_path, json_data)
  File.open(json_file_path, 'w') do |io|
    JSON.dump(json_data, io)
  end
end

def add_memo_elements_to_json_file(list, json_data)
  list.push({ 'id' => json_data['memos'].size + 1, 'title' => @title, 'text' => @text })
end

def change_the_elements_of_json(list)
  list[@id.to_i - 1] = { 'id' => @id.to_i, 'title' => @memo_title, 'text' => @memo_text }
end

def name_and_text_that_matches_id_from_json(list)
  list.each do |file|
    if file['id'] == @id.to_i
      @title = file['title']
      @text = file['text']
    end
  end
end

get '/' do
  @lists = list
  erb :top
end

get '/new' do
  erb :post
end

post '/' do
  @title = params[:title]
  @text = params[:text]

  add_memo_elements_to_json_file(list, json_data)

  update_json_file(json_file_path, json_data)

  redirect to('/')
  erb :post
end

get '/:id' do
  @id = params[:id]

  name_and_text_that_matches_id_from_json(list)

  erb :show
end

delete '/:id' do
  @id = params[:id]

  list.delete_at(@id.to_i - 1)

  update_json_file(json_file_path, json_data)

  redirect to('/')
  erb :top
end

get '/:id/edit' do
  @id = params[:id]

  name_and_text_that_matches_id_from_json(list)

  erb :edit
end

patch '/:id/edit' do
  @id = params[:id]
  @memo_title = params[:memo_title]
  @memo_text = params[:memo_text]

  change_the_elements_of_json(list)

  update_json_file(json_file_path, json_data)

  redirect to('/')
  erb :edit
end
