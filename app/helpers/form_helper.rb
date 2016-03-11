module FormHelper
  def setup_user(user)
    1.times { user.addresses.build }
    user
  end
end