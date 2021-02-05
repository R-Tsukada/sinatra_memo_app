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
      password: 'Aochan1123',
      dbname: 'memo_app'
    )
    MemoApp.new(connection)
  end

  def memo_records(user_id = nil)
    memos_rows = if user_id
                   @connection.exec_params('SELECT * FROM Memo WHERE user_id = $1 ORDER BY user_id', [user_id])
                 else
                   @connection.exec_params('SELECT * FROM Memo ORDER BY user_id')
                 end
    memos = {}
    memos_rows.each do |r|
      memos[r['user_id']] = { 'memo_title' => r['memo_title'], 'memo_text' => r['memo_text'] }
    end
    memos
  end

  def create_memos(memo_title, memo_text)
    sql = <<~SQL
      INSERT INTO Memo (memo_title, memo_text)
      VALUES($1, $2)
    SQL
    @connection.exec_params(sql, [memo_title, memo_text])
  end

  def delete_memos(user_id)
    sql = <<~SQL
      DELETE FROM Memo
      WHERE user_id = $1
    SQL
    @connection.exec_params(sql, [user_id])
  end

  def edit_memos(memo_title, memo_text, user_id)
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
  @memo = memo.memo_records
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
  @memo = sql.memo_records(@id)
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
  @memo = memo.memo_records(@id)
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
