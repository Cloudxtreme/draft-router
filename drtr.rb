require 'sinatra'
#require 'datamapper'
require 'time'
#require 'rack-flash'
#require 'sinatra/redirect_with_flash'

SITE_TITLE = "Draft Router"
SITE_DESCRIPTION = "simplest way to draft perfection"

enable :sessions
#use Rack::Flash, :sweep => true

#DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/drtr.db")

class Player
=begin
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :drafted, Boolean, :required => true, :default => 0
	property :created_at, DateTime
	property :updated_at, DateTime
=end
end

#DataMapper.auto_upgrade!

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end


#
# Application
#

get '/' do
	@players = '' #Player.all :order => :id.desc
	@title = 'All Players'
	if @players.empty?
		#flash[:error] = 'No players found.'
	end
	erb :home
end

post '/' do
	p = Player.new
	p.attributes = {
		:content => params[:content],
		:created_at => Time.now,
		:updated_at => Time.now
	}
	if p.save
		redirect '/', :notice => 'Player created successfully.'
	else
		redirect '/', :error => 'Failed to save player.'
	end
end

get '/:id' do
	@player = Player.get params[:id]
	@title = "Edit player ##{params[:id]}"
	if @player
		erb :edit
	else
		redirect '/', :error => "Can't find that player."
	end
end

put '/:id' do
	p = Player.get params[:id]
	unless p
		redirect '/', :error => "Can't find that player."
	end
	p.attributes = {
		:content => params[:content],
		:complete => params[:complete] ? 1 : 0,
		:updated_at => Time.now
	}
	if p.save
		redirect '/', :notice => 'Player updated successfully.'
	else
		redirect '/', :error => 'Error updating player.'
	end
end

get '/:id/delete' do
	@player = Player.get params[:id]
	@title = "Confirm deletion of player ##{params[:id]}"
	if @player
		erb :delete
	else
		redirect '/', :error => "Can't find that player."
	end
end

delete '/:id' do
	p = Player.get params[:id]
	if p.destroy
		redirect '/', :notice => 'Player deleted successfully.'
	else
		redirect '/', :error => 'Error deleting player.'
	end
end

get '/:id/complete' do
	p = Player.get params[:id]
	unless p
		redirect '/', :error => "Can't find that player."
	end
	p.attributes = {
		:complete => p.complete ? 0 : 1, # flip it
		:updated_at => Time.now
	}
	if p.save
		redirect '/', :notice => 'Player marked as drafted.'
	else
		redirect '/', :error => 'Error marking player as drafted.'
	end
end
