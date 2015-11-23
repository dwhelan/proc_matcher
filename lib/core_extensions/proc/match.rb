module CoreExtensions
  module Proc
    module Match
      def self.included(base)
        base.class_eval do
          def match(other)
            ProcSource.new(other) == ProcSource.new(self)
          end
        end
      end
    end
  end
end
