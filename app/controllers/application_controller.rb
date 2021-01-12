class ApplicationController < ActionController::Base


    add_flash_types :info, :error, :warning
    before_action :_set_important_variables

    # https://guides.rubyonrails.org/action_controller_overview.html
    def default_url_options
        { locale: I18n.locale }
    end


    def _set_important_variables
        $testvar = 42
        #AlphabetPicture.image_base = "ajcarlesso"

        messaggio_occasionale = ENV.fetch "MESSAGGIO_OCCASIONALE", nil
        flash[:notice] = "[OCCASIONAL_MESSAGE] #{messaggio_occasionale}"  if messaggio_occasionale 
    end

end
