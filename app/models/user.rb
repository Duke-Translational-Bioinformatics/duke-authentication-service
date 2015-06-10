class User
  attr_reader :uid, :display_name, :mail
  def initialize(params = {})
    [:uid,:display_name,:mail].each do |required_key|
      unless params.has_key? required_key
        raise ArgumentError.new('missing required key')
      end
    end
    @uid = params[:uid]
    @display_name = params[:display_name]
    @mail = params[:mail]
  end
end
