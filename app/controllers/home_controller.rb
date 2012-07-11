class HomeController < ApplicationController
  def index
    redirect_to tags_index_path if current_user
  end

  def login
    if current_user
      redirect_to tags_index_path
    else
      consumer = OAuth::Consumer.new(ENV['EVERNOTE_CONSUMER_KEY'], ENV['EVERNOTE_CONSUMER_SECRET'], {
        site: ENV['EVERNOTE_SITE'],
        request_token_path: "/oauth",
        access_token_path: "/oauth",
        authorize_path: "/OAuth.action"
      })
      @request_token = consumer.get_request_token(oauth_callback: home_callback_url)
      redirect_url =  @request_token.authorize_url(oauth_callback: home_callback_url)
      session[:request_token] = @request_token
      redirect_to redirect_url
    end
  end

  def callback
    if session[:request_token]
      @request_token = session[:request_token]
      access_token = @request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
      evernote_user_id = access_token.params[:edam_userId]
      if user = User.find_by_evernote_id(evernote_user_id)
        user.access_token = access_token.token
      else
        user = User.new({
          access_token: access_token.token,
          evernote_shard: access_token.params[:edam_shard],
          evernote_id: evernote_user_id
        })
      end
      user.save
      session[:user_id] = user.id
      redirect_to tags_index_path, :notice => "Successfully logged in"
    else
      redirect_to root_path, :alert => "Unexpected error"
    end
  end

  def logout
    session[:user_id] = nil
    session[:access_token] = nil
    session[:request_token] = nil
    redirect_to root_url, :notice => "Successfully logged out"
  end

end
