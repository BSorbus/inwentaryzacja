class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.inwentaryzacja.v#{@version}")
    #req.headers.fetch(:accept).include?("application/vnd.netpar2015.v#{@version}")
  end
end