module Errors
  class UserAlreadyExistsError < GraphQL::ExecutionError
    def to_h
      super.merge({ "extensions" => {"code" => "USER_ALREADY_EXISTS"} })
    end
  end
end