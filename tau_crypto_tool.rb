require 'openssl'
require 'base64'
require 'yaml'


COMMAND_CREATE_KEY = "-create_key"
COMMAND_ENCRYPT = "-private_encrypt"
COMMAND_DECRYPT = "-public_decrypt"

YAML_DATA_ARRAY_BLOCK = "data"

def help
  print "
  You must setup next parameters :



  Usage: #{__FILE__} #{COMMAND_CREATE_KEY} private_key_file public_key_file
  Usage: #{__FILE__} #{COMMAND_ENCRYPT} private_key_file input_file output_file
  Usage: #{__FILE__} #{COMMAND_DECRYPT} public_key_file input_file output_file

  Example: #{__FILE__} #{COMMAND_CREATE_KEY} private.pem public.pem
  Example: #{__FILE__} #{COMMAND_ENCRYPT} private.pem text.txt encrypted_text.txt
  Example: #{__FILE__} #{COMMAND_DECRYPT} public.pem encrypted_text.txt decrypted_text.txt

"
end

def generate_key(private_file, public_file)
    puts " generate key START"

    key = OpenSSL::PKey::RSA.new(2048)
    public_key = key.public_key

    puts " Save private key into "+private_file
    File.write(private_file, key.to_pem)
    puts " Save public key into "+public_file
    File.write(public_file, public_key.to_pem)

    puts " generate key FINISH"

end

def do_private_encrypt(private_key_file, input_file, output_file)
    puts " private encrypt START"

    puts " Load private key from "+private_key_file
    private_key = OpenSSL::PKey::RSA.new File.read private_key_file

    puts " Load input data from "+input_file
    input_data = File.open(input_file).read
    #puts "input_data = "+input_data.to_s

    puts " Preparing input data"
    input_data_64 = Base64.encode64(input_data)
    #puts "input_data_64 = "+input_data_64.to_s

    input_array_of_strings = input_data_64.chars.each_slice(128).map(&:join)
    #puts "input_array_of_strings = "+input_array_of_strings.to_s

    output_yaml = {}
    output_yaml[YAML_DATA_ARRAY_BLOCK] = []

    puts " Encrypt data"
    input_array_of_strings.each do |str|
        #puts "    str = "+str.to_s

        output_data = private_key.private_encrypt(str, OpenSSL::PKey::RSA::PKCS1_PADDING)
        #puts "    output_data = "+output_data.to_s

        output_data_64 = Base64.encode64(output_data)
        #puts "    output_data_64 = "+output_data_64.to_s

        output_yaml[YAML_DATA_ARRAY_BLOCK] << output_data_64
    end

    puts " Save encrypted data into "+output_file
    File.write(output_file, output_yaml.to_yaml)

    puts " private encrypt FINISH"
end

def do_public_decrypt(public_key_file, input_file, output_file)
    puts " public decrypt START"

    puts " Load public key from "+public_key_file
    public_key = OpenSSL::PKey::RSA.new File.read public_key_file

    puts " Load encrypted data from "+input_file
    input_file_yaml = YAML::load_file(input_file)
    input_array = input_file_yaml[YAML_DATA_ARRAY_BLOCK]

    output_array = []

    puts " Decrypt data"
    input_array.each do |str|
        decrypted_str = public_key.public_decrypt(Base64.decode64(str), OpenSSL::PKey::RSA::PKCS1_PADDING)
        output_array << decrypted_str
    end

    puts " Preparing data"
    output_64 = output_array.join
    output_data = Base64.decode64(output_64)

    puts " Save decrypted data into "+output_file
    File.write(output_file, output_data)
    
    puts " public decrypt FINISH"
end




if !(((ARGV.size == 3) || (ARGV.size == 4)) && ([COMMAND_CREATE_KEY, COMMAND_ENCRYPT, COMMAND_DECRYPT].include?(ARGV[0].to_s.downcase))  )
  help
  exit
end

if  ARGV[0].to_s.downcase == COMMAND_CREATE_KEY
    generate_key(ARGV[1], ARGV[2])
    exit
end

if  ARGV[0].to_s.downcase == COMMAND_ENCRYPT
    do_private_encrypt(ARGV[1], ARGV[2], ARGV[3])
    exit
end

if  ARGV[0].to_s.downcase == COMMAND_DECRYPT
    do_public_decrypt(ARGV[1], ARGV[2], ARGV[3])
    exit
end

help
