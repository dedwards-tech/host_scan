require 'json'


# TODO: introduce the notion of a credential object for types of credentials

class Credential
  attr_accessor :dict
  private :dict

  def initialize(kvp_in)
    @dict = {}
    [ 'ref_id', 'user_name', 'user_pwd' ].each do |expected_key|
      @dict[expected_key] = kvp_in.fetch(expected_key, '')
    end
  end

  def [](key, default=nil)
    @dict.fetch(key, default)
  end

  # get a copy of credential data, minus internal items like ref_id, missing
  #   # fields will be created as '' (blank) strings.
  def copy
    ret_hash = {}
    [ 'user_name', 'user_pwd' ].each do |key|
      ret_hash[key] = @dict.fetch(key, '')
    end
    ret_hash
  end

  # deep copy of this entire object, missing fields will be copied as
  # '' (blank) strings.
  def clone
    ret_hash = {}
    @dict.keys.each do |key|
      ret_hash[key] = @dict.fetch(key, '')
    end
    ret_hash
  end

  def to_hash
    @dict
  end

  def to_s
    @dict.to_s
  end

  def inspect
    @dict.inspect
  end
end


class CredentialList
  include Enumerable

  attr_accessor :collection
  private :collection

  def initialize(credential_list)
    @collection = []
    credential_list.each { |cred_kvp| append(cred_kvp) }
  end

  def append(cred_kvp)
    @collection.append(Credential.new(cred_kvp))
  end

  def each(&block)
    @collection.each(&block)
  end

  # fetch the credential with the matching 'ref_id' value.
  # retrieves a single credential (hash) or default value (nil if not specified).
  # yields the result if a block is provided.
  #
  def fetch(ref_id, default=nil)
    ret_item = default
    @collection.each do |credential|
      if credential['ref_id'] == ref_id
        # copy everything except the 'ref_id'
        ret_item = credential.copy
        break
      end
    end
    yield ret_item if block_given?
    ret_item
  end

  # copy one or more credential references from a list of hashes
  # containing a 'ref_id' field associated with a credential.
  # if a block is provided, it will only copy those references
  # that return a value of true.
  #
  def copy_refs!(ref_list, ref_key='credential_ref')
    ref_list.each do |ref_item|
      found_item = fetch(ref_item[ref_key])
      next if found_item.nil?
      if block_given?
        # skip this reference if the yield returns false
        next unless yield(found_item)
      end
      # copy the credential fields to the ref_list object
      ref_item.merge!(found_item)
    end
    ref_list
  end

  def to_s
    @collection.to_s
  end

  def inspect
    @collection.inspect
  end
end

class CredentialHelper

  def self.load(file_name)
    # open the encrypted password file and load them into a collection
    in_file = File.open(file_name, 'r')

    # TODO: decrypt the file from binary to its json form

    # return an enumerator of credentials
    CredentialList.new(JSON.load(in_file))
  end

end
