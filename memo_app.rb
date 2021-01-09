# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

class Memo

  def initialize(connection)
    @connection = connection
  end

  def self.connect_to_sql
    connection = PG::connect(
    :host => "localhost",
    :user => 'ryotsukada',
    :password => 'Aochan1123',
    :dbname => 'memo_app'
    )
    Memo.new(connection)
  end

  def load_by_sql_data(user_id = nil)
    results = if user_id
                @connection.exec_params('SELECT * FROM Memo WHERE user_id = $1 ORDER BY user_id', [user_id])
              else
                @connection.exec_params('SELECT * FROM Memo ORDER BY user_id')
              end
    memos = {}
    results.each do |result|
      memos[result['user_id']] = { 'memo_title' => result['memo_title'], 'memo_text' => result['memo_text'] }
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
      SET memo_text = $1, memo_title = $2
      WHERE user_id = $3
    SQL
    @connection.exec_params(sql, [memo_title, memo_text, user_id])
  end
end

  get '/' do
    memo = Memo.connect_to_sql
    @memo_list = memo.load_by_sql_data
    erb :top
  end

  get '/new' do
    erb :post
  end

  post '/' do
    memo_title = params[:memo_title]
    memo_text = params[:memo_text]
    memo = Memo.connect_to_sql
    memo.data_create(memo_title, memo_text)
    redirect to('/')
    erb :post
  end

  get '/:id' do
    @id = params[:id]
    memo = Memo.connect_to_sql
    @memo_list = memo.load_by_sql_data(@id)

    erb :show
  end

  delete '/:id' do
    @id = params[:id]
    memo = Memo.connect_to_sql
    memo.data_delete(@id)
    redirect to('/')
    erb :top
  end

  get '/:id/edit' do
    @id = params[:id]
    memo = Memo.connect_to_sql
    @memo_list = memo.load_by_sql_data(@id)

    erb :edit
  end

  patch '/:id/edit' do
    @id = params[:id]
    memo_title = params[:memo_title]
    memo_text = params[:memo_text]
    memo = Memo.connect_to_sql
    memo.data_edit(memo_title, memo_text, @id)
    redirect to('/')
    erb :edit
  end
