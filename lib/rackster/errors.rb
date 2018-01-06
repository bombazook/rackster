module Rackster
  module Errors
    class ExpectedError < StandardError; end
    class NoAppError < ExpectedError; end
    class ManualSetupError < ExpectedError; end
    class DbExists < ExpectedError; end
    class PendingMigrations < ExpectedError; end

    class UnexpectedError < StandardError; end
    class ConstMissingError < UnexpectedError; end
    class LoadError < UnexpectedError; end
    class UnexpectedConfig < UnexpectedError; end
  end
end
