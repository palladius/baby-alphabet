class ArticlesController < ApplicationController
  PERMITTED_PARAMS = [:name, :age]


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

      # rendo cambiabile la image base SOLO da show letter :)
    if params[:image_base] # "ajcarlesso"
      AlphabetPicture.image_base = params[:image_base] 
      flash[:alert] = "AlphabetPicture.image_base: Directory changed to @#{params[:image_base] }@."
    end
  end

  def varz
    _common_variables
  end
  
#  private:

  def _common_variables
    permitted_by_controller = params.permit(:predilige, :cells_per_row, :image_base)
    $print_friendly = params[:print_friendly]
    @alphabet_photo_paths = AlphabetPicture.findall
    # I should put this in ApplicationController I guess..
    $image_base = params[:image_base]
    $image_base = ENV["ALPHABET_DEFAULT_FOLDER"] if $image_base.nil?
    $image_base = "vanilla" if $image_base.nil?


    $alphabet = ('A'..'Z').to_a
    if params[:alphabet] == 'it'
      $alphabet = ('A'..'I').to_a + ('L'..'V').to_a + ['Z']
    end
  end
end
