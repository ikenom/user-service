module Errors
  class PasswordInvalidError < GraphQL::ExecutionError
    def to_h
      super.merge({ "extensions" => {"code" => "PASSWORD_INVALID"} })
    end
  end
end