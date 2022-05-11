require 'rho/rhoapplication'
require 'openssl'
require 'base64'




def do_public_decrypt(public_key_file, input_file)
    puts " public decrypt START"

    puts " Load public key from "+public_key_file
    public_key = OpenSSL::PKey::RSA.new File.read public_key_file

    puts " Load encrypted data from "+input_file

    #input_file_yaml = YAML::load_file(input_file)
    input_file_yaml = File.read input_file
    #input_array = input_file_yaml[YAML_DATA_ARRAY_BLOCK]
    input_array = input_file_yaml.split(";")


    output_array = []

    puts " Decrypt data"
    input_array.each do |str|
        decrypted_str = public_key.public_decrypt(Base64.decode64(str), OpenSSL::PKey::RSA::PKCS1_PADDING)
        output_array << decrypted_str
    end

    puts " Preparing data"
    output_64 = output_array.join
    output_data = Base64.decode64(output_64)

    puts " public decrypt FINISH"


    return output_data
end


class AppApplication < Rho::RhoApplication
  def initialize
    # Tab items are loaded left->right, @tabs[0] is leftmost tab in the tab-bar
    # Super must be called *after* settings @tabs!
    @tabs = nil
    #To remove default toolbar uncomment next line:
    #@@toolbar = nil
    super

    puts "***** TEST decrypt START"

    key_file = File.join(Rho::RhoApplication::get_model_path('app','Settings'), 'public.pem')
    encrypted_file = File.join(Rho::RhoApplication::get_model_path('app','Settings'), 'encrypted.txt')
    decrypted_text = do_public_decrypt(key_file, encrypted_file)
    puts "**** DECRYPTED TEXT START *****"
    puts decrypted_text
    puts "**** DECRYPTED TEXT FINISH *****"

    puts "***** TEST decrypt FINISH"


  end
end
