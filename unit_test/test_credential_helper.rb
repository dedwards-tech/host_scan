require 'test/unit'
require_relative File.join('..', 'credential_helper')

class UnitTest_CredentialHelper < Test::Unit::TestCase
  def test_pwd_file_load
    my_cred = CredentialHelper.load('./example_passwords.json')
    # TODO: add assert if count != 3 items in the collection
    # TODO: add assert if any fields are missing, or values are blank

    my_refs = [
        { "blah"      => "one",  "credential_ref" => "infra_admin" },
        { "blah_blah" => "two",  "credential_ref" => "infra_admin" },
        { "cheeze"    => "whiz", "credential_ref" => "esxi_user", "and" => "butter" }
    ]

    # make a deep copy of my_refs
    cp_refs = []
    my_refs.each { |dict| cp_refs.append(dict.clone) }

    # modify copy of credential references and compare
    my_cred.copy_refs!(cp_refs)
    # TODO: add assert if user_name and user_pwd fields are not present
    # TODO: add assert if ANY other fields than user_name, user_pwd, and original are present
    # TODO: add assert if user_name or user_pwd values are blank
  end
end
