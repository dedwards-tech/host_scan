require 'json'


class SshCredentialHelper
  include Enumerable

  attr_accessor :collection
  private :collection

  # create a new collection (list) of credential data; each credential
  # is a hash object of key / value pairs representing a basic user name
  # and password login.
  #
  def initialize(credential_list)
    @collection = []
    credential_list.each do |cred_kvp|
      if SshCredentialHelper.credential_valid(cred_kvp)
        if SshCredentialHelper.credential_valid(cred_kvp)
          @collection.append(_copy_cred(cred_kvp, true))
        else
          puts("WARNING: credential data is missing required fields; cred_kvp=#{cred_kvp.to_s}")
        end
      end
    end
  end

  ### IMPLEMENTATION OF ENUMERABLE
  def each(&block)
    @collection.each(&block)
  end

  # deep copy of the entire collection of credentials.
  def clone
    ret_list = []
    @collection.each do |credential_kvp|
      cred_copy = {}
      credential_kvp.keys.each do |key|
        cred_copy[key] = credential_kvp.fetch(key, '')
      end
      ret_list.append(cred_copy)
    end
    ret_list
  end

  def to_s
    @collection.to_s
  end

  def inspect
    @collection.inspect
  end

  ### CLASS METHODS
  private :_copy_cred
  def _copy_cred(cred_kvp, with_ref=false)
    ret_hash = {}
    key_list = ['user_name', 'user_pwd']
    key_list.append('ref_id') if with_ref
    key_list.each do |key|
      ret_hash[key] = cred_kvp.fetch(key, '')
    end
    ret_hash
  end

  # static method to load an encrypted credential file
  def self.load(file_name)
    # open the encrypted password file and load them into a collection
    in_file = File.open(file_name, 'r')

    # TODO: decrypt the file from binary to its json form

    # return an enumerator of credentials
    SshCredentialHelper.new(JSON.load(in_file))
  end

  # static method to validate contents of any credential hash; all keys
  # must be in the data set to be valid.
  #
  def self.credential_valid(credential_kvp)
    valid = true
    [ 'ref_id', 'user_name', 'user_pwd' ].each do |expected_key|
      if not credential_kvp.keys.include?(expected_key)
        valid = false
      elsif credential_kvp.get(expected_key, nil).nil?
        valid = false
      elsif credential_kvp[expected_key] == ''
        valid = false
      end
    end
    valid
  end

  # fetch the credential with the matching 'ref_id' value.
  # retrieves a single credential (hash) or default value (nil if not specified).
  # yields the result if a block is provided.
  #
  def fetch(ref_id, default = nil)
    ret_item = default
    @collection.each do |credential|
      if credential['ref_id'] == ref_id
        # copy everything except the 'ref_id'
        ret_item = _copy_cred(credential)
        break
      end
    end
    yield ret_item if block_given?
    ret_item
  end

  # copy one or more credential references from a list of hashes
  # containing a 'credential_ref' field associated with a credential.
  #
  def copy_ref(ref_item, ref_key='credential_ref')
    found_item = fetch(ref_item[ref_key])
    next if found_item.nil?
    new_item = {}
    ref_item.keys.each do |item_key|
      new_item.append(ref_item[item_key])
    end
    # copy only the essential credential fields to the ref_item hash
    new_item.merge!(_copy_cred(found_item))
    new_item
  end

  # copy one or more credential references from a list of hashes
  # containing a 'credential_ref' field associated with a credential.
  #
  def copy_refs!(ref_list, ref_key='credential_ref')
    ref_list.each do |ref_item|
      found_item = fetch(ref_item[ref_key])
      next if found_item.nil?
      # copy only the essential credential fields to the ref_item hash
      ref_item.merge!(_copy_cred(found_item))
    end
    ref_list
  end

end
