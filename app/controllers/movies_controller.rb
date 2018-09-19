class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.order(params[:sort_by])
    redirect = false

    @sort_column = nil
    if params.has_key?(:sort_by)
      @sort_column = params[:sort_by]
    elsif session.has_key?(:sort)
      @sort_column = session[:sort_by]
      redirect = true
    end
    
    @all_ratings = ['G','PG','PG-13','R']
    if params.has_key?(:ratings)
      @ratings = params[:ratings]
    elsif session.has_key?(:ratings)
      @ratings = session[:ratings]
      redirect = true
    else
      @ratings = Hash[@all_ratings.collect { |v| [v, ""] }]
    end
    
    @movies = Movie.where(:rating => @ratings.keys)
    session[:ratings] = @ratings
    
    if @sort_column
        @movies = @movies.order(params[:sort_by])
        session[:sort_by] = @sort_column 
    end
    
    if redirect
      flash.keep
      redirect_to movies_path({:sort_by => @sort_column, :ratings => @ratings})
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
