class FirebaseClient
  attr_reader :connection

  def initialize
    url = "https://identitytoolkit.googleapis.com"
    @connection = Faraday.new(
      url: url,
      headers: {'Content-Type' => 'application/json'}) do |faraday|
      faraday.response(:json, content_type: /\bjson$/)
    end
  end

  def sign_up(email:, password:)
    payload = {
      :email => email,
      :password => password
    }

    url = "v1/accounts:signUp?key=#{ENV["FIREBASE_API_KEY"]}"
    response = connection.post(url, payload.to_json)
  end
end