# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

class MemoApp
  def initialize(connection)
    @connection = connection
  end

  def self.connect_to_sql
    connection = PG.connect(
      host: 'localhost',
      user: 'ryotsukada',
      password: ENV['password'],
      dbname: 'memo_app'
    )
    MemoApp.new(connection)
  end

  def find_memos
    @connection.exec_params('SELECT * FROM Memo ORDER BY memo_id')
  end

  def find_memo_by_id(memo_id)
    @connection.exec_params('SELECT * FROM Memo WHERE memo_id = $1', [memo_id]).first
  end

  def create_memos(memo_title, memo_text)
    sql = <<~SQL
      INSERT INTO Memo (memo_title, memo_text)
      VALUES($1, $2)
    SQL
    @connection.exec_params(sql, [memo_title, memo_text])
  end

  def delete_memos(memo_id)
    sql = <<~SQL
      DELETE FROM Memo
      WHERE memo_id = $1
    SQL
    @connection.exec_params(sql, [memo_id])
  end

  def edit_memos(memo_title, memo_text, memo_id)
    sql = <<~SQL
      UPDATE Memo
      SET memo_title = $1, memo_text = $2
      WHERE memo_id = $3
    SQL
    @connection.exec_params(sql, [memo_title, memo_text, memo_id])
  end
end

get '/' do
  memo = MemoApp.connect_to_sql
  @memo = memo.find_memos
  erb :top
end

get '/new' do
  erb :post
end

post '/' do
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = MemoApp.connect_to_sql
  memo.create_memos(memo_title, memo_text)
  redirect to('/')
  erb :post
end

get '/:id' do
  @id = params[:id]
  sql = MemoApp.connect_to_sql
  @memo = sql.find_memo_by_id(@id)
  erb :show
end

delete '/:id' do
  @id = params[:id]
  memo = MemoApp.connect_to_sql
  memo.delete_memos(@id)
  redirect to('/')
  erb :top
end

get '/:id/edit' do
  @id = params[:id]
  memo = MemoApp.connect_to_sql
  @memo = memo.find_memo_by_id(@id)
  erb :edit
end

patch '/:id/edit' do
  @id = params[:id]
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = MemoApp.connect_to_sql
  memo.edit_memos(memo_title, memo_text, @id)
  redirect to('/')
  erb :edit
end
