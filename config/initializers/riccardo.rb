
$VERSION = File.read("#{Rails.root}/VERSION").strip

# load ".env" automatically
$dotenv_vars = Dotenv.load
# Force manually to load ".env" and ".env.MYENV" which should be the dflt behaviours but looks like its not
DOTENV_SMART_VARS = Dotenv.load ".env", ".env.#{Rails.env}"


# This is the meta default :)
ALPHABET_DEFAULT_FOLDER_IN_CASE_NOTHING_IS_FOUND = "vanilla"

Rails.application.configure do

    config.hosts << "aj-alphabet.palladi.us"
    config.hosts << "*.palladi.us"
    config.hosts << "*.palladius.it"
    config.hosts << ENV["FQDN"] if ENV["FQDN"] 

end