class UserMailer < ActionMailer::Base
  def signup_notification(activation_url, user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = activation_url

  end

  def activation(site_url, user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = site_url
  end

  def reset_notification(reset_url, user)
    setup_email(user)
    @subject    += 'Link to reset your password'
    @body[:url]  = reset_url
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "admin@brokenmodel.com"
      @subject     = "brokenmodel.com "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
