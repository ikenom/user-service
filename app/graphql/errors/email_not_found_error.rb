module Errors
  class EmailNotFoundError < GraphQL::ExecutionError
    def to_h
      super.merge({ "extensions" => {"code" => "EMAIL_NOT_FOUND"} })
    end
  end
end