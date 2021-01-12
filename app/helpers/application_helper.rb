module ApplicationHelper

    # todo use $image_base 

    def alphabet_image_tag(subpath, options={} )
        puts " -- Helper::alphabet_image_tag('#{subpath}')"
        #return image_tag("ajcarlesso/#{subpath}", options)
        base = AlphabetPicture.class_image_base 
       return image_tag("#{base}/#{subpath}", options)
        @@image_base 
    end

end
