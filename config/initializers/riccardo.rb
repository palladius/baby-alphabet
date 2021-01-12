
$VERSION = File.read("#{Rails.root}/VERSION").strip

Rails.application.configure do

    config.hosts << "aj-alphabet.palladi.us"
    config.hosts << "*.palladi.us"
    config.hosts << "*.palladius.it"

    end