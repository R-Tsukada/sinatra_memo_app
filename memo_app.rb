# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

class MemoApp
  def initialize(connection)
    @connection = connection
  end

  def self.connect_to_sql
    connection = PG.connect(
      host: 'localhost',
      user: 'ryotsukada',
      password: 'Aochan1123',
      dbname: 'memo_app'
    )
    MemoApp.new(connection)
  end

  def loading_sql_data
    sql_data = @connection.exec_params('SELECT * FROM Memo ORDER BY user_id')
    memos = {}
    sql_data.each do |datum|
      memos[datum['user_id']] = { 'memo_title' => datum['memo_title'], 'memo_text' => datum['memo_text'] }
    end
    memos
  end

  def data_create(memo_title, memo_text)
    sql = <<~SQL
      INSERT INTO Memo (memo_title, memo_text)
      VALUES($1, $2)
    SQL
    @connection.exec_params(sql, [memo_title, memo_text])
  end

  def data_delete(user_id)
    sql = <<~SQL
      DELETE FROM Memo
      WHERE user_id = $1
    SQL
    @connection.exec_params(sql, [user_id])
  end

  def data_edit(memo_title, memo_text, user_id)
    sql = <<~SQL
      UPDATE Memo
      SET memo_title = $1, memo_text = $2
      WHERE user_id = $3
    SQL
    @connection.exec_params(sql, [memo_title, memo_text, user_id])
  end
end

get '/' do
  memo = MemoApp.connect_to_sql
  @memo_list = memo.loading_sql_data
  erb :top
end

get '/new' do
  erb :post
end

post '/' do
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = MemoApp.connect_to_sql
  memo.data_create(memo_title, memo_text)
  redirect to('/')
  erb :post
end

get '/:id' do
  @id = params[:id]
  memo = MemoApp.connect_to_sql
  @memo_list = memo.loading_sql_data

  erb :show
end

delete '/:id' do
  @id = params[:id]
  memo = MemoApp.connect_to_sql
  memo.data_delete(@id)
  redirect to('/')
  erb :top
end

get '/:id/edit' do
  @id = params[:id]
  memo = MemoApp.connect_to_sql
  @memo_list = memo.loading_sql_data

  erb :edit
end

patch '/:id/edit' do
  @id = params[:id]
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = MemoApp.connect_to_sql
  memo.data_edit(memo_title, memo_text, @id)
  redirect to('/')
  erb :edit
end
