class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # get all the ratings from the movie.rb file
    @all_ratings = Movie.all_ratings
    # set the ratings to that in the params or session hash or to nil
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    # assign the params hash and session hash :sort key to the variable sort
    sort = params[:sort] || session[:sort]
    # case matches the sort variable, whether the :sort key value is title or release_date
    case sort
    when 'title'
      # set ordering to the db query of order to title
      # add the class hilite to the title header
      ordering = {:order => :title}
      @title_header = 'hilite'
    when 'release_date'
      # set ordering to the db query of order to release date
      # add the hilite class to the date header
      ordering = {:order => :release_date}
      @date_header = 'hilite'
    end

    # if the selected ratings is empty fill it with the value 1 so that the
    # checkboxes are checked
    if @selected_ratings == {}
      @selected_ratings = {"G"=>1, "PG"=>1, "PG-13"=>1, "R"=>1, "NC-17"=>1}
    end

    # this checks to see if the sorting was chosen, title or release date and keeps that
    # when the user changes the ratings
    if params[:sort] != session[:sort]
      session[:sort] = sort
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end

    # if the params hash and session hash aren't the same then make the
    # session hash have whatever is in the sort variable
    # if the selected ratings is not empty then give the session hash the
    # ratings and then redirect to the sorted page with the ratings and the
    # sort variable(either title or release date)
    if params[:ratings] != session[:ratings] and @selected_ratings != {}
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    # find the movies with a dynamic attribute-based finder with the ratings
    # and the ordering
    @movies = Movie.find_all_by_rating(@selected_ratings.keys, ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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
