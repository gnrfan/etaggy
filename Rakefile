require 'rake'

namespace :db do
    task :prepare do
        require 'rubygems'
        require 'datamapper'
        require 'models'

        @config = YAML.load_file(File.join('config', 'settings.yml'))
        DataMapper.setup(:default, @config[:database])
    end

    desc 'Create the database tables.'
    task :migrate => :prepare do
        DataMapper.auto_migrate!
    end

    desc 'Upgrade the database tables.'
    task :upgrade => :prepare do
        DataMapper.auto_upgrade!
    end
end

