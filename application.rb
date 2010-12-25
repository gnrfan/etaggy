# Etaggy - Extremely simple JSON store for testing ETag support in client libraries
#
# (C) 2010 Antonio Ognio <antonio at ognio then a dot and finally com>

require 'rubygems'
require 'sinatra'
require 'sinatra/cache'
require 'datamapper'
require 'haml'
require 'models'

configure do
    @config = YAML.load_file(File.join('config', 'settings.yml'))
    DataMapper.setup(:default, @config[:database])

    set :admin_username, @config[:admin][:name]
    set :admin_password, @config[:admin][:password]

    set :haml, {:format => :html5}

    set :cache_enabled, !development?
    set :cache_output_dir, File.dirname(__FILE__) + '/public/system/cache'

    set :public, File.dirname(__FILE__) + '/public'

    enable :sessions
end

not_found do
    haml :not_found, :cache => false
end

error do
    haml :error, :cache => false
end

helpers do
    
    def successful_rest_action(params)
        {
            :ok => true,
            :message => params[:message],
            :payload => params[:payload]
        }.to_json
    end

    def failed_rest_action(params)
        {
            :ok => false,
            :message => params[:message],
            :payload => params[:payload]
        }.to_json
    end

end

get '/' do
    haml :index
end

get '/about/?' do
    haml :about
end

get '/docs/:doc_key' do |doc_key|
    
    @document = JSONDocument.first(:doc_key => doc_key)
    raise not_found unless @document

    content_type "application/json"

    etag @document.etag

    @document.to_json

end

put '/docs/:doc_key' do |doc_key|

    content_type "application/json"

    @document = JSONDocument.first(:doc_key => doc_key)
    if @document
        payload = {:doc_key => doc_key, :_id => @document.uuid}
        return failed_rest_action :message => "The document already exist. You need to update it or delete it perhaps.", 
                                  :payload => payload
    end

    @document = JSONDocument.new(params)

    if @document.save
        payload = {:doc_key => doc_key, :_id => @document.uuid}
        successful_rest_action :message => "Document created successfully.", 
                               :payload => payload   
    else
        payload = {'doc_key' => doc_key}
        failed_rest_action :message => "Document creation failed.", 
                           :payload => payload
    end

end

post '/docs/:doc_key' do |doc_key|

    @document = JSONDocument.first(:doc_key => doc_key)
    raise not_found unless @document

    content_type "application/json"

    if @document.update(params)
        payload = {:doc_key => doc_key}
        successful_rest_action :message => "Document updated successfully.", :payload => payload   
    else
        payload = {'doc_key' => doc_key}
        failed_rest_action :message => "Document could not be updated.", :payload => payload
    end

end

delete '/docs/:doc_key' do |doc_key|

    @document = JSONDocument.first(:doc_key => doc_key)
    raise not_found unless @document

    content_type "application/json"

    if @document.destroy
        payload = {:doc_key => doc_key}
        successful_rest_action :message => "Document deleted successfully.", :payload => payload   
    else
        payload = {'doc_key' => doc_key}
        failed_rest_action :message => "Document could not be deleted.", :payload => payload
    end

end

get '/recent/?' do

   @recently_created = JSONDocument.all(:order => [ :created_at.desc ], :limit => 5)  
   @recently_updated = JSONDocument.all(:order => [ :updated_at.desc ], :limit => 5)  

   haml :recent

end
