require 'ssh_credential_helper'

class NetworkScanHelper
  include Enumerable

  attr_accessor :collection
  private :collection

  # create a new collection (list) of credential data; each credential
  # is a hash object of key / value pairs representing a basic user name
  # and password login.
  #
  def initialize(host_list)
    @collection = []
    host_list.each do |host_kvp|
      if NetworkScanHelper.host_valid(host_kvp)
        if NetworkScanHelper.host_valid(host_kvp, true)
          @collection.append(_copy_host(host_kvp, true))
        else
          puts("WARNING: host data is missing required fields; host_kvp=#{host_kvp.to_s}")
        end
      end
    end
  end

  ### IMPLEMENTATION OF ENUMERABLE
  def each(&block)
    @collection.each(&block)
  end

  def to_s
    # TODO: replace user_pwd value with '*******' for security purposes
    @collection.to_s
  end

  def inspect
    # TODO: make sure this calls to_s or hides user_pwd value for security purposes
    @collection.inspect
  end

  ### CLASS METHODS
  private :_copy_host
  def _copy_host(host_kvp, with_cred=false)
    ret_hash = {}
    key_list = [ 'ref_id', 'server_ip', 'fqdn', 'credential_ref' ]
    key_list.append('user_name', 'user_pwd') if with_cred
    key_list.each do |key|
      ret_hash[key] = host_kvp.fetch(key, '')
    end
    ret_hash
  end

  # static method to load a network host scan list and associated login
  # credentials to assist in making connections to a large list of hosts.
  #
  def self.load(file_name)
    # open the network host scan list
    in_file   = File.open(file_name, 'r')
    json_data = JSON.load(in_file)
    cred_file = json_data.get('credential_file', nil)
    raise ArgumentError, "ERR: no credential_file specified in scan list #{in_file}" if cred_file.nil?
    raise ArgumentError, "ERR: credential_file specified #{in_file} not found" unless File.exist?(cred_file)
    # validate the host list real quick, before creating any objects
    host_list    = json_data.get('hosts', nil)
    raise ArgumentError, "ERR: no hosts specified in scan list #{in_file}" if host_list.nil?
    raise ArgumentError, "ERR: hosts specified in #{in_file} is empty" if host_list.count == 0
    #
    # load the encrypted credential list, then load the host connections
    # and copy each login credential its referenced host item.
    #
    cred_helper = SshCredentialHelper.new(JSON.load(cred_file))
    cred_helper.copy_refs!(host_list)
    NetworkScanHelper.new(host_list)
  end

  # static method to validate contents of any host data set; all keys must
  # be present in the data set to be valid.
  #
  def self.host_valid(host_kvp, with_cred=false)
    valid    = true
    key_list = [ 'ref_id', 'server_ip', 'fqdn', 'credential_ref' ]
    key_list.append('user_name', 'user_pwd') if with_cred
    key_list.each do |expected_key|
      if not host_kvp.keys.include?(expected_key)
        valid = false
      elsif host_kvp.get(expected_key, nil).nil?
        valid = false
      elsif host_kvp[expected_key] == ''
        valid = false
      end
    end
    valid
  end

end

