class PlacesController < ApplicationController

    before_action :authenticate_user!, :except => [ :show, :home ]

    def home
        if user_signed_in?
            redirect_to '/places'
        else
            return
        end
    end

    def index
        @places = Place.where(approval: true)
        # @places = Place.all
    end

    def approve
        if can? :approval, Project
          @project.update_attributes approval: true
        end
    end

    def show
        require 'uri-handler'
        @place = Place.find(params[:id])
        @rating = Rating.where(place_id: params[:id]).take
        @review = Review.where(place_id: params[:id]).take
    end

    def new
        @place = Place.new
        @rating = Rating.new
        @review = Review.new
        @tags = Tag.all
    end

    def edit
        @place = Place.find(params[:id])
    end

    def create
        @place = Place.new(place_params)

        @place.user = current_user

        uploaded_file = place_params[:img_url].path

        cloudnary_file = Cloudinary::Uploader.upload(uploaded_file)

        @place.img_url = cloudnary_file['public_id']

        @place.save

        @rating = Rating.new(rating_params)

        @rating.user = current_user

        @rating.place = @place

        @rating.save

        if review_params[:review] == ""
            redirect_to @place
            return
        else

        @review = Review.new(review_params)

        @review.user = current_user

        @review.place = @place

        @review.save

        end

        redirect_to @place
    end


    def update
        @place = Place.find(params[:id])

        @place.update(place_params)
        redirect_to @place
    end

    def destroy
    end

    private
    def place_params
        params.require(:place).permit(:id, :name, :description, :img_url, :address, :approval, :tag_ids => [])
    end

    def rating_params
        params.require(:place).permit(:value)
    end

    def review_params
        params.require(:place).permit(:review)
    end

end