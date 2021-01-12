class ArticlesController < ApplicationController


  def index
    _common_variables
  end

  def alphabet
    @predilige = params[:predilige]
    @cells_per_row = params[:cells_per_row]
    _common_variables
  end

  def showletter
    _common_variables
    @letter = params[:letter].to_s[0].downcase
  end

  def _common_variables
    #@photos = AlphabetPicture.findall
    #@photos = Dir[ Rails.root + "app/assets/images/alphabet/*" ]
    $print_friendly = params[:print_friendly]
    @alphabet_photo_paths = AlphabetPicture.findall
    $alphabet = ('A'..'Z').to_a
    if params[:alphabet] == 'it'
      $alphabet = ('A'..'I').to_a + ('L'..'V').to_a + ['Z']
    end
    #@photos.map{|paz| paz.slice! "#{Rails.root}/app/assets/images/alphabet/" ; paz  } 
  end
end
