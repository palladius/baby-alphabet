
$VERSION = File.read("#{Rails.root}/VERSION").strip

# load ".env"
Dotenv.load

# This is the meta default :)
ALPHABET_DEFAULT_FOLDER_IN_CASE_NOTHING_IS_FOUND = "vanilla"

Rails.application.configure do

    config.hosts << "aj-alphabet.palladi.us"
    config.hosts << "*.palladi.us"
    config.hosts << "*.palladius.it"

end