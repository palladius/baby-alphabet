module ArticlesHelper

    def render_picture(alphabet_picture)
        return :ERROR unless alphabet_picture.is_a?(AlphabetPicture)
        alphabet_picture.to_s
    end

    def print_friendly?
        return false if $print_friendly.nil? 
        return $print_friendly == "true"
    end

    def render_if_print_friendly?()
        if print_friendly?
            yield
        else
            return
        end
    end
    def render_unless_print_friendly?()
        unless print_friendly?
            yield
        else
            return
        end
    end

    def render_varz_in_text_form()
        ret = "#varz:\n"
        $INTERESTING_ENV_VARS = %w{OCCASIONAL_MESSAGE MESSAGGIO_OCCASIONALE FQDN PROJECT_ID ALPHABET_DEFAULT_FOLDER HOSTNAME }
        $INTERESTING_ENV_VARS.each do |env|
            ret += "#{ env }:\t#{ ENV.fetch env, :boh }\n"

        end

        return ret
    end
end
