module ApplicationHelper
    EMPTY_SQUARE_FILENAME = "_empty.jpg"
    EMPTY_VERTICAL_FILENAME = "_portrait.jpg"
    EMPTY_HORIZONTAL_FILENAME = "_landscape.jpg"
    BASE_DIRECTORY = AlphabetPicture.class_image_base # might change

    # todo consider using $image_base and see if you can toggle it 
    def alphabet_image_tag(subpath, options={} )
        #puts " -- Helper::alphabet_image_tag('#{subpath}')"
        base = AlphabetPicture.class_image_base
        subpath = "_empty.jpg" if subpath.to_s == "" #subpath.nil? 
        return image_tag("#{base}/#{subpath}", options) 
    end

    def empty_image_path(type = :any)
        # so i prep for VERTICAL and HORICONTAL default :)
        return "#{BASE_DIRECTORY}/#{EMPTY_VERTICAL_FILENAME}" if type == :vertical
        return "#{BASE_DIRECTORY}/#{EMPTY_VERTICAL_FILENAME}" if type == :portrait

        return "#{BASE_DIRECTORY}/#{EMPTY_HORIZONTAL_FILENAME}" if type == :horizontal
        return "#{BASE_DIRECTORY}/#{EMPTY_HORIZONTAL_FILENAME}" if type == :landscape

        # anything else yields this.. the square one
        "#{BASE_DIRECTORY}/#{EMPTY_SQUARE_FILENAME}"
    end

end
