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

end
