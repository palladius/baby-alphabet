class AlphabetPicture # < ActiveRecord::Base
    #self.abstract_class = true

    attr_accessor :filename, :size, :nil

    # e.g. filename = "seychelles.jpg"
    def initialize(filename)
      puts("++++++++ DEB AlphabetPicture.new('#{filename}' [#{filename.class}])")
      self.filename = filename.to_s
      self.nil=false
      if filename.nil? 
        self.nil = true
        return
      end
      begin
        self.size = FastImage.size("#{Rails.root}/app/assets/images/#{image_path}") 
      rescue Exception
        puts("Exception: #{$!}")
        self.size = [1, 1]
        self.nil = true
      end
    end

    def nil?
      self.nil
    end

    def initial
      filename[0]
    end

    def image_path
      "alphabet/#{filename}"
    end

    def width
      size[0]
    end
    def height
      size[1]
    end

    # or I piss of my wife!
    # Model is this:
    # pizza.jpg -> [ pizza, pizza]
    # "mamma (mum).jpg" -> [mamma, mum]
    def bilingual_words
      #if filename =~ /_portrait|_landscape/i
      #  return [ "#{self.initial}??", "O_missing"]
      #end
      if filename =~ /(.*)\(.*\)/
          regex_incasinata = /(.+)\((.+)\)/
        [  
          filename[regex_incasinata, 1] ,

          filename[regex_incasinata, 2] ,
        ]
      else
        [ basename, basename]
      end
    end

    def word_in_primary_language # italian
      bilingual_words[0].capitalize.split(" ").first
    end
    def word_in_secondary_language # UK
      bilingual_words[1].capitalize.split(" ").first
    end

    def verticality
      ar = aspect_ratio  # cachiong
      
      return :very_wide  if  ar > 1.5
      return "landscape" if  ar.between?(1.25, 1.4)  # 4/3
      return "square" if  ar.between?(0.9, 1.1)      # 1/1
      return "portrait" if  ar.between?(0.66, 0.82)  # 3/4
      return :very_tall  if  ar < 0.65
      return :boh
    end

    def aspect_ratio
      1.0*width/height 
    end

    def paz
      #OBSOLETE!
      filename
    end

    def fake?
      filename =~ /^_/   # _portrait.jpg e _landscape.jpg
    end
    alias_method :prestanome?, :fake?


    def full_path
        "alphabet/#{paz}" # obj.full_path
    end
    def basename # or PAROLA
      filename.split(".")[0] # obj.basename
    end
    alias_method :parola, :basename
    def prima_parola
      #"Babbo Natale" => "Babbo"
      return nil if fake?
      basename.split(" ")[0].gsub("_"," ") # cosi puoi nominare un file "babbo_natale" e funge!
    end
    
    def to_s
      "AlphabetPicture('#{filename}'): #{width}x#{height} (#{aspect_ratio} / #{verticality})"
    end

    def self.findall_by_initial_and_verticality(initial, verticality)
      findall_by_initial(initial).select{|file| AlphabetPicture.new(file).verticality == verticality }
    end

    # useless to final client, tough logic here
    def self._find_longfiles(initial=nil)
      if initial.nil?
        Dir[ Rails.root + "app/assets/images/alphabet/*" ]
      else
        lowercase_initial = initial.to_s[0].downcase # :)
        raise "Wrong initial! #{lowercase_initial}" unless lowercase_initial.between?('a', 'z')
        arr_up = Dir[ Rails.root + "app/assets/images/alphabet/#{lowercase_initial}*" ] # nota che dovrei anche prendere quelle MAIUSCOLE :) TODO
        arr_down = Dir[ Rails.root + "app/assets/images/alphabet/#{lowercase_initial.upcase}*" ] # nota che dovrei anche prendere quelle MAIUSCOLE :) TODO
        arr_up + arr_down # = Dir[ Rails.root + "app/assets/images/alphabet/#{lowercase_initial.upcase}*" ] # nota che dovrei anche prendere quelle MAIUSCOLE :) TODO
      end
    end
    def self.findall_by_initial(initial=nil)
      # fullpath_images=[]
      # if initial.nil?
      #   fullpath_images =  Dir[ Rails.root + "app/assets/images/alphabet/*" ]
      # else
      #   lowercase_initial = initial.to_s[0].downcase # :)
      #   raise "Wrong initial! #{lowercase_initial}" unless lowercase_initial.between?('a', 'z')
      #   arr_up = Dir[ Rails.root + "app/assets/images/alphabet/#{lowercase_initial}*" ] # nota che dovrei anche prendere quelle MAIUSCOLE :) TODO
      #   arr_down = Dir[ Rails.root + "app/assets/images/alphabet/#{lowercase_initial.upcase}*" ] # nota che dovrei anche prendere quelle MAIUSCOLE :) TODO
      #   fullpath_images = arr_up + arr_down # = Dir[ Rails.root + "app/assets/images/alphabet/#{lowercase_initial.upcase}*" ] # nota che dovrei anche prendere quelle MAIUSCOLE :) TODO
      # end
      # fullpath_images.map{|paz| paz.slice! "#{Rails.root}/app/assets/images/alphabet/" ; paz  } 
      _find_longfiles(initial).map{|path| path.slice! "#{Rails.root}/app/assets/images/alphabet/" ; path  } 
    end

    def self.findall()
      self.findall_by_initial()
    end

  end