class HomeController < ApplicationController
  def index
  end

  def login
    unless params[:oauth_token]
      unless session[:access_token]
        consumer = OAuth::Consumer.new(ENV['EVERNOTE_CONSUMER_KEY'], ENV['EVERNOTE_CONSUMER_SECRET'], {
          site: ENV['EVERNOTE_SITE'],
          request_token_path: "/oauth",
          access_token_path: "/oauth",
          authorize_path: "/OAuth.action"
        })
        @request_token = consumer.get_request_token(oauth_callback: home_login_url)
        redirect_url =  @request_token.authorize_url(oauth_callback: home_login_url)
        session[:request_token] = @request_token
        redirect_to redirect_url
      else
        access_token = session[:access_token]
        evernote_user_id = access_token.params[:edam_userId]
        unless user = User.find_by_evernote_id(evernote_user_id)
          user = User.new({
            access_token: access_token.token,
            evernote_shard: access_token.params[:edam_shard],
            evernote_id: evernote_user_id
          })
          user.save
        end
        session[:user_id] = user.id
        redirect_to tags_index_path, :notice => "Successfully logged in"
      end
    else
      if session[:request_token]
        @request_token = session[:request_token]
        access_token = @request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
        session[:access_token] = access_token
        redirect_to :action => :login
      else
        redirect_to root_path, :alert => "Unexpected error"
      end
    end
  end

  def logout
    session[:user_id] = nil
    session[:access_token] = nil
    redirect_to root_url, :notice => "Successfully logged out"
  end

end
