# Etaggy - Extremely simple JSON store for testing ETag support in client libraries
#
# (C) 2010 Antonio Ognio <antonio at ognio then a dot and finally com>

require 'datamapper'
require 'dm-types'
require 'dm-timestamps'
require 'dm-is-slug'
require 'uuidtools'
require 'digest'
require 'json'

class JSONDocument

    include DataMapper::Resource

    property :id,         Serial
    property :uuid,       UUID,    :default => lambda { UUIDTools::UUID.random_create.to_s }, :unique => true
    property :doc_key,    String,  :length => 255, :required => true, :unique => true   
    property :body,       Text,    :required => true
    property :length,     Integer, :default => lambda { |r,p| r.body.length }
    property :created_at, DateTime 
    property :updated_at, DateTime

    validates_with_method :check_json

    def check_json
        begin
            JSON.parse(self.body)
            return true
        rescue
            [ false, "The document is not valid JSON." ]
        end
    end

    def etag
        Digest::SHA1.hexdigest((self.updated_at ? self.updated_at : self.created_at).to_s)
    end

    def to_hash
        {
            :_id        => self.uuid,
            :contents   => JSON.parse(self.body),
            :length     => self.length,
            :created_at => self.created_at,
            :updated_at => self.updated_at
        }
    end

    def to_json
        to_hash.to_json
    end

    def get_url
        "/docs/#{self.doc_key}"
    end

end
